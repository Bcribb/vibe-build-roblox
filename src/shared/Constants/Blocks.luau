--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")

local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local classesFolder: Instance = sharedFolder:WaitForChild("Classes")
local assetsFolder: Instance = ReplicatedStorage:WaitForChild("Assets")
local blocksFolder: Instance = assetsFolder:WaitForChild("Blocks")

local BLOCK_CONSTANTS: any = require(constantsFolder:WaitForChild("BlockConstants"))
local BouncyCube: any = require(classesFolder:WaitForChild("Blocks"):WaitForChild("BouncyCube"))

export type BlockDefinition = {
	NAME: string,
	MODEL: Instance,
	CLASS: any,
}

export type BlockDefinitions = {
	[number]: BlockDefinition,
}

export type BlocksConstants = {
	GRID_WIDTH: number,
	BLOCK_DEFINITION_ATTRIBUTE: string,
	BLOCK_TAG: string,
	BOUNDS_TAG: string,
	BLOCK_DEFINITIONS: BlockDefinitions,
}

local BLOCKS: BlocksConstants = table.clone(BLOCK_CONSTANTS) :: BlocksConstants
BLOCKS.BLOCK_DEFINITIONS = {
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
		[4] = {
			NAME = "BouncyCube",
			MODEL = blocksFolder:WaitForChild("BouncyCube"),
			CLASS = BouncyCube,
		},
	}

return BLOCKS
