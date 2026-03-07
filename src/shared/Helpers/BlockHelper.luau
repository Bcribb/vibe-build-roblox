--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService: CollectionService = game:GetService("CollectionService")
local Workspace: Workspace = game:GetService("Workspace")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))
local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))
local PlayerHelper: any = require(helpersFolder:WaitForChild("PlayerHelper"))

type BlockDefinition = BLOCKS.BlockDefinition
type CloneableBlockInstance = Model | BasePart

local BlockHelper: any = {}

local function getBoundsForPlacement(target: PVInstance): (CFrame, Vector3)
	if target:IsA("BasePart") then
		local targetPart: BasePart = target

		return targetPart.CFrame, targetPart.Size
	end

	local targetModel: Model = target :: Model

	return targetModel:GetBoundingBox()
end

function BlockHelper.getBlocksFolder(): Folder
	local blocksFolder: Instance = Workspace:WaitForChild("Blocks")

	return blocksFolder :: Folder
end

function BlockHelper.createBlockInstance(blockDefinitionNumber: number): CloneableBlockInstance?
	local blockDefinition: BlockDefinition? = BLOCKS.BLOCK_DEFINITIONS[blockDefinitionNumber]

	if blockDefinition == nil then
		error("[BlockHelper] Missing block definition for block definition number: ", blockDefinitionNumber)
	end

	return blockDefinition.MODEL:Clone() :: CloneableBlockInstance
end

function BlockHelper.getNormalOffsetDistance(target: PVInstance, normal: Vector3): number
	local boundsCFrame: CFrame, boundsSize: Vector3 = getBoundsForPlacement(target)
	local rightVector: Vector3 = boundsCFrame.RightVector
	local upVector: Vector3 = boundsCFrame.UpVector
	local lookVector: Vector3 = boundsCFrame.LookVector
	local projectedHalfExtent: number = (
		math.abs(normal:Dot(rightVector)) * boundsSize.X
		+ math.abs(normal:Dot(upVector)) * boundsSize.Y
		+ math.abs(normal:Dot(lookVector)) * boundsSize.Z
	) * 0.5

	return projectedHalfExtent
end

function BlockHelper.applyNormalOffset(
	target: PVInstance,
	targetPosition: Vector3,
	hitNormal: Vector3
): Vector3
	local normalOffsetDistance: number = BlockHelper.getNormalOffsetDistance(target, hitNormal)

	return targetPosition + (hitNormal * normalOffsetDistance)
end

function BlockHelper.clampPositionFromOrigin(
	origin: Vector3,
	targetPosition: Vector3,
	maxDistance: number
): Vector3
	local offset: Vector3 = targetPosition - origin
	local offsetMagnitude: number = offset.Magnitude

	if offsetMagnitude <= maxDistance then
		return targetPosition
	end

	return origin + (offset.Unit * maxDistance)
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

function BlockHelper.validateDelete(player: Player, target: Instance): boolean
	if not target:IsA("Model") then
		return false
	end

	if not CollectionService:HasTag(target, TOOLS.CREATE.CREATED_MODEL_TAG) then
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

return BlockHelper
