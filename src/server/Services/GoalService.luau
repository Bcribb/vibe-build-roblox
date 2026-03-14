--!strict

local CollectionService: CollectionService = game:GetService("CollectionService")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService: RunService = game:GetService("RunService")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")
local packagesFolder: Instance = ReplicatedStorage:WaitForChild("Packages")

local GOAL_CONSTANTS : any = require(constantsFolder:WaitForChild("GoalConstants"))

local PlayerHelper : any = require(helpersFolder:WaitForChild("PlayerHelper"))

local Signal: any = require(packagesFolder:WaitForChild("Signal"))

local GoalService = {
    goalHitSignal = Signal.new()
}

local function onHeartbeat(): ()
    local overlapParams: OverlapParams = OverlapParams.new()
    overlapParams.CollisionGroup = GOAL_CONSTANTS.GOAL_QUERY_COLLISION_GROUP

    for _, goal: Instance in CollectionService:GetTagged(GOAL_CONSTANTS.GOAL_TAG) do
        local results: { BasePart } = workspace:GetPartsInPart(goal :: BasePart, overlapParams)

        for _, result: BasePart in results do
            local player: Player? = PlayerHelper.getPlayerFromPart(result)
            
            if player ~= nil then
                GoalService.goalHitSignal:Fire(player)
            end
        end
    end
end

function GoalService.start(): ()
    RunService.Heartbeat:Connect(onHeartbeat)
end

return GoalService