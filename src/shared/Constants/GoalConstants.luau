--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local COLLISION_GROUP_CONSTANTS: any = require(constantsFolder:WaitForChild("CollisionGroupConstants"))

local GoalConstants = {
    GOAL_TAG = "Goal",
    GOAL_QUERY_COLLISION_GROUP = COLLISION_GROUP_CONSTANTS.HURTBOX_QUERY_GROUP,
}

return GoalConstants