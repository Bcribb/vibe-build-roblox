--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))

local Block: any = {}
Block.__index = Block

function Block.new(blockDefinitionNumber: number): any
	local self: any = setmetatable({
		blockDefinitionNumber = blockDefinitionNumber,
	}, Block)

	return self
end

function Block.fromModel(model: Model): any
	local blockDefinitionNumber: number = model:GetAttribute(BLOCKS.BLOCK_DEFINITION_ATTRIBUTE)
	local block: any = Block.new(blockDefinitionNumber)
	block:setModel(model)

	return block
end

function Block:setModel(model: Model): ()
	self.model = model
end

function Block:enableDebugVisuals(enabled: boolean): ()
	self.model.PrimaryPart.Transparency = if enabled then 0.7 else 1
end

return Block
