--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local assetsFolder: Instance = ReplicatedStorage:WaitForChild("Assets")
local toolsFolder: Instance = assetsFolder:WaitForChild("Tools")

export type ToolType = "create" | "delete"

export type ToolConstants = {
	NAME: string,
	TYPE: ToolType,
	TOOL_TYPE_ATTRIBUTE_NAME: string,
	TOOL: Instance?,
}

export type CreateToolConstants = ToolConstants & {
	BLOCK_ATTRIBUTE_NAME: string,
	CREATED_MODEL_TAG: string,
	PREVIEW_DISTANCE_STUDS: number,
}

export type HighlightDepthMode = "AlwaysOnTop" | "Occluded"

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
		HIGHLIGHT_DEPTH_MODE = "AlwaysOnTop",
	},
	CREATE = {
		NAME = "Create",
		TYPE = "create",
		TOOL_TYPE_ATTRIBUTE_NAME = "ToolType",
		TOOL = toolsFolder:WaitForChild("Create"),
		BLOCK_ATTRIBUTE_NAME = "BlockType",
		CREATED_MODEL_TAG = "BuiltModel",
		PREVIEW_DISTANCE_STUDS = 8,
	},
}

return TOOLS