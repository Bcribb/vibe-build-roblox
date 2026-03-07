--!strict

local CollectionService: CollectionService = game:GetService("CollectionService")
local Players: Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService: RunService = game:GetService("RunService")
local Workspace: Workspace = game:GetService("Workspace")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))
local TOOL_PROVIDER: any = require(constantsFolder:WaitForChild("ToolProvider"))
local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))

local ToolProviderService: any = {}

local overlapParams: OverlapParams = OverlapParams.new()
local heartbeatConnection: RBXScriptConnection? = nil
local elapsedSeconds: number = 0
local pollIntervalSeconds: number = 0
local randomGenerator: Random = Random.new()

local function hasCreateToolInContainer(container: Instance): boolean
	for _, child: Instance in container:GetChildren() do
		if not child:IsA("Tool") then
			continue
		end

		local tool: Tool = child
		local toolType: string? = tool:GetAttribute(TOOLS.CREATE.TOOL_TYPE_ATTRIBUTE_NAME) :: string?

		if toolType == TOOLS.CREATE.TYPE then
			return true
		end
	end

	return false
end

local function playerHasCreateTool(player: Player): boolean
	local backpack: Instance? = player:FindFirstChildOfClass("Backpack")

	if backpack ~= nil and hasCreateToolInContainer(backpack) then
		return true
	end

	local character: Model? = player.Character

	if character ~= nil and hasCreateToolInContainer(character) then
		return true
	end

	return false
end

local function destroyCreateToolsInContainer(container: Instance?): ()
	if container == nil then
		return
	end

	for _, child: Instance in container:GetChildren() do
		if not child:IsA("Tool") then
			continue
		end

		local tool: Tool = child
		local toolType: string? = tool:GetAttribute(TOOLS.CREATE.TOOL_TYPE_ATTRIBUTE_NAME) :: string?

		if toolType ~= TOOLS.CREATE.TYPE then
			continue
		end

		tool:Destroy()
	end
end

local function getRandomBlockKey(): number
	local randomIndex: number = randomGenerator:NextInteger(1, #BLOCKS.BLOCK_DEFINITIONS)

	return randomIndex
end

local function grantCreateTool(player: Player): ()
	local backpack: Instance? = player:FindFirstChildOfClass("Backpack")

	if backpack == nil then
		return
	end

	local tool: TOOLS.CreateToolConstants = TOOLS.CREATE

	local toolInstance: Tool = tool.TOOL:Clone()
	local selectedBlockKey: number = getRandomBlockKey()
	local selectedBlock: BLOCKS.BlockDefinition = BLOCKS.BLOCK_DEFINITIONS[selectedBlockKey]

	toolInstance.Name = selectedBlock.NAME
	toolInstance:SetAttribute(tool.TOOL_TYPE_ATTRIBUTE_NAME, tool.TYPE)
	toolInstance:SetAttribute(BLOCKS.BLOCK_DEFINITION_ATTRIBUTE, selectedBlockKey)
	toolInstance.Parent = backpack
end

local function pollProviderTouches(): ()
	local providerParts: { Instance } = CollectionService:GetTagged(TOOL_PROVIDER.PROVIDER_TAG)
	local processedPlayers: { [Player]: boolean } = {}

	for _, providerInstance: Instance in providerParts do
		if not providerInstance:IsA("BasePart") then
			continue
		end

		local providerPart: BasePart = providerInstance
		local touchingParts: { BasePart } = Workspace:GetPartsInPart(providerPart, overlapParams)

		for _, touchingPart: BasePart in touchingParts do
			local character: Model? = touchingPart:FindFirstAncestorOfClass("Model")

			if character == nil then
				continue
			end

			local player: Player? = Players:GetPlayerFromCharacter(character)

			if player == nil then
				continue
			end

			if processedPlayers[player] then
				continue
			end

			processedPlayers[player] = true

			if playerHasCreateTool(player) then
				continue
			end

			grantCreateTool(player)
		end
	end
end

local function shouldRunPoll(deltaTime: number, pollIntervalSeconds: number): boolean
	elapsedSeconds += deltaTime

	if elapsedSeconds < pollIntervalSeconds then
		return false
	end

	while elapsedSeconds >= pollIntervalSeconds do
		elapsedSeconds -= pollIntervalSeconds
	end

	return true
end

local function onHeartbeat(deltaTime: number): ()
	if not shouldRunPoll(deltaTime, pollIntervalSeconds) then
		return
	end

	pollProviderTouches()
end

function ToolProviderService.init(): ()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {}
end

function ToolProviderService.consumeCreateTool(player: Player): ()
	local backpack: Instance? = player:FindFirstChildOfClass("Backpack")
	local character: Model? = player.Character

	destroyCreateToolsInContainer(backpack)
	destroyCreateToolsInContainer(character)
end

function ToolProviderService.start(): ()
	if heartbeatConnection ~= nil then
		return
	end

	pollIntervalSeconds = TOOL_PROVIDER.POLL_INTERVAL_SECONDS
	heartbeatConnection = RunService.Heartbeat:Connect(onHeartbeat)
end

return ToolProviderService
