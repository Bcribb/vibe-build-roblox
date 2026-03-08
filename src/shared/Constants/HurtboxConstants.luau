--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local COLLISION_GROUP_CONSTANTS: any = require(constantsFolder:WaitForChild("CollisionGroupConstants"))

local HURTBOX_CONSTANTS: { [string]: any } = {
	HURTBOX_TAG = "Hurtbox",
	HURTBOX_COLLISION_GROUP = COLLISION_GROUP_CONSTANTS.HURTBOX_COLLISION_GROUP,
	PLAYER_HURTBOX_SIZE = Vector3.new(2, 4, 1),
	DEBOUNCE_SECONDS = 0.5,

	HURTBOX_COLOR = Color3.fromRGB(0, 255, 0),
	ENABLED_TRANSPARENCY = 0.7,
	DISABLED_TRANSPARENCY = 1,
}

return HURTBOX_CONSTANTS