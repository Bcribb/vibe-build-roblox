--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService: CollectionService = game:GetService("CollectionService")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local classesFolder: Instance = sharedFolder:WaitForChild("Classes")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))

local Block: any = require(classesFolder:WaitForChild("Block"))

local BlockController: any = {
    blocks = {}
}

local function onBlockAdded(model: Model): ()
    local block: any = Block.fromModel(model)

    block:enableDebugVisuals(false)

    BlockController.blocks[model] = block
end

function BlockController.start(): ()
    for _, model: Model in CollectionService:GetTagged(BLOCKS.BLOCK_TAG) do
        onBlockAdded(model)
    end

    CollectionService:GetInstanceAddedSignal(BLOCKS.BLOCK_TAG):Connect(onBlockAdded)
end

return BlockController