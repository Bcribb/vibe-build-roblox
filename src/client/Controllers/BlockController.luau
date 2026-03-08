--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService: CollectionService = game:GetService("CollectionService")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local classesFolder: Instance = sharedFolder:WaitForChild("Classes")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local clientFolder: Instance = ReplicatedStorage:WaitForChild("Client")
local datastorageFolder: Instance = clientFolder:WaitForChild("Datastorage")

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))

local DebugDatastorage: any = require(datastorageFolder:WaitForChild("DebugDatastorage"))

local Block: any = require(classesFolder:WaitForChild("Block"))

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

    block:showBounds(DebugDatastorage.showBounds)

    BlockController.blocks[model] = block
end

function BlockController.start(): ()
    for _, model: Model in CollectionService:GetTagged(BLOCKS.BLOCK_TAG) do
        onBlockAdded(model)
    end

    CollectionService:GetInstanceAddedSignal(BLOCKS.BLOCK_TAG):Connect(onBlockAdded)
end

return BlockController