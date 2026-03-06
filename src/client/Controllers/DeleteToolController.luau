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

local RaycastHelper: any = require(helpersFolder:WaitForChild("RaycastHelper"))
local BlockHelper: any = require(helpersFolder:WaitForChild("BlockHelper"))

local DeleteHighlight: any = require(classesFolder:WaitForChild("DeleteHighlight"))

local deleteHighlight : any = DeleteHighlight.new()
local enabled : boolean = false

local blockClientComm: any = Comm.ClientComm.new(remotesFolder, false, "BlockService")
local destroyBlockRemote: any = blockClientComm:GetFunction("DestroyBlock")
local targetModel: Model? = nil
local toolActivatedConnection: RBXScriptConnection? = nil

local DeleteToolController: any = {}

local function onRenderStepped(): ()
	if not enabled then
		return
	end

	local raycastResult: RaycastResult? = RaycastHelper.raycastFromMouse({ Players.LocalPlayer.Character })

	if raycastResult then
		local model: Model = raycastResult.Instance:FindFirstAncestorOfClass("Model")

		if model and BlockHelper.validateDelete(Players.LocalPlayer, model) then
			targetModel = model
			deleteHighlight:setTargetModel(model)

			return
		end
	end

	deleteHighlight:setEnabled(false)
end

local function commitDelete(): ()
	if targetModel then
		destroyBlockRemote(targetModel)
	end
end

function DeleteToolController.onToolEquipped(tool: Tool): ()
	deleteHighlight:setEnabled(true)
	toolActivatedConnection = tool.Activated:Connect(commitDelete)

	enabled = true
end

function DeleteToolController.onToolUnequipped(): ()
	deleteHighlight:setEnabled(false)
	if toolActivatedConnection then
		toolActivatedConnection:Disconnect()
		toolActivatedConnection = nil
	end

	enabled = false
end

RunService.RenderStepped:Connect(onRenderStepped)

return DeleteToolController