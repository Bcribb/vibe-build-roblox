--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))
local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))

type BlockDefinition = BLOCKS.BlockDefinition
type CloneableBlockInstance = Model | BasePart

local BlockHelper: any = {}

function BlockHelper.getBlockDefinitionNumber(tool: Tool): number?
	local value: any = tool:GetAttribute(TOOLS.CREATE.BLOCK_ATTRIBUTE_NAME)

	if type(value) ~= "number" then
		return nil
	end

	return value
end

function BlockHelper.createBlockInstance(blockDefinitionNumber: number): CloneableBlockInstance?
	local blockDefinition: BlockDefinition? = BLOCKS[blockDefinitionNumber]

	if blockDefinition == nil then
		return nil
	end

	return blockDefinition.MODEL:Clone() :: CloneableBlockInstance
end

return BlockHelper
