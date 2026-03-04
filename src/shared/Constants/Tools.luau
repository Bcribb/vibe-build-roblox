--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local assetsFolder: Instance = ReplicatedStorage:WaitForChild("Assets")
local toolsFolder: Instance = assetsFolder:WaitForChild("Tools")

export type ToolConstants = {
	NAME: string,
	MODEL: Instance?,
}

export type ToolsConstants = {
	DELETE: ToolConstants,
	CUBE: ToolConstants,
}

local TOOLS: ToolsConstants = {
	DELETE = {
		NAME = "Delete",
		MODEL = nil,
	},
	CUBE = {
		NAME = "Cube",
		MODEL = toolsFolder:WaitForChild("Cube"),
	},
}

return TOOLS