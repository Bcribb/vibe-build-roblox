--!strict

local Players: Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService: RunService = game:GetService("RunService")
local UserInputService: UserInputService = game:GetService("UserInputService")
local Workspace: Workspace = game:GetService("Workspace")

local packagesFolder: Instance = ReplicatedStorage:WaitForChild("Packages")
local remotesFolder: Folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")

local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))
local Comm: any = require(packagesFolder:WaitForChild("Comm"))
local CreateToolHelper: any = require(helpersFolder:WaitForChild("CreateToolHelper"))

local blockClientComm: any = Comm.ClientComm.new(remotesFolder, false, "BlockService")
local spawnBlockRemote: any = blockClientComm:GetFunction("SpawnBlock")

type PreviewState = {
	tool: Tool,
	ghost: PVInstance,
	blockDefinitionNumber: number,
	rotation: CFrame,
	renderConnection: RBXScriptConnection,
	activatedConnection: RBXScriptConnection,
}

local CreateToolController: any = {}

local activePreview: PreviewState? = nil

local function getBoundsForPlacement(target: PVInstance): (CFrame, Vector3)
	if target:IsA("BasePart") then
		local targetPart: BasePart = target

		return targetPart.CFrame, targetPart.Size
	end

	local targetModel: Model = target :: Model

	return targetModel:GetBoundingBox()
end

local function getNormalOffsetDistance(target: PVInstance, normal: Vector3): number
	local boundsCFrame: CFrame, boundsSize: Vector3 = getBoundsForPlacement(target)
	local rightVector: Vector3 = boundsCFrame.RightVector
	local upVector: Vector3 = boundsCFrame.UpVector
	local lookVector: Vector3 = boundsCFrame.LookVector
	local projectedHalfExtent: number = (
		math.abs(normal:Dot(rightVector)) * boundsSize.X
		+ math.abs(normal:Dot(upVector)) * boundsSize.Y
		+ math.abs(normal:Dot(lookVector)) * boundsSize.Z
	) * 0.5

	return projectedHalfExtent
end

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

	local camera: Camera? = Workspace.CurrentCamera

	if camera == nil then
		return nil
	end

	local mouseLocation: Vector2 = UserInputService:GetMouseLocation()
	local mouseRay: Ray = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local filterInstances: { Instance } = { character }

	if previewGhost ~= nil then
		local previewGhostInstance: Instance = previewGhost :: any
		table.insert(filterInstances, previewGhostInstance)
	end

	local raycastParams: RaycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterInstances
	local raycastResult: RaycastResult? = Workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 1000, raycastParams)

	if raycastResult == nil then
		return nil
	end

	local rootPosition: Vector3 = rootPart.Position
	local targetPosition: Vector3 = raycastResult.Position
	local hitNormal: Vector3 = raycastResult.Normal

	if previewGhost ~= nil then
		local normalOffsetDistance: number = getNormalOffsetDistance(previewGhost, hitNormal)
		targetPosition += hitNormal * normalOffsetDistance
	end

	local maxDistance: number = TOOLS.CREATE.PREVIEW_DISTANCE_STUDS
	local offset: Vector3 = targetPosition - rootPosition
	local offsetMagnitude: number = offset.Magnitude

	if offsetMagnitude > maxDistance then
		targetPosition = rootPosition + (offset.Unit * maxDistance)
	end

	return CFrame.new(targetPosition)
end

local function setGhostVisuals(ghostRoot: Instance): ()
	if ghostRoot:IsA("BasePart") then
		local ghostPart: BasePart = ghostRoot
		ghostPart.Anchored = true
		ghostPart.Massless = true
		ghostPart.CanCollide = false
		ghostPart.CanTouch = false
		ghostPart.CanQuery = false
		ghostPart.Transparency = math.max(ghostPart.Transparency, 0.65)
	end

	for _, descendant: Instance in ghostRoot:GetDescendants() do
		if not descendant:IsA("BasePart") then
			continue
		end

		local ghostPart: BasePart = descendant
		ghostPart.Anchored = true
		ghostPart.Massless = true
		ghostPart.CanCollide = false
		ghostPart.CanTouch = false
		ghostPart.CanQuery = false
		ghostPart.Transparency = math.max(ghostPart.Transparency, 0.65)
	end
end

local function destroyActive(): ()
	local preview: PreviewState? = activePreview

	if preview == nil then
		return
	end

	preview.renderConnection:Disconnect()
	preview.activatedConnection:Disconnect()
	local ghostInstance: Instance = preview.ghost :: any

	ghostInstance:Destroy()
	activePreview = nil
end

local function placeActiveModel(): ()
	local preview: PreviewState? = activePreview

	if preview == nil then
		return
	end

	if preview.tool.Parent == nil then
		destroyActive()
		return
	end

	local placementPosition: Vector3 = preview.ghost:GetPivot().Position
	spawnBlockRemote(preview.blockDefinitionNumber, placementPosition)
end

local function updateActiveCFrame(): ()
	local preview: PreviewState? = activePreview

	if preview == nil then
		return
	end

	if preview.tool.Parent == nil then
		destroyActive()
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

	local blockDefinitionNumber: number? =
		CreateToolHelper.getBlockDefinitionNumber(tool)

	if blockDefinitionNumber == nil then
		return
	end

	local ghostInstance: Model | BasePart? =
		CreateToolHelper.createBlockInstance(blockDefinitionNumber)

	if ghostInstance == nil then
		return
	end

	setGhostVisuals(ghostInstance)
	ghostInstance.Parent = Workspace

	local ghost: PVInstance = ghostInstance :: any
	local currentPivot: CFrame = ghost:GetPivot()
	local rotationOnly: CFrame = currentPivot.Rotation
	local renderConnection: RBXScriptConnection = RunService.RenderStepped:Connect(function(): ()
		updateActiveCFrame()
	end)
	local activatedConnection: RBXScriptConnection = tool.Activated:Connect(function(): ()
		placeActiveModel()
	end)

	activePreview = {
		tool = tool,
		ghost = ghost,
		blockDefinitionNumber = blockDefinitionNumber,
		rotation = rotationOnly,
		renderConnection = renderConnection,
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

return CreateToolController
