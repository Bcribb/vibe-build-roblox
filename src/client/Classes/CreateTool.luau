--!strict

local Players: Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService: RunService = game:GetService("RunService")
local Workspace: Workspace = game:GetService("Workspace")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))
local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))

type PreviewState = {
	tool: Tool,
	ghost: PVInstance,
	rotation: CFrame,
	renderConnection: RBXScriptConnection,
}

export type CreateTool = {
	activePreview: PreviewState?,
	destroyActive: (self: CreateTool) -> (),
	createForTool: (self: CreateTool, tool: Tool) -> (),
	clearForTool: (self: CreateTool, tool: Tool) -> (),
}

local CreateTool: any = {}
CreateTool.__index = CreateTool

local function getPreviewTargetCFrame(): CFrame?
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

	local previewPosition: Vector3 = rootPart.Position + (camera.CFrame.LookVector * TOOLS.CREATE.PREVIEW_DISTANCE_STUDS)

	return CFrame.new(previewPosition)
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

function CreateTool.new(): CreateTool
	local self: CreateTool = setmetatable({
		activePreview = nil,
	}, CreateTool)

	return self
end

function CreateTool:destroyActive(): ()
	local preview: PreviewState? = self.activePreview

	if preview == nil then
		return
	end

	preview.renderConnection:Disconnect()
	local ghostInstance: Instance = preview.ghost :: any

	ghostInstance:Destroy()
	self.activePreview = nil
end

function CreateTool:updateActiveCFrame(): ()
	local preview: PreviewState? = self.activePreview

	if preview == nil then
		return
	end

	if preview.tool.Parent == nil then
		self:destroyActive()
		return
	end

	local targetTranslation: CFrame? = getPreviewTargetCFrame()

	if targetTranslation == nil then
		return
	end

	preview.ghost:PivotTo(targetTranslation * preview.rotation)
end

function CreateTool:createForTool(tool: Tool): ()
	self:destroyActive()

	local blockKey: number? = tool:GetAttribute(TOOLS.CREATE.BLOCK_ATTRIBUTE_NAME) :: number?

	if blockKey == nil then
		error("[CreateTool] Missing block attribute on create tool")
	end

	local blockDefinition: any = BLOCKS[blockKey]

	if blockDefinition == nil then
		error("[CreateTool] Missing block definition for block key")
	end

	local sourceModel: Instance? = blockDefinition.MODEL

	if sourceModel == nil then
		error("[CreateTool] Block definition is missing MODEL")
	end

	local ghostInstance: Instance = sourceModel:Clone()

	if not ghostInstance:IsA("Model") and not ghostInstance:IsA("BasePart") then
		ghostInstance:Destroy()
		error("[CreateTool] Block model clone must be Model or BasePart")
	end

	setGhostVisuals(ghostInstance)
	ghostInstance.Parent = Workspace

	local ghost: PVInstance = ghostInstance :: any
	local currentPivot: CFrame = ghost:GetPivot()
	local rotationOnly: CFrame = currentPivot.Rotation
	local renderConnection: RBXScriptConnection = RunService.RenderStepped:Connect(function(): ()
		self:updateActiveCFrame()
	end)

	self.activePreview = {
		tool = tool,
		ghost = ghost,
		rotation = rotationOnly,
		renderConnection = renderConnection,
	}

	self:updateActiveCFrame()
end

function CreateTool:clearForTool(tool: Tool): ()
	local preview: PreviewState? = self.activePreview

	if preview == nil then
		return
	end

	if preview.tool ~= tool then
		return
	end

	self:destroyActive()
end

return CreateTool
