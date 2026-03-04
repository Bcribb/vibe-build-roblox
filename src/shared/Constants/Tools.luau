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
}

export type ToolsConstants = {
	DELETE: ToolConstants,
	CREATE: CreateToolConstants,
}

local TOOLS: ToolsConstants = {
	DELETE = {
		NAME = "Delete",
		TYPE = "delete",
		TOOL_TYPE_ATTRIBUTE_NAME = "ToolType",
		TOOL = toolsFolder:WaitForChild("Delete"),
	},
	CREATE = {
		NAME = "Create",
		TYPE = "create",
		TOOL_TYPE_ATTRIBUTE_NAME = "ToolType",
		TOOL = toolsFolder:WaitForChild("Create"),
		BLOCK_ATTRIBUTE_NAME = "BlockType",
	},
}

return TOOLS