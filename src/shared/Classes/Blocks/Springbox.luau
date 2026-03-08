--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService: TweenService = game:GetService("TweenService")
local Players: Players = game:GetService("Players")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local classesFolder: Instance = sharedFolder:WaitForChild("Classes")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local BLOCK_CONSTANTS: any = require(constantsFolder:WaitForChild("BlockConstants"))
local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))

local Block: any = require(classesFolder:WaitForChild("Block"))

local Springbox: any = {}
Springbox.__index = Springbox
setmetatable(Springbox, { __index = Block })

function Springbox.new(blockDefinitionNumber: number): any
	local self: any = setmetatable(Block.new(blockDefinitionNumber), Springbox)

    self.lastTriggeredAt = 0

	return self
end

function Springbox.fromModel(model: Model): any
    local springbox: any = Springbox.new(model:GetAttribute(BLOCK_CONSTANTS.BLOCK_DEFINITION_ATTRIBUTE) :: number)
	springbox:setModel(model)

	return springbox
end

function Springbox:setModel(model: Model): ()
	Block.setModel(self, model)

	self.triggerbox = model:FindFirstChild("Triggerbox")
    self.spring = model:FindFirstChild("Visuals"):FindFirstChild("Spring")
end

function Springbox:onTriggered(player: Player): ()
    local now: number = workspace:GetServerTimeNow()
    if now - self.lastTriggeredAt < BLOCKS.BLOCK_DEFINITIONS[self.blockDefinitionNumber].COOLDOWN then
        return
    end

    self.lastTriggeredAt = now

	if player == Players.LocalPlayer then
		local hrp : BasePart = player.Character.PrimaryPart
		local direction: Vector3 = self.spring.CFrame.LookVector

		hrp.AssemblyLinearVelocity =  direction * 100
	end
end

BLOCKS.registerBlockClass("Springbox", Springbox)
print(BLOCKS.BLOCK_DEFINITIONS)

return Springbox
