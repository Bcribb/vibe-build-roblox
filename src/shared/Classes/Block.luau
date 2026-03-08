--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local BLOCK_CONSTANTS: any = require(constantsFolder:WaitForChild("BlockConstants"))

local Block: any = {}
Block.__index = Block

function Block.new(blockDefinitionNumber: number): any
	local self: any = setmetatable({
		blockDefinitionNumber = blockDefinitionNumber,
	}, Block)

	return self
end

function Block.fromModel(model: Model): any
	local blockDefinitionNumber: number = model:GetAttribute(BLOCK_CONSTANTS.BLOCK_DEFINITION_ATTRIBUTE)
	local block: any = Block.new(blockDefinitionNumber)
	block:setModel(model)

	return block
end

function Block:setModel(model: Model): ()
	self.model = model

	if not model.PrimaryPart then
		error("[Block] Missing primary part for model: ", model.Name)
	end

	self.bounds = model.PrimaryPart
end

function Block:showBounds(enabled: boolean): ()
	self.model.PrimaryPart.Transparency = if enabled then 0.7 else 1
end

return Block
