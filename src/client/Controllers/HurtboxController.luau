--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService: RunService = game:GetService("RunService")
local Players: Players = game:GetService("Players")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local TRIGGERBOX_CONSTANTS: any = require(constantsFolder:WaitForChild("TriggerboxConstants"))

local HurtboxHelper: any = require(sharedFolder:WaitForChild("Helpers"):WaitForChild("HurtboxHelper"))

local HurtboxController: any = {}

local function onRenderStepped(_: number): ()
    local character : Model = Players.LocalPlayer.Character

    if not character then
        return
    end

    local hurtbox: BasePart? = HurtboxHelper.findFirstHurtboxDescendant(character)

    if not hurtbox then
        return
    end

    local parts : { BasePart } = workspace:GetPartsInPart(hurtbox, TRIGGERBOX_CONSTANTS.TRIGGERBOX_OVERLAP_PARAMS)

    for _, part: BasePart in parts do
        print(part.Name)
    end
end

function HurtboxController.start(): ()
    RunService.RenderStepped:Connect(onRenderStepped)
end

return HurtboxController