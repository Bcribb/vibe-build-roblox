--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService: TweenService = game:GetService("TweenService")
local Workspace: Workspace = game:GetService("Workspace")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")

local GROW: any = require(constantsFolder:WaitForChild("Grow"))
local BlockHelper: any = require(helpersFolder:WaitForChild("BlockHelper"))

local GrowController: any = {}
local removingFolder: Folder? = nil

local growTweenInfo: TweenInfo = TweenInfo.new(
	GROW.GROW_TWEEN_TIME_SECONDS,
	GROW.GROW_TWEEN_EASING_STYLE,
	GROW.GROW_TWEEN_EASING_DIRECTION
)
local shrinkTweenInfo: TweenInfo = TweenInfo.new(
	GROW.SHRINK_TWEEN_TIME_SECONDS,
	GROW.SHRINK_TWEEN_EASING_STYLE,
	GROW.SHRINK_TWEEN_EASING_DIRECTION
)

local function growPart(part: BasePart): ()
	local originalSize: Vector3 = part.Size
	part.Size = GROW.INITIAL_SIZE

	local tween: Tween = TweenService:Create(part, growTweenInfo, {
		Size = originalSize,
	})
	tween:Play()
end

local function onBlocksDescendantAdded(descendant: Instance): ()
	if not descendant:IsA("BasePart") then
		return
	end

	local part: BasePart = descendant
	growPart(part)
end

local function ensureRemovingFolder(): Folder
	local existingRemovingFolder: Instance? = Workspace:FindFirstChild("Removing")

	if existingRemovingFolder ~= nil then
		return existingRemovingFolder :: Folder
	end

	local newRemovingFolder: Folder = Instance.new("Folder")
	newRemovingFolder.Name = "Removing"
	newRemovingFolder.Parent = Workspace

	return newRemovingFolder
end

local function onBlocksDescendantRemoving(descendant: Instance): ()
	if not descendant:IsA("BasePart") then
		return
	end

	local removingFolderValue: Folder? = removingFolder

	if removingFolderValue == nil then
		return
	end

	local part: BasePart = descendant
	local removingPart: BasePart = part:Clone()
	removingPart.Parent = removingFolderValue

	local tween: Tween = TweenService:Create(removingPart, shrinkTweenInfo, {
		Size = GROW.INITIAL_SIZE,
	})
	tween.Completed:Once(function(): ()
		removingPart:Destroy()
	end)
	tween:Play()
end

function GrowController.init(): ()
	removingFolder = ensureRemovingFolder()
end

function GrowController.start(): ()
	local blocksFolder: Folder = BlockHelper.getBlocksFolder()

	blocksFolder.DescendantAdded:Connect(onBlocksDescendantAdded)
	blocksFolder.DescendantRemoving:Connect(onBlocksDescendantRemoving)
end

return GrowController
