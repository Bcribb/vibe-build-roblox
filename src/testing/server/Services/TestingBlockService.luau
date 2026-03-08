--!strict

local CollectionService: CollectionService = game:GetService("CollectionService")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage: ServerStorage = game:GetService("ServerStorage")
local Workspace: Workspace = game:GetService("Workspace")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local serverFolder: Instance = ServerStorage:WaitForChild("Server")
local servicesFolder: Instance = serverFolder:WaitForChild("Services")

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))
local TOOL_PROVIDER: any = require(constantsFolder:WaitForChild("ToolProvider"))

local BlockService: any = require(servicesFolder:WaitForChild("BlockService"))

local TestingBlockService: any = {}

local SPACING_MULTIPLIER: number = 2
local ROW_OFFSET_X: number = 24
local BLOCK_HEIGHT_OFFSET: number = BLOCKS.GRID_WIDTH / 2
local TOOL_ROW_OFFSET_Z: number = 2 * BLOCKS.GRID_WIDTH
local ROTATION_COUNT: number = 4

local function ensureTestingToolProvidersFolder(): Folder
	local workspace: Instance = Workspace
	local existingFolder: Instance? = workspace:FindFirstChild("TestingToolProviders")

	if existingFolder ~= nil then
		return existingFolder :: Folder
	end

	local folder: Folder = Instance.new("Folder")
	folder.Name = "TestingToolProviders"
	folder.Parent = workspace

	return folder
end

local function getSpawnPosition(): Vector3
	local world: Instance? = Workspace:FindFirstChild("World")
	local spawnLocation: SpawnLocation? = if world then world:FindFirstChildOfClass("SpawnLocation") else nil

	if spawnLocation then
		return spawnLocation.Position
	end

	return Vector3.new(0, 3, 0)
end

function TestingBlockService.init(): ()
	local spawnPosition: Vector3 = getSpawnPosition()
	local spacing: number = SPACING_MULTIPLIER * BLOCKS.GRID_WIDTH
	local startPosition: Vector3 = spawnPosition + Vector3.new(ROW_OFFSET_X, BLOCK_HEIGHT_OFFSET, 0)
	local rotatedBlocksGridOrigin: Vector3 = startPosition - Vector3.new(0, 0, TOOL_ROW_OFFSET_Z + spacing)
	local toolProviderGridOrigin: Vector3 = rotatedBlocksGridOrigin + Vector3.new(ROTATION_COUNT * spacing, 0, 0)

	for blockDefinitionNumber: number, _ in BLOCKS.BLOCK_DEFINITIONS do
		local rowOffsetZ: number = -(blockDefinitionNumber - 1) * spacing

		for rotation: number = 0, ROTATION_COUNT - 1 do
			local columnOffsetX: number = rotation * spacing
			local position: Vector3 = rotatedBlocksGridOrigin + Vector3.new(columnOffsetX, 0, rowOffsetZ)
			BlockService.spawnBlock(blockDefinitionNumber, position, rotation)
		end
	end

	local toolProvidersFolder: Folder = ensureTestingToolProvidersFolder()

	for blockDefinitionNumber: number, blockDefinition: any in BLOCKS.BLOCK_DEFINITIONS do
		local rowOffsetZ: number = -(blockDefinitionNumber - 1) * spacing
		local position: Vector3 = toolProviderGridOrigin + Vector3.new(0, 0, rowOffsetZ)

		local part: Part = Instance.new("Part")
		part.Name = blockDefinition.NAME .. "ToolProvider"
		part.Size = Vector3.new(BLOCKS.GRID_WIDTH, BLOCKS.GRID_WIDTH, BLOCKS.GRID_WIDTH)
		part.Position = position
		part.CanCollide = false
		part.Anchored = true
		part.Material = Enum.Material.SmoothPlastic
		part.Color = Color3.fromRGB(215, 97, 197)
		part.Transparency = 0.8
		part:SetAttribute(BLOCKS.BLOCK_DEFINITION_ATTRIBUTE, blockDefinitionNumber)
		part.Parent = toolProvidersFolder

		local billboardGui: BillboardGui = Instance.new("BillboardGui")
		billboardGui.Name = "Label"
		billboardGui.StudsOffset = Vector3.new(0, BLOCKS.GRID_WIDTH / 2 + 1, 0)
		billboardGui.Size = UDim2.fromOffset(80, 24)
		billboardGui.AlwaysOnTop = true
		billboardGui.Parent = part

		local textLabel: TextLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = blockDefinition.NAME
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.GothamBold
		textLabel.Parent = billboardGui

		CollectionService:AddTag(part, TOOL_PROVIDER.PROVIDER_TAG)
	end
end

function TestingBlockService.start(): ()
end

return TestingBlockService
