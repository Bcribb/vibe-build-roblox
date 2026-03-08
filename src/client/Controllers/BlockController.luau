--!strict

local CollectionService: CollectionService = game:GetService("CollectionService")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local packagesFolder: Instance = ReplicatedStorage:WaitForChild("Packages")
local remotesFolder: Folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local classesFolder: Instance = sharedFolder:WaitForChild("Classes")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local blocksClasses: Instance = classesFolder:WaitForChild("Blocks")

local Comm: any = require(packagesFolder:WaitForChild("Comm"))

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))

local Block: any = require(classesFolder:WaitForChild("Block"))

local blockClientComm: any = Comm.ClientComm.new(remotesFolder, false, "BlockService")
local blockTriggeredSignal: any = blockClientComm:GetSignal("BlockTriggered")

local BlockController: any = {
	blocks = {}
}

local function onBlockAdded(model: Model): ()
    local blockDefinitionNumber: number = model:GetAttribute(BLOCKS.BLOCK_DEFINITION_ATTRIBUTE) :: number
    local definition: BLOCKS.BlockDefinition = BLOCKS.BLOCK_DEFINITIONS[blockDefinitionNumber]
    local block: any = nil

    if definition.CLASS then
        block = definition.CLASS.fromModel(model)
    else
        block = Block.fromModel(model)
    end

    BlockController.blocks[model] = block
end

function BlockController.notifyServerBlockTriggered(blockModel: Model): ()
	blockTriggeredSignal:Fire(blockModel)
end

local function onBlockTriggeredSignal(player: Player, blockModel: Model): ()
	local block: any? = BlockController.blocks[blockModel]

	if not block then
		return
	end

	if type(block.onTriggered) == "function" then
		block:onTriggered(player)
	end
end

function BlockController.init(): ()
	for _, block: ModuleScript in blocksClasses:GetChildren() do
		require(block)
	end
end

function BlockController.start(): ()
	for _, model: Model in CollectionService:GetTagged(BLOCKS.BLOCK_TAG) do
		onBlockAdded(model)
	end

	CollectionService:GetInstanceAddedSignal(BLOCKS.BLOCK_TAG):Connect(onBlockAdded)

	blockTriggeredSignal:Connect(onBlockTriggeredSignal)
end

return BlockController