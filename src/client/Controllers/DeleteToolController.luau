--!strict

local CollectionService: CollectionService = game:GetService("CollectionService")
local Players: Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService: RunService = game:GetService("RunService")
local UserInputService: UserInputService = game:GetService("UserInputService")
local Workspace: Workspace = game:GetService("Workspace")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))

type DeleteState = {
	tool: Tool,
	activatedConnection: RBXScriptConnection,
	renderConnection: RBXScriptConnection,
	highlight: Highlight,
}

local DeleteToolController: any = {}

local activeDelete: DeleteState? = nil

local function getHighlightDepthMode(depthModeName: string): Enum.HighlightDepthMode
	if depthModeName == "AlwaysOnTop" then
		return Enum.HighlightDepthMode.AlwaysOnTop
	end

	return Enum.HighlightDepthMode.Occluded
end

local function getMouseRaycastResult(): RaycastResult?
	local localPlayer: Player = Players.LocalPlayer
	local character: Model? = localPlayer.Character
	local camera: Camera? = Workspace.CurrentCamera

	if character == nil or camera == nil then
		return nil
	end

	local mouseLocation: Vector2 = UserInputService:GetMouseLocation()
	local mouseRay: Ray = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local raycastParams: RaycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }

	return Workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 1000, raycastParams)
end

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
	local raycastResult: RaycastResult? = getMouseRaycastResult()

	if raycastResult == nil then
		return nil
	end

	if not isWithinDeleteDistance(raycastResult.Position) then
		return nil
	end

	return getTaggedAncestorModel(raycastResult.Instance)
end

local function updateHoverHighlight(highlight: Highlight): ()
	local targetModel: Model? = getValidDeleteModelUnderMouse()

	if targetModel == nil then
		highlight.Adornee = nil
		highlight.Enabled = false
		return
	end

	highlight.Adornee = targetModel
	highlight.Enabled = true
end

local function destroyActive(): ()
	local currentDeleteState: DeleteState? = activeDelete

	if currentDeleteState == nil then
		return
	end

	currentDeleteState.activatedConnection:Disconnect()
	currentDeleteState.renderConnection:Disconnect()
	currentDeleteState.highlight:Destroy()
	activeDelete = nil
end

local function destroyModelUnderMouse(): ()
	local targetModel: Model? = getValidDeleteModelUnderMouse()

	if targetModel == nil then
		return
	end

	targetModel:Destroy()
end

function DeleteToolController.destroyActive(): ()
	destroyActive()
end

function DeleteToolController.createForTool(tool: Tool): ()
	destroyActive()

	local highlight: Highlight = Instance.new("Highlight")
	highlight.FillColor = TOOLS.DELETE.HIGHLIGHT_FILL_COLOR
	highlight.FillTransparency = TOOLS.DELETE.HIGHLIGHT_FILL_TRANSPARENCY
	highlight.OutlineColor = TOOLS.DELETE.HIGHLIGHT_OUTLINE_COLOR
	highlight.OutlineTransparency = TOOLS.DELETE.HIGHLIGHT_OUTLINE_TRANSPARENCY
	highlight.DepthMode = getHighlightDepthMode(TOOLS.DELETE.HIGHLIGHT_DEPTH_MODE)
	highlight.Enabled = false
	highlight.Parent = Workspace
	local renderConnection: RBXScriptConnection = RunService.RenderStepped:Connect(function(): ()
		if tool.Parent == nil then
			destroyActive()
			return
		end

		updateHoverHighlight(highlight)
	end)
	local activatedConnection: RBXScriptConnection = tool.Activated:Connect(function(): ()
		if tool.Parent == nil then
			destroyActive()
			return
		end

		destroyModelUnderMouse()
	end)

	activeDelete = {
		tool = tool,
		activatedConnection = activatedConnection,
		renderConnection = renderConnection,
		highlight = highlight,
	}

	updateHoverHighlight(highlight)
end

function DeleteToolController.clearForTool(tool: Tool): ()
	local currentDeleteState: DeleteState? = activeDelete

	if currentDeleteState == nil then
		return
	end

	if currentDeleteState.tool ~= tool then
		return
	end

	destroyActive()
end

return DeleteToolController
