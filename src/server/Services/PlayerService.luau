--!strict

local Players: Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage: ServerStorage = game:GetService("ServerStorage")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local serverFolder: Instance = ServerStorage:WaitForChild("Server")
local servicesFolder: Instance = serverFolder:WaitForChild("Services")

local COLLISION_GROUP_CONSTANTS: any = require(constantsFolder:WaitForChild("CollisionGroupConstants"))
local HURTBOX_CONSTANTS: any = require(constantsFolder:WaitForChild("HurtboxConstants"))
local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))

local HurtboxService: any = require(servicesFolder:WaitForChild("HurtboxService"))

local PlayerService: any = {}

local function hasDeleteToolInBackpack(backpack: Instance): boolean
	for _, child: Instance in backpack:GetChildren() do
		if not child:IsA("Tool") then
			continue
		end

		local tool: Tool = child
		local toolType: string? = tool:GetAttribute(TOOLS.DELETE.TOOL_TYPE_ATTRIBUTE_NAME) :: string?

		if toolType == TOOLS.DELETE.TYPE then
			return true
		end
	end

	return false
end

local function grantDeleteTool(player: Player): ()
	local backpack: Instance = player:WaitForChild("Backpack")

	if hasDeleteToolInBackpack(backpack) then
		return
	end

	local toolInstance: Tool = TOOLS.DELETE.TOOL:Clone()
	toolInstance.Name = TOOLS.DELETE.NAME
	toolInstance:SetAttribute(TOOLS.DELETE.TOOL_TYPE_ATTRIBUTE_NAME, TOOLS.DELETE.TYPE)
	toolInstance.Parent = backpack
end

local function setCollisionGroup(character: Model): ()
	for _, descendant: Instance in character:GetDescendants() do
		if not descendant:IsA("BasePart") then
			continue
		end

		descendant.CollisionGroup = COLLISION_GROUP_CONSTANTS.PLAYERS_COLLISION_GROUP
	end
end

local function createHurtbox(character: Model): ()
	HurtboxService.createForModel(character, HURTBOX_CONSTANTS.PLAYER_HURTBOX_SIZE)
end

local function onCharacterAdded(character: Model): ()
	grantDeleteTool(Players:GetPlayerFromCharacter(character))
	setCollisionGroup(character)
	createHurtbox(character)
end

local function watchPlayer(player: Player): ()
	player.CharacterAdded:Connect(onCharacterAdded)

	if player.Character then
		onCharacterAdded(player.Character)
	end
end

function PlayerService.init(): ()
end

function PlayerService.start(): ()
	Players.PlayerAdded:Connect(function(player: Player): ()
		watchPlayer(player)
	end)

	for _, player: Player in Players:GetPlayers() do
		watchPlayer(player)
	end
end

return PlayerService
