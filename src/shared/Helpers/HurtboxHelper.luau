--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local HURTBOX_CONSTANTS: any = require(constantsFolder:WaitForChild("HurtboxConstants"))

local HurtboxHelper: any = {}

function HurtboxHelper.findFirstHurtboxDescendant(instance : Instance): BasePart?
    for _, descendant: Instance in instance:GetDescendants() do
        if descendant:HasTag(HURTBOX_CONSTANTS.HURTBOX_TAG) then
            return descendant :: BasePart
        end
    end

    return nil
end

return HurtboxHelper