--!strict

local Players: Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local clientFolder: Instance = ReplicatedStorage:WaitForChild("Client")
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local classesFolder: Instance = clientFolder:WaitForChild("Classes")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))

local CreateTool: any = require(classesFolder:WaitForChild("CreateTool"))

local ToolController: any = {}

local createTool: any = CreateTool.new()

local function onToolEquipped(tool: Tool): ()
	local toolType: string? = tool:GetAttribute(TOOLS.CREATE.TOOL_TYPE_ATTRIBUTE_NAME) :: string?

	if toolType ~= TOOLS.CREATE.TYPE then
		createTool:destroyActive()
		return
	end

	createTool:createForTool(tool)
end

local function onToolUnequipped(tool: Tool): ()
	local toolType: string? = tool:GetAttribute(TOOLS.CREATE.TOOL_TYPE_ATTRIBUTE_NAME) :: string?

	if toolType ~= TOOLS.CREATE.TYPE then
		return
	end

	createTool:clearForTool(tool)
end

local function watchCharacter(character: Model): ()
	for _, child: Instance in character:GetChildren() do
		if not child:IsA("Tool") then
			continue
		end

		local tool: Tool = child
		onToolEquipped(tool)
	end

	character.ChildAdded:Connect(function(child: Instance): ()
		if not child:IsA("Tool") then
			return
		end

		local tool: Tool = child
		onToolEquipped(tool)
	end)

	character.ChildRemoved:Connect(function(child: Instance): ()
		if not child:IsA("Tool") then
			return
		end

		local tool: Tool = child
		onToolUnequipped(tool)
	end)
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
		createTool:destroyActive()
		watchCharacter(addedCharacter)
	end)
end

return ToolController
