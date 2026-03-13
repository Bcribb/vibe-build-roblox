--!strict

local CollectionService: CollectionService = game:GetService("CollectionService")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService: RunService = game:GetService("RunService")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")

local BLOCK_CONSTANTS: any = require(constantsFolder:WaitForChild("BlockConstants"))
local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))
local BlockHelper: any = require(helpersFolder:WaitForChild("BlockHelper"))

local isServer: boolean = RunService:IsServer()

local Block: any = {}
Block.__index = Block

function Block.new(blockDefinitionNumber: number): any
	local self: any = setmetatable({
		blockDefinitionNumber = blockDefinitionNumber,
	}, Block)

	if isServer then
		self:initialiseModel(blockDefinitionNumber)
	end

	return self
end

function Block.fromModel(model: Model): any
	local blockDefinitionNumber: number = model:GetAttribute(BLOCK_CONSTANTS.BLOCK_DEFINITION_ATTRIBUTE)
	local block: any = setmetatable({
		blockDefinitionNumber = blockDefinitionNumber,
	}, Block)
	block:setModel(model)

	return block
end

function Block:initialiseModel(blockDefinitionNumber: number): ()
	local definition: BLOCKS.BlockDefinition = BLOCKS.BLOCK_DEFINITIONS[blockDefinitionNumber]
	local model: Model = definition.MODEL:Clone()
	local blocksFolder: Folder = BlockHelper.ensureBlocksFolder()

	self:setModel(model)

	model.Parent = blocksFolder
	CollectionService:AddTag(model, BLOCK_CONSTANTS.BLOCK_TAG)
	model:SetAttribute(BLOCK_CONSTANTS.BLOCK_DEFINITION_ATTRIBUTE, blockDefinitionNumber)
end

function Block:applyPlacementRotation(position: Vector3, rotation: number): ()
	local angleRadians: number = BLOCK_CONSTANTS.PLACEMENT_ROTATION_ANGLES[rotation]

	self.model:PivotTo(CFrame.new(position) * CFrame.Angles(0, angleRadians, 0))
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

function Block:destroy(): ()
	self.model:Destroy()
end

return Block
