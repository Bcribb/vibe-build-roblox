--!strict

local CollectionService: CollectionService = game:GetService("CollectionService")
local Players: Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace: Workspace = game:GetService("Workspace")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local TOOL_PROVIDER: any = require(constantsFolder:WaitForChild("ToolProvider"))

local ToolProviderService: any = {}

local overlapParams: OverlapParams = OverlapParams.new()

local function pollProviderTouches(): ()
	local providerParts: { Instance } = CollectionService:GetTagged(TOOL_PROVIDER.PROVIDER_TAG)

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

			print(player.Name)
		end
	end
end

function ToolProviderService.init(): ()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {}
end

function ToolProviderService.start(): ()
	task.spawn(function(): ()
		while true do
			pollProviderTouches()
			task.wait(TOOL_PROVIDER.POLL_INTERVAL_SECONDS)
		end
	end)
end

return ToolProviderService
