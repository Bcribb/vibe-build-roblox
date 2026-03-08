--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService: TweenService = game:GetService("TweenService")
local RunService: RunService = game:GetService("RunService")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local classesFolder: Instance = sharedFolder:WaitForChild("Classes")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local BLOCK_CONSTANTS: any = require(constantsFolder:WaitForChild("BlockConstants"))

local Block: any = require(classesFolder:WaitForChild("Block"))

local BridgeBox: any = {}
BridgeBox.__index = BridgeBox
setmetatable(BridgeBox, { __index = Block })

function BridgeBox.new(blockDefinitionNumber: number): any
	local self: any = setmetatable(Block.new(blockDefinitionNumber), BridgeBox)

    self.lastTriggeredAt = 0
	self.isExtended = false
	self.renderSteppedConnection = RunService.RenderStepped:Connect(
		function(_deltaTime: number): ()
			self:onRenderStepped(_deltaTime)
		end
	)

	return self
end

function BridgeBox.fromModel(model: Model): any
    local bridgeBox: any = BridgeBox.new(model:GetAttribute(BLOCK_CONSTANTS.BLOCK_DEFINITION_ATTRIBUTE) :: number)
	bridgeBox:setModel(model)

	return bridgeBox
end

function BridgeBox:destroy(): ()
	self.renderSteppedConnection:Disconnect()
end

function BridgeBox:setModel(model: Model): ()
	Block.setModel(self, model)

	self.triggerbox = model:FindFirstChild("Triggerbox")
	self.bridge = model:FindFirstChild("Visuals"):FindFirstChild("Bridge")
	self.button = model:FindFirstChild("Visuals"):FindFirstChild("Button")
end

function BridgeBox:extendBridge(): ()
	local originalCFrame: CFrame = self.bounds.CFrame:ToWorldSpace(self:getDefinition().BRIDGE_OFFSET),
	local extendDirection: Vector3 = self.bridge.CFrame.LookVector
	local tweenInfo: TweenInfo = self:getDefinition().EXTENSION_TWEEN_INFO
	local tween: Tween = TweenService:Create(self.bridge, tweenInfo, {
		CFrame = originalCFrame + extendDirection * self:getDefinition().EXTENSION_DISTANCE / 2,
		Size = Vector3.new(
			self:getDefinition().BRIDGE_SIZE.X,
			self:getDefinition().BRIDGE_SIZE.Y,
			self:getDefinition().BRIDGE_SIZE.Z + self:getDefinition().EXTENSION_DISTANCE),
	})

	tween:Play()

	self.isExtended = true
end

function BridgeBox:retractBridge(): ()
	local tweenInfo: TweenInfo = self:getDefinition().EXTENSION_TWEEN_INFO
	local tween: Tween = TweenService:Create(self.bridge, tweenInfo, {
		CFrame = self.bounds.CFrame:ToWorldSpace(self:getDefinition().BRIDGE_OFFSET),
		Size = self:getDefinition().BRIDGE_SIZE,
	})

	tween:Play()

	self.isExtended = false
end

function BridgeBox:onTriggered(_player: Player): ()
    local now: number = workspace:GetServerTimeNow()
    if now - self.lastTriggeredAt < self:getDefinition().COOLDOWN then
        return
    end

    self.lastTriggeredAt = now

	self:extendBridge()
end

function BridgeBox:onRenderStepped(_deltaTime: number): ()
	if self.isExtended then
		local serverTime: number = workspace:GetServerTimeNow()

		if serverTime - self.lastTriggeredAt > self:getDefinition().COOLDOWN then
			self:retractBridge()
		end
	end
end

return BridgeBox
