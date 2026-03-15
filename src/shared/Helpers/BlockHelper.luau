--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService: CollectionService = game:GetService("CollectionService")
local RunService: RunService = game:GetService("RunService")
local Workspace: Workspace = game:GetService("Workspace")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))
local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))
local BLOCK_CONSTANTS: any = require(constantsFolder:WaitForChild("BlockConstants"))
local COLLISION_GROUP_CONSTANTS: any = require(constantsFolder:WaitForChild("CollisionGroupConstants"))

local PlayerHelper: any = require(helpersFolder:WaitForChild("PlayerHelper"))

local BlockHelper: any = {}

function BlockHelper.ensureBlocksFolder(): Folder
	local existingBlocksFolder: Instance? = Workspace:FindFirstChild("Blocks")

	if existingBlocksFolder ~= nil then
		return existingBlocksFolder :: Folder
	end

	if RunService:IsServer() then
		local blocksFolder: Folder = Instance.new("Folder")
		blocksFolder.Name = "Blocks"
		blocksFolder.Parent = Workspace

		return blocksFolder
	end

	local blocksFolder: Instance = Workspace:WaitForChild("Blocks")

	return blocksFolder :: Folder
end

function BlockHelper.getBlocksFolder(): Folder
	return BlockHelper.ensureBlocksFolder()
end

function BlockHelper.setGhostVisuals(ghostRoot: Instance): ()
	for _, descendant: Instance in ghostRoot:GetDescendants() do
		if not descendant:IsA("BasePart") then
			continue
		end

		local ghostPart: BasePart = descendant
		ghostPart.Anchored = true
		ghostPart.Massless = true
		ghostPart.CanCollide = false
		ghostPart.CanTouch = false
		ghostPart.CanQuery = false
		ghostPart.Transparency = math.max(ghostPart.Transparency, 0.65)
	end
end

function BlockHelper.validatePlacement(player: Player, blockDefinitionNumber: number, position: Vector3, rotation: number): (boolean, boolean, string?)
	local blockDefinition: BLOCKS.BlockDefinition = BLOCKS.BLOCK_DEFINITIONS[blockDefinitionNumber]
	local model : Model = blockDefinition.MODEL:Clone()
	local bounds: BasePart = model:FindFirstChild("Bounds")

	model:PivotTo(CFrame.new(position) * CFrame.Angles(0, BLOCK_CONSTANTS.PLACEMENT_ROTATION_ANGLES[rotation], 0))

	local overlapParams: OverlapParams = OverlapParams.new()
	overlapParams.CollisionGroup = COLLISION_GROUP_CONSTANTS.PLACEMENT_QUERY_GROUP

	local otherParts: { BasePart } = workspace:GetPartBoundsInBox(bounds.CFrame, bounds.Size * 0.9, overlapParams)

	if #otherParts > 0 then
		return false, false, "Block overlaps with other parts"
	end

	model:Destroy()

	return true, true, nil
end

function BlockHelper.validateDelete(player: Player, target: Instance): boolean
	if not target:IsA("Model") then
		return false
	end

	if not CollectionService:HasTag(target, BLOCKS.BLOCK_TAG) then
		return false
	end

	local hrp : BasePart? = PlayerHelper.getHumanoidRootPart(player)

	if not hrp then
		return false
	end

	if (hrp.CFrame.Position - target.PrimaryPart.Position).Magnitude > TOOLS.DELETE.MAX_DISTANCE_STUDS then
		return false
	end

	return true
end

function BlockHelper.findFirstBlockAncestor(instance: Instance): Model
	if not instance:IsDescendantOf(workspace) then
		error("[BlockHelper] Instance is not a descendant of workspace: ", instance.Name)
	end

	local ancestor: Instance? = instance.Parent

	while ancestor ~= workspace do
		if ancestor:HasTag(BLOCKS.BLOCK_TAG) then
			return ancestor :: Model
		end

		ancestor = ancestor.Parent
	end

	error("[BlockHelper] Missing block ancestor for instance: ", instance.Name)
end

return BlockHelper
