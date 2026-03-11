--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")

local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local assetsFolder: Instance = ReplicatedStorage:WaitForChild("Assets")
local blocksFolder: Instance = assetsFolder:WaitForChild("Blocks")

local BLOCK_CONSTANTS: any = require(constantsFolder:WaitForChild("BlockConstants"))

export type BlockDefinition = any

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
	},
	[5] = {
		NAME = "BridgeBox",
		MODEL = blocksFolder:WaitForChild("BridgeBox"),
		COOLDOWN = 5,

		BUTTON_OFFSET = (function()
			local model: Model = blocksFolder:WaitForChild("BridgeBox")
			local button: BasePart = model:FindFirstChild("Visuals"):FindFirstChild("Button")
			local bounds: BasePart = model:FindFirstChild("Bounds")
			local offset: CFrame = bounds.CFrame:ToObjectSpace(button.CFrame)

			return offset
		end)(),
		BRIDGE_OFFSET = (function()
			local model: Model = blocksFolder:WaitForChild("BridgeBox")
			local bridge: BasePart = model:FindFirstChild("Visuals"):FindFirstChild("Bridge")
			local bounds: BasePart = model:FindFirstChild("Bounds")
			local offset: CFrame = bounds.CFrame:ToObjectSpace(bridge.CFrame)

			return offset
		end)(),
		BRIDGE_SIZE = blocksFolder:WaitForChild("BridgeBox"):WaitForChild("Visuals"):WaitForChild("Bridge").Size,

		EXTENSION_DISTANCE = BLOCKS.GRID_WIDTH * 3,
		EXTENSION_TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		RETRACTION_TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
	},
}

BLOCKS.getDefinitionNumberByName = function(name: string): number
	for definitionNumber: number, definition: BlockDefinition in BLOCKS.BLOCK_DEFINITIONS do
		if definition.NAME == name then
			return definitionNumber
		end
	end

	error("[Blocks] Missing block definition for name: " .. name)
end

return BLOCKS
