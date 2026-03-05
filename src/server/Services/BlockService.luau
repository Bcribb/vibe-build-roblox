--!strict

local CollectionService: CollectionService = game:GetService("CollectionService")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace: Workspace = game:GetService("Workspace")

local packagesFolder: Instance = ReplicatedStorage:WaitForChild("Packages")
local remotesFolder: Folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local Comm: any = require(packagesFolder:WaitForChild("Comm"))
local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))
local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))

local BlockService: any = {}
local blockServerComm: any = nil

local function getBlocksFolder(): Folder
	local blocksFolder: Instance? = Workspace:FindFirstChild("Blocks")

	if blocksFolder ~= nil then
		return blocksFolder :: Folder
	end

	local newBlocksFolder: Folder = Instance.new("Folder")
	newBlocksFolder.Name = "Blocks"
	newBlocksFolder.Parent = Workspace

	return newBlocksFolder
end

local function ensurePrimaryPart(model: Model): ()
	if model.PrimaryPart ~= nil then
		return
	end

	for _, descendant: Instance in model:GetDescendants() do
		if not descendant:IsA("BasePart") then
			continue
		end

		model.PrimaryPart = descendant
		return
	end
end

local function validateDestroyModel(_player: Player, args: { any }): (boolean, ...any)
	local modelArgument: any = args[1]

	if typeof(modelArgument) ~= "Instance" then
		return false
	end

	if not modelArgument:IsA("Model") then
		return false
	end

	local targetModel: Model = modelArgument
	local blocksFolder: Folder = getBlocksFolder()

	if not targetModel:IsDescendantOf(blocksFolder) then
		return false
	end

	return true
end

function BlockService.spawnBlock(blockDefinitionNumber: number, position: Vector3): Model
	local blockDefinition: BLOCKS.BlockDefinition = BLOCKS[blockDefinitionNumber]
	local blockModelTemplate: Model = blockDefinition.MODEL :: Model
	local blockModel: Model = blockModelTemplate:Clone()
	local blocksFolder: Folder = getBlocksFolder()

	ensurePrimaryPart(blockModel)
	blockModel.Parent = blocksFolder
	blockModel:PivotTo(CFrame.new(position))
	CollectionService:AddTag(blockModel, TOOLS.CREATE.CREATED_MODEL_TAG)

	return blockModel
end

function BlockService.destroyBlock(model: Model): ()
	model:Destroy()
end

function BlockService.init(): ()
	if blockServerComm ~= nil then
		return
	end

	blockServerComm = Comm.ServerComm.new(remotesFolder, "BlockService")

	blockServerComm:BindFunction("SpawnBlock", function(_player: Player, blockDefinitionNumber: number, position: Vector3): Model
		return BlockService.spawnBlock(blockDefinitionNumber, position)
	end)
	blockServerComm:BindFunction("DestroyBlock", function(_player: Player, model: Model): ()
		BlockService.destroyBlock(model)
	end, { validateDestroyModel })
end

function BlockService.start(): ()
end

return BlockService
