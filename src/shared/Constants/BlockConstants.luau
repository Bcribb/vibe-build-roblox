--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")

export type BlockConstants = {
	GRID_WIDTH: number,
	BLOCK_DEFINITION_ATTRIBUTE: string,
	BLOCK_TAG: string,
	BOUNDS_TAG: string,
	ENABLED_TRANSPARENCY: number,
	DISABLED_TRANSPARENCY: number,
}

local BLOCK_CONSTANTS: BlockConstants = {
	GRID_WIDTH = 6,
	BLOCK_DEFINITION_ATTRIBUTE = "BlockDefinition",
	BLOCK_TAG = "Block",
	BOUNDS_TAG = "Bounds",
	ENABLED_TRANSPARENCY = 0.7,
	DISABLED_TRANSPARENCY = 1,
}

return BLOCK_CONSTANTS
