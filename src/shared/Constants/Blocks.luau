--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local assetsFolder: Instance = ReplicatedStorage:WaitForChild("Assets")
local blocksFolder: Instance = assetsFolder:WaitForChild("Blocks")

export type BlockDefinition = {
	NAME: string,
	MODEL: Instance,
}

export type BlockDefinitions = {
	[number]: BlockDefinition,
}

export type BlocksConstants = {
	GRID_WIDTH: number,
	BLOCK_DEFINITION_ATTRIBUTE: string,
	BLOCK_TAG: string,
	BLOCK_DEFINITIONS: BlockDefinitions,
}

local BLOCKS: BlocksConstants = {
	GRID_WIDTH = 6,
	BLOCK_DEFINITION_ATTRIBUTE = "BlockDefinition",

	BLOCK_TAG = "Block",
	BOUNDS_TAG = "Bounds",

	BLOCK_DEFINITIONS = {
		[1] = {
			NAME = "Cube",
			MODEL = blocksFolder:WaitForChild("Cube"),
		},
		[2] = {
			NAME = "Wedge",
			MODEL = blocksFolder:WaitForChild("Wedge"),
		},
		[3] = {
			NAME = "Sphere",
			MODEL = blocksFolder:WaitForChild("Sphere"),
		},
	},
}

return BLOCKS
