--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")

export type BlockConstants = {
	GRID_WIDTH: number,
	BLOCK_DEFINITION_ATTRIBUTE: string,
	BLOCK_TAG: string,
	BOUNDS_TAG: string,
	ORIGIN_TAG: string,
	ENABLED_TRANSPARENCY: number,
	DISABLED_TRANSPARENCY: number,
	PLACEMENT_ROTATION_ANGLES: { [number]: number },
}

local BLOCK_CONSTANTS: BlockConstants = {
	GRID_WIDTH = 6,
	BLOCK_DEFINITION_ATTRIBUTE = "BlockDefinition",
	BLOCK_TAG = "Block",
	BOUNDS_TAG = "Bounds",
	ORIGIN_TAG = "Origin",
	ENABLED_TRANSPARENCY = 0.7,
	DISABLED_TRANSPARENCY = 1,
	PLACEMENT_ROTATION_ANGLES = {
		[0] = 0,
		[1] = -math.pi / 2,
		[2] = -math.pi,
		[3] = math.pi / 2,
	},
}

return BLOCK_CONSTANTS
