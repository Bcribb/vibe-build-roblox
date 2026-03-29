--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService: RunService = game:GetService("RunService")
local UserInputService: UserInputService = game:GetService("UserInputService")
local Players: Players = game:GetService("Players")

local remotesFolder: Folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
local packagesFolder: Instance = ReplicatedStorage:WaitForChild("Packages")
local clientFolder: Instance = ReplicatedStorage:WaitForChild("Client")
local classesFolder: Instance = clientFolder:WaitForChild("Classes")
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")

local Comm: any = require(packagesFolder:WaitForChild("Comm"))

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))
local BLOCK_CONSTANTS: any = require(constantsFolder:WaitForChild("BlockConstants"))
local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))

local BlockHelper: any = require(helpersFolder:WaitForChild("BlockHelper"))
local GridHelper: any = require(helpersFolder:WaitForChild("GridHelper"))
local PlayerHelper: any = require(helpersFolder:WaitForChild("PlayerHelper"))
local ShiftLockHelper: any = require(helpersFolder:WaitForChild("ShiftLockHelper"))
local VectorHelper: any = require(helpersFolder:WaitForChild("VectorHelper"))

local buildClientComm: any = Comm.ClientComm.new(remotesFolder, true, "BuildContract")
local buildRemote: any = buildClientComm:GetFunction("Build")

local BlockGhost: any = require(classesFolder:WaitForChild("BlockGhost"))

local enabled: boolean = false
local isAwaitingSpawn: boolean = false
local rotation: number = 0 -- 0..3 representing quarter turns
local blockDefinitionNumber: number? = nil
local blockGhost: any? = nil
local toolActivatedConnection: RBXScriptConnection? = nil
local lastEquippedTool: Tool? = nil

local CreateToolController: any = {}

local function findEquippedCreateTool(): Tool?
	local character: Model? = Players.LocalPlayer.Character

	if character == nil or not PlayerHelper.isPlayerAlive(Players.LocalPlayer) then
		return nil
	end

	for _, child: Instance in character:GetChildren() do
		if child:IsA("Tool") then
			local toolType: string? = (child :: Tool):GetAttribute(TOOLS.CREATE.TOOL_TYPE_ATTRIBUTE_NAME) :: string?

			if toolType == TOOLS.CREATE.TYPE then
				return child :: Tool
			end
		end
	end

	return nil
end

local function getOrCreateBlockGhost(blockDefinitionNumber: number): any
	if blockGhost then
		if blockGhost:getBlockDefinitionNumber() == blockDefinitionNumber then
			return blockGhost
		end

		blockGhost:destroy()
		blockGhost = nil
	end

	return BlockGhost.new(blockDefinitionNumber)
end

local function onToolActivated(): ()
	if not blockGhost or isAwaitingSpawn or not PlayerHelper.isPlayerAlive(Players.LocalPlayer) then
		return
	end

	local ghostPart: BasePart? = blockGhost.model.PrimaryPart :: BasePart

	if ghostPart == nil then
		return
	end

	local position: Vector3 = ghostPart.Position

	if not BlockHelper.validatePlacement(Players.LocalPlayer, blockGhost:getBlockDefinitionNumber(), position, rotation) then
		return
	end

	isAwaitingSpawn = true
	local buildPromise: any = buildRemote(blockGhost:getBlockDefinitionNumber(), position, rotation)

	buildPromise:andThen(function(success: boolean, response: string)
		if not success then
			isAwaitingSpawn = false

			print("Failed to spawn block: ", response)

			return
		end
	end):catch(function(_error: any): ()
		isAwaitingSpawn = false

		print("Failed to spawn block")
	end)
end

local function getPlacementPosition(): Vector3
	local cameraCFrame : CFrame = workspace.CurrentCamera.CFrame
	local cameraLookVector : Vector3 = cameraCFrame.LookVector
	local cameraRightVector : Vector3 = cameraCFrame.RightVector
	local cameraFlattenedLookVector : Vector3 = VectorHelper.flattenedUnit(cameraLookVector)
	local angle : number = cameraFlattenedLookVector:Angle(cameraLookVector, cameraRightVector) + math.pi / 16

	local rotation : number = math.sign(angle) * (math.pi / 2) * ((angle / (math.pi / 2)) ^ 2)

	local direction : Vector3 = VectorHelper.rotateAboutAxis(cameraFlattenedLookVector, cameraRightVector, rotation)
	local offset : Vector3 = direction * TOOLS.CREATE.PREVIEW_DISTANCE_STUDS

	local hrp : BasePart = PlayerHelper.getHumanoidRootPart(Players.LocalPlayer) :: BasePart
	local placementPosition : Vector3 = GridHelper.alignPositionToGrid(hrp.CFrame.Position + offset)

	return placementPosition
end

local function onRenderStepped(): ()
	local tool: Tool? = findEquippedCreateTool()

	if tool ~= lastEquippedTool then
		if lastEquippedTool ~= nil then
			if toolActivatedConnection then
				toolActivatedConnection:Disconnect()
				toolActivatedConnection = nil
			end

			isAwaitingSpawn = false
			enabled = false
			ShiftLockHelper.setForcedShiftLockEnabled(false)
		end

		lastEquippedTool = tool

		if tool ~= nil then
			blockDefinitionNumber = tool:GetAttribute(BLOCKS.BLOCK_DEFINITION_ATTRIBUTE) :: number
			toolActivatedConnection = tool.Activated:Connect(onToolActivated)
			isAwaitingSpawn = false
			enabled = true
			ShiftLockHelper.setForcedShiftLockEnabled(true)
		end
	end

	if not enabled or isAwaitingSpawn or not PlayerHelper.isPlayerAlive(Players.LocalPlayer) then
		if blockGhost then
			blockGhost:setVisible(false)
			blockGhost:destroy()
			blockGhost = nil
		end

		return
	end

	blockGhost = getOrCreateBlockGhost(blockDefinitionNumber :: number)
	blockGhost:setVisible(true)

	local placementPosition: Vector3 = getPlacementPosition()
	local angleRadians: number = BLOCK_CONSTANTS.PLACEMENT_ROTATION_ANGLES[rotation]
	blockGhost:setPosition(placementPosition, angleRadians)
end

local function onInputBegan(input: InputObject, _gameProcessed: boolean): ()
	if input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end

	if input.KeyCode ~= Enum.KeyCode.Q and input.KeyCode ~= Enum.KeyCode.E then
		return
	end

	if findEquippedCreateTool() == nil then
		return
	end

	if input.KeyCode == Enum.KeyCode.E then
		rotation = (rotation + 1) % 4
	elseif input.KeyCode == Enum.KeyCode.Q then
		rotation = (rotation - 1 + 4) % 4
	end
end

UserInputService.InputBegan:Connect(onInputBegan)
RunService.RenderStepped:Connect(onRenderStepped)

return CreateToolController