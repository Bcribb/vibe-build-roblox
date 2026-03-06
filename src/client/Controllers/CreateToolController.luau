--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService: RunService = game:GetService("RunService")
local Players: Players = game:GetService("Players")

local remotesFolder: Folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
local packagesFolder: Instance = ReplicatedStorage:WaitForChild("Packages")
local clientFolder: Instance = ReplicatedStorage:WaitForChild("Client")
local classesFolder: Instance = clientFolder:WaitForChild("Classes")
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")

local Comm: any = require(packagesFolder:WaitForChild("Comm"))

local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))

local RaycastHelper: any = require(helpersFolder:WaitForChild("RaycastHelper"))
local BlockHelper: any = require(helpersFolder:WaitForChild("BlockHelper"))
local PlayerHelper: any = require(helpersFolder:WaitForChild("PlayerHelper"))

local blockClientComm: any = Comm.ClientComm.new(remotesFolder, true, "BlockService")
local spawnBlockRemote: any = blockClientComm:GetFunction("SpawnBlock")

local BlockGhost: any = require(classesFolder:WaitForChild("BlockGhost"))

local enabled : boolean = false
local isAwaitingSpawn: boolean = false
local blockDefinitionNumber : number? = nil
local blockGhost : any? = nil
local toolActivatedConnection : RBXScriptConnection? = nil

local CreateToolController: any = {}

local function getOrCreateBlockGhost(blockDefinitionNumber: number): any
	if blockGhost then
		if blockGhost:getBlockDefinitionNumber() == blockDefinitionNumber then
			return blockGhost
		end

		blockGhost:destroy()
		blockGhost = nil
	end

	return BlockGhost.new(blockDefinitionNumber)
end

local function onRenderStepped(): ()
	if not enabled or isAwaitingSpawn then
		if blockGhost then
			blockGhost:setVisible(false)
		end

		return
	end

	blockGhost = getOrCreateBlockGhost(blockDefinitionNumber)
	blockGhost:setVisible(true)

	local hrp : BasePart? = PlayerHelper.getHumanoidRootPart(Players.LocalPlayer)

	if not hrp then
		return
	end

	local raycastResult: RaycastResult? = RaycastHelper.raycastFromMouse({ Players.LocalPlayer.Character })
	local position: Vector3 = (Players.LocalPlayer:GetMouse().Hit.Position)

	if raycastResult then
		position = raycastResult.Position
		position = BlockHelper.applyNormalOffset(blockGhost.model, position, raycastResult.Normal)
	end

	position = BlockHelper.clampPositionFromOrigin(hrp.Position, position, TOOLS.CREATE.PREVIEW_DISTANCE_STUDS)

	blockGhost:setPosition(position)
end

local function onToolActivated(): ()
	if not blockGhost or isAwaitingSpawn then
		return
	end

	local ghostPart: BasePart? = blockGhost.model:FindFirstChildWhichIsA("BasePart", true)

	if ghostPart == nil then
		return
	end

	local position: Vector3 = ghostPart.Position
	isAwaitingSpawn = true
	local spawnBlockPromise: any = spawnBlockRemote(blockGhost:getBlockDefinitionNumber(), position)
	spawnBlockPromise:catch(function(_error: any): ()
		isAwaitingSpawn = false
	end)
end

function CreateToolController.onToolEquipped(tool: Tool): ()
	blockDefinitionNumber = tool:GetAttribute(TOOLS.CREATE.BLOCK_ATTRIBUTE_NAME) :: number
	toolActivatedConnection = tool.Activated:Connect(onToolActivated)
	isAwaitingSpawn = false

	enabled = true
end

function CreateToolController.onToolUnequipped(): ()
	if toolActivatedConnection then
		toolActivatedConnection:Disconnect()
		toolActivatedConnection = nil
	end

	isAwaitingSpawn = false
	enabled = false
end

RunService.RenderStepped:Connect(onRenderStepped)

return CreateToolController