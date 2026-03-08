--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage: ServerStorage = game:GetService("ServerStorage")
local Workspace: Workspace = game:GetService("Workspace")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local serverFolder: Instance = ServerStorage:WaitForChild("Server")
local servicesFolder: Instance = serverFolder:WaitForChild("Services")

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))

local BlockService: any = require(servicesFolder:WaitForChild("BlockService"))

local TestingBlockService: any = {}

local SPACING_MULTIPLIER: number = 2
local ROW_OFFSET_X: number = 24
local BLOCK_HEIGHT_OFFSET: number = BLOCKS.GRID_WIDTH / 2

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

	for blockDefinitionNumber: number, _ in BLOCKS.BLOCK_DEFINITIONS do
		local position: Vector3 = startPosition + Vector3.new((blockDefinitionNumber - 1) * spacing, 0, 0)
		BlockService.spawnBlock(blockDefinitionNumber, position)
	end
end

function TestingBlockService.start(): ()
end

return TestingBlockService
