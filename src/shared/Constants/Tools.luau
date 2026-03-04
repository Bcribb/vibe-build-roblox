--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local assetsFolder: Instance = ReplicatedStorage:WaitForChild("Assets")
local toolsFolder: Instance = assetsFolder:WaitForChild("Tools")

export type ToolConstants = {
	NAME: string,
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
		TOOL = toolsFolder:WaitForChild("Delete"),
	},
	CREATE = {
		NAME = "Create",
		TOOL = toolsFolder:WaitForChild("Create"),
		BLOCK_ATTRIBUTE_NAME = "BlockType",
	},
}

return TOOLS