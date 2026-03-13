--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService: RunService = game:GetService("RunService")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local BLOCK_CONSTANTS: any = require(constantsFolder:WaitForChild("BlockConstants"))
local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))

local isServer: boolean = RunService:IsServer()

local Block: any = {}
Block.__index = Block

function Block.new(blockDefinitionNumber: number): any
	local self: any = setmetatable({
		blockDefinitionNumber = blockDefinitionNumber,
	}, Block)

	if isServer then
		local definition: BLOCKS.BlockDefinition = BLOCKS.BLOCK_DEFINITIONS[blockDefinitionNumber]
		local model: Model = definition.MODEL:Clone()
		self:setModel(model)
	end

	return self
end

function Block.fromModel(model: Model): any
	local blockDefinitionNumber: number = model:GetAttribute(BLOCK_CONSTANTS.BLOCK_DEFINITION_ATTRIBUTE)
	local block: any = Block.new(blockDefinitionNumber)
	block:setModel(model)

	return block
end

function Block:getDefinition(): BLOCKS.BlockDefinition
	return BLOCKS.BLOCK_DEFINITIONS[self.blockDefinitionNumber]
end

function Block:setModel(model: Model): ()
	self.model = model

	if not model.PrimaryPart then
		error("[Block] Missing primary part for model: " .. model.Name)
	end

	self.bounds = model.PrimaryPart
end

return Block
