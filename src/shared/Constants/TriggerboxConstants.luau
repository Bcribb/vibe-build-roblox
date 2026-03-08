--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local COLLISION_GROUP_CONSTANTS: any = require(constantsFolder:WaitForChild("CollisionGroupConstants"))

local triggerboxOverlapParams: OverlapParams = OverlapParams.new()
triggerboxOverlapParams.CollisionGroup = COLLISION_GROUP_CONSTANTS.TRIGGERBOX_QUERY_GROUP

local TRIGGERBOX_CONSTANTS: { [string]: any } = {
	TRIGGERBOX_TAG = "Triggerbox",
    TRIGGERBOX_OVERLAP_PARAMS = triggerboxOverlapParams,
}

return TRIGGERBOX_CONSTANTS