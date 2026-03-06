--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder: Folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
local packagesFolder: Instance = ReplicatedStorage:WaitForChild("Packages")
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local Comm: any = require(packagesFolder:WaitForChild("Comm"))

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))

local BlockHelper: any = require(sharedFolder:WaitForChild("Helpers"):WaitForChild("BlockHelper"))

local blockClientComm: any = Comm.ClientComm.new(remotesFolder, false, "BlockService")
local spawnBlockRemote: any = blockClientComm:GetFunction("SpawnBlock")

local BlockGhost: any = {}
BlockGhost.__index = BlockGhost

function BlockGhost.new(blockDefinitionNumber: number): any
    if BLOCKS[blockDefinitionNumber] == nil then
        error("[BlockGhost] Missing block definition for block definition number: ", blockDefinitionNumber)
    end

    local self : any = setmetatable({
		blockDefinitionNumber = blockDefinitionNumber,
	}, BlockGhost)

    self:initModel()

	return self
end

function BlockGhost:initModel(): ()
    local blockDefinition: BLOCKS.BlockDefinition = BLOCKS[self.blockDefinitionNumber]

    local model: Model = blockDefinition.MODEL:Clone()

    BlockHelper.setGhostVisuals(model)

    self.model = model
end

function BlockGhost:destroy(): ()
	self.model:Destroy()
end

function BlockGhost:getBlockDefinitionNumber(): number
	return self.blockDefinitionNumber
end

function BlockGhost:setVisible(isVisible: boolean): ()
	if isVisible then
		self.model.Parent = workspace
	else
		self.model.Parent = nil
	end
end

function BlockGhost:setPosition(position: Vector3): ()
	self.model:PivotTo(CFrame.new(position))
end

function BlockGhost:commit(): ()
	spawnBlockRemote(self.blockDefinitionNumber, self.model:FindFirstChildOfClass("Part").CFrame.Position)
end

return BlockGhost