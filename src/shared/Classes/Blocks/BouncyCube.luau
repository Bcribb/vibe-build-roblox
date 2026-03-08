--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService: TweenService = game:GetService("TweenService")
local Players: Players = game:GetService("Players")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local classesFolder: Instance = sharedFolder:WaitForChild("Classes")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local BLOCK_CONSTANTS: any = require(constantsFolder:WaitForChild("BlockConstants"))

local Block: any = require(classesFolder:WaitForChild("Block"))

local BouncyCube: any = {}
BouncyCube.__index = BouncyCube
setmetatable(BouncyCube, { __index = Block })

function BouncyCube.new(blockDefinitionNumber: number): any
	local self: any = setmetatable(Block.new(blockDefinitionNumber), BouncyCube)

	return self
end

function BouncyCube.fromModel(model: Model): any
	local bouncyCube: any = BouncyCube.new(model:GetAttribute(BLOCK_CONSTANTS.BLOCK_DEFINITION_ATTRIBUTE) :: number)
	bouncyCube:setModel(model)

	return bouncyCube
end

function BouncyCube:setModel(model: Model): ()
	Block.setModel(self, model)

	self.triggerbox = model:FindFirstChild("Triggerbox")
end

function BouncyCube:onTriggered(player: Player): ()
	if player == Players.LocalPlayer then
		local hrp : BasePart = player.Character.PrimaryPart
		local direction: Vector3 = (hrp.CFrame.Position - self.bounds.Position).Unit

		hrp.AssemblyLinearVelocity =  direction * 100
	end

	local cubePart: BasePart = self.model:FindFirstChild("Visuals"):FindFirstChild("Bouncer")
	cubePart.Size = self.triggerbox.Size

	local originalSize: Vector3 = self.bounds.Size
	local tweenInfo: TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
	local tween: Tween = TweenService:Create(cubePart, tweenInfo, {
		Size = originalSize
	})

	tween:Play()
end

return BouncyCube
