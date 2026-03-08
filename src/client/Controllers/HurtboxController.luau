--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService: RunService = game:GetService("RunService")
local Players: Players = game:GetService("Players")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local clientFolder: Instance = ReplicatedStorage:WaitForChild("Client")

local TRIGGERBOX_CONSTANTS: any = require(constantsFolder:WaitForChild("TriggerboxConstants"))

local HurtboxHelper: any = require(sharedFolder:WaitForChild("Helpers"):WaitForChild("HurtboxHelper"))
local BlockHelper: any = require(sharedFolder:WaitForChild("Helpers"):WaitForChild("BlockHelper"))

local BlockController: any = require(clientFolder:WaitForChild("Controllers"):WaitForChild("BlockController"))

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
        local block: Model? = BlockHelper.findFirstBlockAncestor(part)

        if block then
            BlockController.blocks[block]:onTriggered(Players.LocalPlayer)
        end
    end
end

function HurtboxController.start(): ()
    RunService.RenderStepped:Connect(onRenderStepped)
end

return HurtboxController