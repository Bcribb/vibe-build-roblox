--!strict

local CollectionService: CollectionService = game:GetService("CollectionService")
local Players: Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService: RunService = game:GetService("RunService")
local UserInputService: UserInputService = game:GetService("UserInputService")

local clientFolder: Instance = ReplicatedStorage:WaitForChild("Client")
local classesFolder: Instance = clientFolder:WaitForChild("Classes")
local packagesFolder: Instance = ReplicatedStorage:WaitForChild("Packages")
local remotesFolder: Folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")

local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))

local Comm: any = require(packagesFolder:WaitForChild("Comm"))
local RaycastHelper: any = require(helpersFolder:WaitForChild("RaycastHelper"))
local DeleteHighlight: any = require(classesFolder:WaitForChild("DeleteHighlight"))

local blockClientComm: any = Comm.ClientComm.new(remotesFolder, false, "BlockService")
local destroyBlockRemote: any = blockClientComm:GetFunction("DestroyBlock")

local DeleteToolController: any = {}

local activeTool: Tool? = nil
local deleteHighlight: any = DeleteHighlight.new()

local function isWithinDeleteDistance(hitPosition: Vector3): boolean
	local localPlayer: Player = Players.LocalPlayer
	local character: Model? = localPlayer.Character

	if character == nil then
		return false
	end

	local rootPart: BasePart? = character.PrimaryPart

	if rootPart == nil then
		return false
	end

	local distanceFromRoot: number = (hitPosition - rootPart.Position).Magnitude

	return distanceFromRoot <= TOOLS.DELETE.MAX_DISTANCE_STUDS
end

local function getTaggedAncestorModel(startInstance: Instance): Model?
	local current: Instance? = startInstance

	while current ~= nil do
		if current:IsA("Model") then
			local currentModel: Model = current

			if CollectionService:HasTag(currentModel, TOOLS.CREATE.CREATED_MODEL_TAG) then
				return currentModel
			end
		end

		current = current.Parent
	end

	return nil
end

local function getValidDeleteModelUnderMouse(): Model?
	local raycastResult: RaycastResult? = RaycastHelper.raycastFromMouse({ Players.LocalPlayer.Character })

	if raycastResult == nil then
		return nil
	end

	if not isWithinDeleteDistance(raycastResult.Position) then
		return nil
	end

	return getTaggedAncestorModel(raycastResult.Instance)
end

local function updateHoverHighlight(): ()
	local targetModel: Model? = getValidDeleteModelUnderMouse()

	if targetModel == nil then
		deleteHighlight:setTargetModel(nil)
		deleteHighlight:setEnabled(false)
		return
	end

	deleteHighlight:setTargetModel(targetModel)
	deleteHighlight:setEnabled(true)
end

local function destroyActive(): ()
	deleteHighlight:setTargetModel(nil)
	deleteHighlight:setEnabled(false)
	activeTool = nil
end

function DeleteToolController.destroyActive(): ()
	destroyActive()
end

function DeleteToolController.createForTool(tool: Tool): ()
	destroyActive()
	activeTool = tool
	updateHoverHighlight()
end

function DeleteToolController.clearForTool(tool: Tool): ()
	if activeTool ~= tool then
		return
	end

	destroyActive()
end

RunService.RenderStepped:Connect(function(): ()
	if activeTool == nil then
		return
	end

	if activeTool.Parent == nil then
		destroyActive()
		return
	end

	updateHoverHighlight()
end)

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean): ()
	if activeTool == nil then
		return
	end

	if gameProcessedEvent then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end

	if activeTool.Parent == nil then
		destroyActive()
		return
	end

	local targetModel: Model? = getValidDeleteModelUnderMouse()

	if targetModel == nil then
		return
	end

	destroyBlockRemote(targetModel)
end)

return DeleteToolController
