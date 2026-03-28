--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local packagesFolder: Instance = ReplicatedStorage:WaitForChild("Packages")
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")

local Comm: any = require(packagesFolder:WaitForChild("Comm"))
local Signal: any = require(packagesFolder:WaitForChild("Signal"))

local BlockHelper: any = require(helpersFolder:WaitForChild("BlockHelper"))

local DestroyContract: any = {}
DestroyContract.__index = DestroyContract

function DestroyContract.new(blocksRegistry: { [Model]: any }): any
	local self: any = setmetatable({}, DestroyContract)

	self.blocksRegistry = blocksRegistry
	self:initComm()
	self:initSignal()
	self:bindFunctions()

	return self
end

function DestroyContract:initComm(): ()
	local remotesFolder: Folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
	local destroyServerComm: any = Comm.ServerComm.new(remotesFolder, "DestroyContract")

	self.destroyServerComm = destroyServerComm
end

function DestroyContract:initSignal(): ()
	local destroySignal: any = Signal.new()

	self.destroySignal = destroySignal
end

function DestroyContract:bindFunctions(): ()
	local blocksRegistry: { [Model]: any } = self.blocksRegistry

	local function validateDestroyModel(player: Player, args: { any }): (boolean, ...any)
		local modelArgument: any = args[1]

		if typeof(modelArgument) ~= "Instance" then
			return false
		end

		if not modelArgument:IsA("Model") then
			return false
		end

		local targetModel: Model = modelArgument
		local blocksFolder: Folder = BlockHelper.getBlocksFolder()

		if not targetModel:IsDescendantOf(blocksFolder) then
			return false
		end

		if blocksRegistry[targetModel] == nil then
			return false
		end

		return BlockHelper.validateDelete(player, targetModel)
	end

	self.destroyServerComm:BindFunction("DestroyBlock", function(player: Player, model: Model): (boolean, boolean, nil)
		self.destroySignal:Fire(player, model)

		return true, true, nil
	end, { validateDestroyModel })
end

return DestroyContract
