--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))
local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))

type BlockDefinition = BLOCKS.BlockDefinition
type CloneableBlockInstance = Model | BasePart

local CreateToolHelper: any = {}

local function getValidationError(message: string): (nil, string)
	return nil, message
end

local function getCloneableBlockInstance(instanceValue: Instance): CloneableBlockInstance?
	if instanceValue:IsA("Model") then
		return instanceValue
	end

	if instanceValue:IsA("BasePart") then
		return instanceValue
	end

	return nil
end

function CreateToolHelper.tryGetBlockDefinitionNumberFromTool(tool: Tool): (number?, string?)
	local blockDefinitionNumberValue: any = tool:GetAttribute(TOOLS.CREATE.BLOCK_ATTRIBUTE_NAME)

	if type(blockDefinitionNumberValue) ~= "number" then
		return getValidationError("[CreateToolHelper] Missing or invalid block attribute on create tool")
	end

	return blockDefinitionNumberValue, nil
end

function CreateToolHelper.tryGetBlockDefinition(blockDefinitionNumber: number): (BlockDefinition?, string?)
	local blockDefinition: BlockDefinition? = BLOCKS[blockDefinitionNumber]

	if blockDefinition == nil then
		return getValidationError("[CreateToolHelper] Missing block definition for block key")
	end

	return blockDefinition, nil
end

function CreateToolHelper.tryGetBlockModel(blockDefinitionNumber: number): (CloneableBlockInstance?, string?)
	local blockDefinition: BlockDefinition?, blockDefinitionError: string? =
		CreateToolHelper.tryGetBlockDefinition(blockDefinitionNumber)

	if blockDefinition == nil then
		return nil, blockDefinitionError
	end

	local sourceModel: Instance? = blockDefinition.MODEL

	if sourceModel == nil then
		return getValidationError("[CreateToolHelper] Block definition is missing MODEL")
	end

	local cloneableBlockInstance: CloneableBlockInstance? = getCloneableBlockInstance(sourceModel)

	if cloneableBlockInstance == nil then
		return getValidationError("[CreateToolHelper] Block model must be Model or BasePart")
	end

	return cloneableBlockInstance, nil
end

function CreateToolHelper.tryCreateBlockInstance(blockDefinitionNumber: number): (CloneableBlockInstance?, string?)
	local sourceModel: CloneableBlockInstance?, sourceModelError: string? =
		CreateToolHelper.tryGetBlockModel(blockDefinitionNumber)

	if sourceModel == nil then
		return nil, sourceModelError
	end

	local blockInstance: Instance = sourceModel:Clone()
	local cloneableBlockInstance: CloneableBlockInstance? = getCloneableBlockInstance(blockInstance)

	if cloneableBlockInstance == nil then
		blockInstance:Destroy()
		return getValidationError("[CreateToolHelper] Block model clone must be Model or BasePart")
	end

	return cloneableBlockInstance, nil
end

function CreateToolHelper.mustCreateBlockInstance(blockDefinitionNumber: number): CloneableBlockInstance
	local blockInstance: CloneableBlockInstance?, blockInstanceError: string? =
		CreateToolHelper.tryCreateBlockInstance(blockDefinitionNumber)

	if blockInstance == nil then
		error(blockInstanceError)
	end

	return blockInstance
end

return CreateToolHelper
