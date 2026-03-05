--!strict

local Players: Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local clientFolder: Instance = ReplicatedStorage:WaitForChild("Client")
local controllersFolder: Instance = clientFolder:WaitForChild("Controllers")
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))

local CreateToolController: any = require(controllersFolder:WaitForChild("CreateToolController"))
local DeleteToolController: any = require(controllersFolder:WaitForChild("DeleteToolController"))

local ToolController: any = {}

local function onToolEquipped(tool: Tool): ()
	local toolType: string? = tool:GetAttribute(TOOLS.CREATE.TOOL_TYPE_ATTRIBUTE_NAME) :: string?

	if toolType == TOOLS.CREATE.TYPE then
		DeleteToolController.destroyActive()
		CreateToolController.createForTool(tool)

		return
	end

	if toolType == TOOLS.DELETE.TYPE then
		CreateToolController.destroyActive()
		DeleteToolController.createForTool(tool)

		return
	end

	CreateToolController.destroyActive()
	DeleteToolController.destroyActive()
end

local function onToolUnequipped(tool: Tool): ()
	local toolType: string? = tool:GetAttribute(TOOLS.CREATE.TOOL_TYPE_ATTRIBUTE_NAME) :: string?

	if toolType == TOOLS.CREATE.TYPE then
		CreateToolController.clearForTool(tool)

		return
	end

	if toolType == TOOLS.DELETE.TYPE then
		DeleteToolController.clearForTool(tool)

		return
	end

	CreateToolController.destroyActive()
	DeleteToolController.destroyActive()
end

local function onChildAdded(child: Instance): ()
	if not child:IsA("Tool") then
		return
	end

	local tool: Tool = child
	onToolEquipped(tool)
end

local function onChildRemoved(child: Instance): ()
	if not child:IsA("Tool") then
		return
	end

	local tool: Tool = child
	onToolUnequipped(tool)
end

local function watchCharacter(character: Model): ()
	for _, child: Instance in character:GetChildren() do
		onChildAdded(child)
	end

	character.ChildAdded:Connect(onChildAdded)
	character.ChildRemoved:Connect(onChildRemoved)
end

function ToolController.init(): ()
end

function ToolController.start(): ()
	local localPlayer: Player = Players.LocalPlayer

	local character: Model? = localPlayer.Character

	if character ~= nil then
		watchCharacter(character)
	end

	localPlayer.CharacterAdded:Connect(function(addedCharacter: Model): ()
		CreateToolController.destroyActive()
		DeleteToolController.destroyActive()
		watchCharacter(addedCharacter)
	end)
end

return ToolController
