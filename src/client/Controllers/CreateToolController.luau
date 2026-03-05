--!strict

local Players: Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService: RunService = game:GetService("RunService")
local Workspace: Workspace = game:GetService("Workspace")

local packagesFolder: Instance = ReplicatedStorage:WaitForChild("Packages")
local remotesFolder: Folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")

local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))

local BlockHelper: any = require(helpersFolder:WaitForChild("BlockHelper"))
local RaycastHelper: any = require(helpersFolder:WaitForChild("RaycastHelper"))

local Comm: any = require(packagesFolder:WaitForChild("Comm"))

local blockClientComm: any = Comm.ClientComm.new(remotesFolder, false, "BlockService")
local spawnBlockRemote: any = blockClientComm:GetFunction("SpawnBlock")

type PreviewState = {
	tool: Tool,
	ghost: PVInstance,
	blockDefinitionNumber: number,
	rotation: CFrame,
	activatedConnection: RBXScriptConnection,
}

local CreateToolController: any = {}

local activePreview: PreviewState? = nil

local function getPreviewTargetCFrame(previewGhost: PVInstance?): CFrame?
	local localPlayer: Player = Players.LocalPlayer
	local character: Model? = localPlayer.Character

	if character == nil then
		return nil
	end

	local rootPart: BasePart? = character.PrimaryPart

	if rootPart == nil then
		return nil
	end

	local excludedInstances: { Instance } = { character }

	if previewGhost ~= nil then
		local previewGhostInstance: Instance = previewGhost :: any
		table.insert(excludedInstances, previewGhostInstance)
	end

	local raycastResult: RaycastResult? = RaycastHelper.raycastFromMouse(excludedInstances)

	if raycastResult == nil then
		return nil
	end

	local rootPosition: Vector3 = rootPart.Position
	local targetPosition: Vector3 = raycastResult.Position
	local hitNormal: Vector3 = raycastResult.Normal

	if previewGhost ~= nil then
		targetPosition = BlockHelper.applyNormalOffset(previewGhost, targetPosition, hitNormal)
	end

	local maxDistance: number = TOOLS.CREATE.PREVIEW_DISTANCE_STUDS
	local clampedTargetPosition: Vector3 =
		BlockHelper.clampPositionFromOrigin(rootPosition, targetPosition, maxDistance)

	return CFrame.new(clampedTargetPosition)
end

local function disconnectConnection(connection: RBXScriptConnection): ()
	connection:Disconnect()
end

local function destroyGhost(ghost: PVInstance): ()
	local ghostInstance: Instance = ghost :: any

	ghostInstance:Destroy()
end

local function isToolActive(preview: PreviewState): boolean
	return preview.tool.Parent ~= nil
end

local function destroyActive(): ()
	local preview: PreviewState? = activePreview

	if preview == nil then
		return
	end

	disconnectConnection(preview.activatedConnection)
	destroyGhost(preview.ghost)
	activePreview = nil
end

local function getLivePreview(): PreviewState?
	local preview: PreviewState? = activePreview

	if preview == nil then
		return
	end

	if not isToolActive(preview) then
		destroyActive()
		return
	end

	return preview
end

local function placeActiveModel(): ()
	local preview: PreviewState? = getLivePreview()

	if preview == nil then
		return
	end

	local placementPosition: Vector3 = preview.ghost:GetPivot().Position
	spawnBlockRemote(preview.blockDefinitionNumber, placementPosition)
end

local function updateActiveCFrame(): ()
	local preview: PreviewState? = getLivePreview()

	if preview == nil then
		return
	end

	local targetTranslation: CFrame? = getPreviewTargetCFrame(preview.ghost)

	if targetTranslation == nil then
		return
	end

	preview.ghost:PivotTo(targetTranslation * preview.rotation)
end

function CreateToolController.destroyActive(): ()
	destroyActive()
end

function CreateToolController.createForTool(tool: Tool): ()
	destroyActive()

	local blockDefinitionNumber: number = tool:GetAttribute(TOOLS.CREATE.BLOCK_ATTRIBUTE_NAME)

	local ghostInstance: Model | BasePart? =
		BlockHelper.createBlockInstance(blockDefinitionNumber)

	if ghostInstance == nil then
		return
	end

	BlockHelper.setGhostVisuals(ghostInstance)
	ghostInstance.Parent = Workspace

	local ghost: PVInstance = ghostInstance :: any
	local currentPivot: CFrame = ghost:GetPivot()
	local rotationOnly: CFrame = currentPivot.Rotation
	local activatedConnection: RBXScriptConnection = tool.Activated:Connect(function(): ()
		placeActiveModel()
	end)

	activePreview = {
		tool = tool,
		ghost = ghost,
		blockDefinitionNumber = blockDefinitionNumber,
		rotation = rotationOnly,
		activatedConnection = activatedConnection,
	}

	updateActiveCFrame()
end

function CreateToolController.clearForTool(tool: Tool): ()
	local preview: PreviewState? = activePreview

	if preview == nil then
		return
	end

	if preview.tool ~= tool then
		return
	end

	destroyActive()
end

RunService.RenderStepped:Connect(function(): ()
	if activePreview == nil then
		return
	end

	updateActiveCFrame()
end)

return CreateToolController
