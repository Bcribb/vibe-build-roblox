--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService: TweenService = game:GetService("TweenService")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")

local GROW: any = require(constantsFolder:WaitForChild("Grow"))
local BlockHelper: any = require(helpersFolder:WaitForChild("BlockHelper"))

local GrowController: any = {}

local growTweenInfo: TweenInfo = TweenInfo.new(
	GROW.TWEEN_TIME_SECONDS,
	GROW.TWEEN_EASING_STYLE,
	GROW.TWEEN_EASING_DIRECTION
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

function GrowController.init(): ()
end

function GrowController.start(): ()
	local blocksFolder: Folder = BlockHelper.getBlocksFolder()

	blocksFolder.DescendantAdded:Connect(onBlocksDescendantAdded)
end

return GrowController
