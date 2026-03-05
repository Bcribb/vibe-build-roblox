--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))
local TOOLS: any = require(constantsFolder:WaitForChild("Tools"))

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

function BlockHelper.createBlockInstance(blockDefinitionNumber: number): CloneableBlockInstance?
	local blockDefinition: BlockDefinition? = BLOCKS[blockDefinitionNumber]

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
	if ghostRoot:IsA("BasePart") then
		local ghostPart: BasePart = ghostRoot
		ghostPart.Anchored = true
		ghostPart.Massless = true
		ghostPart.CanCollide = false
		ghostPart.CanTouch = false
		ghostPart.CanQuery = false
		ghostPart.Transparency = math.max(ghostPart.Transparency, 0.65)
	end

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

return BlockHelper
