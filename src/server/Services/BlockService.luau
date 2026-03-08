--!strict

local CollectionService: CollectionService = game:GetService("CollectionService")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage: ServerStorage = game:GetService("ServerStorage")
local Workspace: Workspace = game:GetService("Workspace")

local packagesFolder: Instance = ReplicatedStorage:WaitForChild("Packages")
local remotesFolder: Folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")
local serverFolder: Instance = ServerStorage:WaitForChild("Server")
local servicesFolder: Instance = serverFolder:WaitForChild("Services")

local Comm: any = require(packagesFolder:WaitForChild("Comm"))
local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))
local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))
local BlockHelper: any = require(helpersFolder:WaitForChild("BlockHelper"))

local ToolProviderService: any = require(servicesFolder:WaitForChild("ToolProviderService"))

type PlaceableBlockInstance = Model | BasePart

local BlockService: any = {}
local blockServerComm: any = nil

local function ensureBlocksFolder(): Folder
	local existingBlocksFolder: Instance? = Workspace:FindFirstChild("Blocks")

	if existingBlocksFolder ~= nil then
		return existingBlocksFolder :: Folder
	end

	local blocksFolder: Folder = Instance.new("Folder")
	blocksFolder.Name = "Blocks"
	blocksFolder.Parent = Workspace

	return blocksFolder
end

local function validateDestroyModel(player: Player, args: { any }): (boolean, ...any)
	local modelArgument: any = args[1]

	if typeof(modelArgument) ~= "Instance" then
		return false
	end

	if not modelArgument:IsA("Model") then
		return false
	end

	local targetModel: Model = modelArgument
	local blocksFolder: Folder = BlockHelper.getBlocksFolder()

	if not targetModel:IsDescendantOf(blocksFolder) then
		return false
	end

	return BlockHelper.validateDelete(player, targetModel)
end

local function onBlockDefinitionDescendantAdded(descendant: Instance): ()
	if not descendant:HasTag(BLOCKS.BOUNDS_TAG) then
		return
	end

	local bounds: BasePart = descendant
	bounds.Transparency = 1
end

function BlockService.spawnBlock(blockDefinitionNumber: number, position: Vector3): PlaceableBlockInstance?
	local blocksFolder: Folder = BlockHelper.getBlocksFolder()
	local blockInstance: PlaceableBlockInstance? = BlockHelper.createBlockInstance(blockDefinitionNumber)

	blockInstance.Parent = blocksFolder
	local placeableInstance: PVInstance = blockInstance

	placeableInstance:PivotTo(CFrame.new(position))
	CollectionService:AddTag(blockInstance, BLOCKS.BLOCK_TAG)
	blockInstance:SetAttribute(BLOCKS.BLOCK_DEFINITION_ATTRIBUTE, blockDefinitionNumber)

	return blockInstance
end

function BlockService.destroyBlock(model: Model): ()
	model:Destroy()
end

function BlockService.init(): ()
	if blockServerComm ~= nil then
		return
	end

	ensureBlocksFolder()
	blockServerComm = Comm.ServerComm.new(remotesFolder, "BlockService")

	blockServerComm:BindFunction(
		"SpawnBlock",
		function(player: Player, blockDefinitionNumber: number, position: Vector3): PlaceableBlockInstance?
			BlockService.spawnBlock(blockDefinitionNumber, position)

			ToolProviderService.consumeCreateTool(player)

			return true
		end
	)
	blockServerComm:BindFunction("DestroyBlock", function(_player: Player, model: Model): ()
		BlockService.destroyBlock(model)
	end, { validateDestroyModel })

	local blocksDefinitionFolder: Folder = ReplicatedStorage.Assets.Blocks

	for _, descendant: Instance in blocksDefinitionFolder:GetDescendants() do
		onBlockDefinitionDescendantAdded(descendant)
	end
	blocksDefinitionFolder.DescendantAdded:Connect(onBlockDefinitionDescendantAdded)
end

function BlockService.start(): ()
end

return BlockService
