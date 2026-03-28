--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage: ServerStorage = game:GetService("ServerStorage")

local packagesFolder: Instance = ReplicatedStorage:WaitForChild("Packages")
local remotesFolder: Folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local classesFolder: Instance = sharedFolder:WaitForChild("Classes")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")
local serverFolder: Instance = ServerStorage:WaitForChild("Server")
local serverClassesFolder: Instance = serverFolder:WaitForChild("Classes")
local contractsFolder: Instance = serverClassesFolder:WaitForChild("Contracts")
local servicesFolder: Instance = serverFolder:WaitForChild("Services")

local Comm: any = require(packagesFolder:WaitForChild("Comm"))

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))
local COLLISION_GROUP_CONSTANTS: any = require(constantsFolder:WaitForChild("CollisionGroupConstants"))
local TRIGGERBOX_CONSTANTS: any = require(constantsFolder:WaitForChild("TriggerboxConstants"))

local BlockHelper: any = require(helpersFolder:WaitForChild("BlockHelper"))

local BuildContract: any = require(contractsFolder:WaitForChild("BuildContract"))
local DestroyContract: any = require(contractsFolder:WaitForChild("DestroyContract"))

local ToolProviderService: any = require(servicesFolder:WaitForChild("ToolProviderService"))

local Block: any = require(classesFolder:WaitForChild("Block"))

local BlockService: any = {}
local blockServerComm: any = nil
local blocks: { [Model]: any } = {}

local function onBlockDefinitionDescendantAdded(descendant: Instance): ()
	if descendant:HasTag(BLOCKS.BOUNDS_TAG) then
		local bounds: BasePart = descendant
		bounds.CollisionGroup = COLLISION_GROUP_CONSTANTS.BOUNDS_COLLISION_GROUP
		bounds.Transparency = 1
	end

	if descendant:HasTag(TRIGGERBOX_CONSTANTS.TRIGGERBOX_TAG) then
		local triggerbox: BasePart = descendant
		triggerbox.CollisionGroup = COLLISION_GROUP_CONSTANTS.TRIGGERBOX_COLLISION_GROUP
		triggerbox.Transparency = 1
	end
end

function BlockService.spawnBlock(blockDefinitionNumber: number, position: Vector3, rotation: number): Model
	local block: any = Block.new(blockDefinitionNumber)
	block:applyPlacementRotation(position, rotation)
	local model: Model = block.model
	blocks[model] = block

	return model
end

function BlockService.destroyBlock(model: Model): ()
	local block: any? = blocks[model]

	if block == nil then
		return
	end

	blocks[model] = nil
	block:destroy()
end

function BlockService.destroyAllBlocks(): ()
	for _, block: any in blocks do
		block:destroy()
	end

	table.clear(blocks)
end

function BlockService.init(): ()
	BlockService.buildContract = BuildContract.new()
	BlockService.buildContract.buildSignal:Connect(function(player: Player, blockDefinitionNumber: number, position: Vector3, rotation: number): ()
		BlockService.spawnBlock(blockDefinitionNumber, position, rotation)
		ToolProviderService.consumeCreateTool(player)
	end)

	BlockHelper.ensureBlocksFolder()

	BlockService.destroyContract = DestroyContract.new(blocks)
	BlockService.destroyContract.destroySignal:Connect(function(_player: Player, model: Model): ()
		BlockService.destroyBlock(model)
	end)

	blockServerComm = Comm.ServerComm.new(remotesFolder, "BlockService")

	local blockTriggeredSignal: any = blockServerComm:CreateSignal("BlockTriggered")
	blockTriggeredSignal:Connect(function(player: Player, blockModel: any): ()
		if typeof(blockModel) ~= "Instance" or not blockModel:IsA("Model") then
			return
		end

		local blocksFolder: Folder = BlockHelper.getBlocksFolder()

		if not blockModel:IsDescendantOf(blocksFolder) then
			return
		end

		blockTriggeredSignal:FireExcept(player, player, blockModel)
	end)

	local blocksDefinitionFolder: Folder = ReplicatedStorage.Assets.Blocks

	for _, descendant: Instance in blocksDefinitionFolder:GetDescendants() do
		onBlockDefinitionDescendantAdded(descendant)
	end
	blocksDefinitionFolder.DescendantAdded:Connect(onBlockDefinitionDescendantAdded)
end

function BlockService.start(): ()
end

return BlockService
