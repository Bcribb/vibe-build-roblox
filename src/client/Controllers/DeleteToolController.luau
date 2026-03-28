--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players: Players = game:GetService("Players")
local RunService: RunService = game:GetService("RunService")

local packagesFolder: Instance = ReplicatedStorage:WaitForChild("Packages")
local remotesFolder: Folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
local classesFolder: Instance = ReplicatedStorage:WaitForChild("Client"):WaitForChild("Classes")
local helpersFolder: Instance = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Helpers")
local constantsFolder: Instance = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Constants")

local Comm: any = require(packagesFolder:WaitForChild("Comm"))

local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))
local COLLISION_GROUP_CONSTANTS: any = require(constantsFolder:WaitForChild("CollisionGroupConstants"))

local RaycastHelper: any = require(helpersFolder:WaitForChild("RaycastHelper"))
local BlockHelper: any = require(helpersFolder:WaitForChild("BlockHelper"))
local PlayerHelper: any = require(helpersFolder:WaitForChild("PlayerHelper"))

local DeleteHighlight: any = require(classesFolder:WaitForChild("DeleteHighlight"))

local deleteHighlight : any = DeleteHighlight.new()
local enabled : boolean = false

local blockClientComm: any = Comm.ClientComm.new(remotesFolder, false, "DestroyContract")
local destroyBlockRemote: any = blockClientComm:GetFunction("DestroyBlock")
local targetModel: Model? = nil
local toolActivatedConnection: RBXScriptConnection? = nil
local lastEquippedTool: Tool? = nil

local DeleteToolController: any = {}

local function findEquippedDeleteTool(): Tool?
	local character: Model? = Players.LocalPlayer.Character

	if character == nil or not PlayerHelper.isPlayerAlive(Players.LocalPlayer) then
		return nil
	end

	for _, child: Instance in character:GetChildren() do
		if child:IsA("Tool") then
			local toolType: string? = (child :: Tool):GetAttribute(TOOLS.DELETE.TOOL_TYPE_ATTRIBUTE_NAME) :: string?

			if toolType == TOOLS.DELETE.TYPE then
				return child :: Tool
			end
		end
	end

	return nil
end

local function commitDelete(): ()
	if targetModel and PlayerHelper.isPlayerAlive(Players.LocalPlayer) then
		destroyBlockRemote(targetModel)
	end
end

local function onRenderStepped(): ()
	local tool: Tool? = findEquippedDeleteTool()

	if tool ~= lastEquippedTool then
		if lastEquippedTool ~= nil then
			deleteHighlight:setEnabled(false)
			if toolActivatedConnection then
				toolActivatedConnection:Disconnect()
				toolActivatedConnection = nil
			end

			enabled = false
		end

		lastEquippedTool = tool

		if tool ~= nil then
			deleteHighlight:setEnabled(PlayerHelper.isPlayerAlive(Players.LocalPlayer))
			toolActivatedConnection = tool.Activated:Connect(commitDelete)

			enabled = true
		end
	end

	if not enabled or not PlayerHelper.isPlayerAlive(Players.LocalPlayer) then
		targetModel = nil
		deleteHighlight:setEnabled(false)

		return
	end

	local raycastResult: RaycastResult? = RaycastHelper.raycastFromMouse(
		{ Players.LocalPlayer.Character },
		nil,
		COLLISION_GROUP_CONSTANTS.BOUNDS_QUERY_GROUP
	)

	if raycastResult then
		local model: Model = raycastResult.Instance:FindFirstAncestorOfClass("Model")

		if model and BlockHelper.validateDelete(Players.LocalPlayer, model) then
			targetModel = model
			deleteHighlight:setTargetModel(model)
			deleteHighlight:setEnabled(true)

			return
		end
	end

	deleteHighlight:setEnabled(false)
	targetModel = nil
end

RunService.RenderStepped:Connect(onRenderStepped)

return DeleteToolController