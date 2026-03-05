--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace: Workspace = game:GetService("Workspace")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))

type DeleteHighlightInstance = {
	highlight: Highlight,
}

local DeleteHighlight: any = {}
DeleteHighlight.__index = DeleteHighlight

function DeleteHighlight.new(): DeleteHighlightInstance
	local highlight: Highlight = Instance.new("Highlight")
	highlight.FillColor = TOOLS.DELETE.HIGHLIGHT_FILL_COLOR
	highlight.FillTransparency = TOOLS.DELETE.HIGHLIGHT_FILL_TRANSPARENCY
	highlight.OutlineColor = TOOLS.DELETE.HIGHLIGHT_OUTLINE_COLOR
	highlight.OutlineTransparency = TOOLS.DELETE.HIGHLIGHT_OUTLINE_TRANSPARENCY
	highlight.DepthMode = TOOLS.DELETE.HIGHLIGHT_DEPTH_MODE
	highlight.Enabled = false
	highlight.Parent = Workspace
	local self: DeleteHighlightInstance = setmetatable({
		highlight = highlight,
	}, DeleteHighlight)

	return self
end

function DeleteHighlight.setTargetModel(self: DeleteHighlightInstance, targetModel: Model?): ()
	self.highlight.Adornee = targetModel
end

function DeleteHighlight.setEnabled(self: DeleteHighlightInstance, isEnabled: boolean): ()
	self.highlight.Enabled = isEnabled
end

function DeleteHighlight.destroy(self: DeleteHighlightInstance): ()
	self.highlight:Destroy()
end

return DeleteHighlight
