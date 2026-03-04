--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local assetsFolder: Instance = ReplicatedStorage:WaitForChild("Assets")
local toolsFolder: Instance = assetsFolder:WaitForChild("Tools")

export type ToolConstants = {
	NAME: string,
	TOOL: Instance?,
}

export type ToolsConstants = {
	DELETE: ToolConstants,
	CREATE: ToolConstants,
}

local TOOLS: ToolsConstants = {
	DELETE = {
		NAME = "Delete",
		TOOL = toolsFolder:WaitForChild("Delete"),
	},
	CREATE = {
		NAME = "Create",
		TOOL = toolsFolder:WaitForChild("Create"),
	},
}

return TOOLS