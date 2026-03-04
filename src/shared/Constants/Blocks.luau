--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local assetsFolder: Instance = ReplicatedStorage:WaitForChild("Assets")
local blocksFolder: Instance = assetsFolder:WaitForChild("Blocks")

export type BlockDefinition = {
	NAME: string,
	MODEL: Instance?,
}

export type BlocksConstants = {
    [number]: BlockDefinition,
}

local BLOCKS: BlocksConstants = {
    [1] = {
        NAME = "Cube",
        MODEL = blocksFolder:WaitForChild("Cube"),
	},
}

return BLOCKS
