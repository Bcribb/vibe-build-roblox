--!strict

local CollectionService: CollectionService = game:GetService("CollectionService")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local COLLISION_GROUP_CONSTANTS: any = require(constantsFolder:WaitForChild("CollisionGroupConstants"))
local HURTBOX_CONSTANTS: any = require(constantsFolder:WaitForChild("HurtboxConstants"))

local HurtboxService: any = {}

local function validateModel(modelInput: any): Model
	if typeof(modelInput) ~= "Instance" or not modelInput:IsA("Model") then
		error("HurtboxService.createForModel expected model to be a Model", 3)
	end

	local primaryPart: BasePart? = modelInput.PrimaryPart

	if primaryPart == nil then
		error("HurtboxService.createForModel expected model.PrimaryPart to exist", 2)
	end

	return modelInput
end

local function validateSize(sizeInput: any): Vector3
	if typeof(sizeInput) ~= "Vector3" then
		error("HurtboxService.createForModel expected size to be a Vector3", 3)
	end

	return sizeInput
end

function HurtboxService.createForModel(modelInput: any, sizeInput: any): Part
	local model: Model = validateModel(modelInput)
	local size: Vector3 = validateSize(sizeInput)
	local primaryPart: BasePart = model.PrimaryPart :: BasePart
	local hurtboxCFrame: CFrame = primaryPart.CFrame
	local humanoid: Humanoid? = model:FindFirstChildOfClass("Humanoid")

	if humanoid ~= nil then
		local offsetY: number = (size.Y / 2) - humanoid.HipHeight - (primaryPart.Size.Y / 2)
		hurtboxCFrame = primaryPart.CFrame + Vector3.new(0, offsetY, 0)
	end

	local hurtbox: Part = Instance.new("Part")
	hurtbox.Name = "Hurtbox"
	hurtbox.Size = size
	hurtbox.CFrame = hurtboxCFrame
	hurtbox.CanCollide = false
	hurtbox.CanTouch = false
	hurtbox.CanQuery = true
	hurtbox.Massless = true
	hurtbox.Anchored = false
	hurtbox.Transparency = 1
	hurtbox.Color = HURTBOX_CONSTANTS.HURTBOX_COLOR
	hurtbox.Parent = model
	hurtbox.CollisionGroup = COLLISION_GROUP_CONSTANTS.HURTBOX_COLLISION_GROUP

	CollectionService:AddTag(hurtbox, HURTBOX_CONSTANTS.HURTBOX_TAG)

	local weldConstraint: WeldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = primaryPart
	weldConstraint.Part1 = hurtbox
	weldConstraint.Parent = hurtbox

	return hurtbox
end

return HurtboxService
