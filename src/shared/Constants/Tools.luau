--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local assetsFolder: Instance = ReplicatedStorage:WaitForChild("Assets")
local constantsFolder: Instance = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Constants")
local toolsFolder: Instance = assetsFolder:WaitForChild("Tools")

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))

export type ToolType = "create" | "delete"

export type ToolConstants = {
	NAME: string,
	TYPE: ToolType,
	TOOL_TYPE_ATTRIBUTE_NAME: string,
	TOOL: Instance?,
}

export type CreateToolConstants = ToolConstants & {
	PREVIEW_DISTANCE_STUDS: number,
}

export type HighlightDepthMode = Enum.HighlightDepthMode

export type DeleteToolConstants = ToolConstants & {
	MAX_DISTANCE_STUDS: number,
	HIGHLIGHT_FILL_COLOR: Color3,
	HIGHLIGHT_FILL_TRANSPARENCY: number,
	HIGHLIGHT_OUTLINE_COLOR: Color3,
	HIGHLIGHT_OUTLINE_TRANSPARENCY: number,
	HIGHLIGHT_DEPTH_MODE: HighlightDepthMode,
}

export type ToolsConstants = {
	DELETE: DeleteToolConstants,
	CREATE: CreateToolConstants,
}

local TOOLS: ToolsConstants = {
	DELETE = {
		NAME = "Delete",
		TYPE = "delete",
		TOOL_TYPE_ATTRIBUTE_NAME = "ToolType",

		TOOL = toolsFolder:WaitForChild("Delete"),
		MAX_DISTANCE_STUDS = 12,

		HIGHLIGHT_FILL_COLOR = Color3.fromRGB(255, 85, 85),
		HIGHLIGHT_FILL_TRANSPARENCY = 0.7,
		HIGHLIGHT_OUTLINE_COLOR = Color3.fromRGB(255, 0, 0),
		HIGHLIGHT_OUTLINE_TRANSPARENCY = 0,
		HIGHLIGHT_DEPTH_MODE = Enum.HighlightDepthMode.AlwaysOnTop,
	},
	CREATE = {
		NAME = "Create",
		TYPE = "create",
		TOOL_TYPE_ATTRIBUTE_NAME = "ToolType",

		TOOL = toolsFolder:WaitForChild("Create"),
		PREVIEW_DISTANCE_STUDS = BLOCKS.GRID_WIDTH * 1.5,
	},
}

return TOOLS