--!strict

local Players: Players = game:GetService("Players")

local ToolController: any = {}

local equippedConnections: { [Tool]: RBXScriptConnection } = {}
local observedContainers: { [Instance]: boolean } = {}

local function onToolEquipped(tool: Tool): ()
	print("[ToolController] Equipped", tool.Name)
end

local function connectTool(tool: Tool): ()
	if equippedConnections[tool] ~= nil then
		return
	end

	local equippedConnection: RBXScriptConnection = tool.Equipped:Connect(function(): ()
		onToolEquipped(tool)
	end)
	equippedConnections[tool] = equippedConnection
end

local function watchContainer(container: Instance): ()
	if observedContainers[container] then
		return
	end

	observedContainers[container] = true

	for _, child: Instance in container:GetChildren() do
		if not child:IsA("Tool") then
			continue
		end

		local tool: Tool = child
		connectTool(tool)
	end

	container.ChildAdded:Connect(function(child: Instance): ()
		if not child:IsA("Tool") then
			return
		end

		local tool: Tool = child
		connectTool(tool)
	end)
end

function ToolController.init(): ()
end

function ToolController.start(): ()
	local localPlayer: Player = Players.LocalPlayer
	local backpack: Backpack = localPlayer:WaitForChild("Backpack") :: Backpack

	watchContainer(backpack)

	local character: Model? = localPlayer.Character

	if character ~= nil then
		watchContainer(character)
	end

	localPlayer.CharacterAdded:Connect(function(addedCharacter: Model): ()
		watchContainer(addedCharacter)
	end)
end

return ToolController
