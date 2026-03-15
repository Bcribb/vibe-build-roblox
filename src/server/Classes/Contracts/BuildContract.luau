--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local packagesFolder: Instance = ReplicatedStorage:WaitForChild("Packages")
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")

local Comm: any = require(packagesFolder:WaitForChild("Comm"))
local Signal: any = require(packagesFolder:WaitForChild("Signal"))

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))
local BlockHelper: any = require(helpersFolder:WaitForChild("BlockHelper"))

local BuildContract : any = {}
BuildContract.__index = BuildContract

local function validateBuild(player: Player, args: { any }): (boolean, boolean)
	local blockDefinitionNumber: number = args[1]
	local position: Vector3 = args[2]
	local rotation: number = args[3]
	local argLength: number = args["n"]

	if argLength ~= 3 then
		return false, false, "Invalid number of arguments"
	end

	if typeof(blockDefinitionNumber) ~= "number" then
		return false, false, "Block definition number is not a number"
	end

	if typeof(position) ~= "Vector3" then
		return false, false, "Position is not a vector3"
	end

	if typeof(rotation) ~= "number" then
		return false, false, "Rotation is not a number"
	end

	if BLOCKS.BLOCK_DEFINITIONS[blockDefinitionNumber] == nil then
		return false, false, "Block definition not found"
	end

	if rotation ~= 0 and rotation ~= 1 and rotation ~= 2 and rotation ~= 3 then
		return false, false, "Rotation is not valid"
	end

	return BlockHelper.validatePlacement(player, blockDefinitionNumber, position, rotation)
end

function BuildContract.new(): any
	local self: any = setmetatable({}, BuildContract)

	self:initComm()
	self:initSignal()
	self:bindFunctions()

	return self
end

function BuildContract:initComm(): ()
	local remotesFolder: Folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
	local buildServerComm: any = Comm.ServerComm.new(remotesFolder, "BuildContract")

	self.buildServerComm = buildServerComm
end

function BuildContract:initSignal(): ()
	local buildSignal: any = Signal.new()

	self.buildSignal = buildSignal
end

function BuildContract:bindFunctions(): ()
	self.buildServerComm:BindFunction("Build", function(player : Player, ... : any): ()
		self.buildSignal:Fire(player, ...)

		return true, true, nil
	end, { validateBuild })
end

return BuildContract