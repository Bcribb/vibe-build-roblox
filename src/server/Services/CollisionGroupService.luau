--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService: PhysicsService = game:GetService("PhysicsService")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local COLLISION_GROUP_CONSTANTS: any = require(constantsFolder:WaitForChild("CollisionGroupConstants"))

local CollisionGroupService: any = {}

local function initializeCollisionGroups()
	for _, collisionGroupDefinition in COLLISION_GROUP_CONSTANTS.COLLISION_GROUP_DEFINITIONS do
		PhysicsService:RegisterCollisionGroup(collisionGroupDefinition.name)
	end

	for _, collisionGroupDefinition in COLLISION_GROUP_CONSTANTS.COLLISION_GROUP_DEFINITIONS do
		for _, otherCollisionGroupDefinition in COLLISION_GROUP_CONSTANTS.COLLISION_GROUP_DEFINITIONS do
			PhysicsService:CollisionGroupSetCollidable(collisionGroupDefinition.name, otherCollisionGroupDefinition.name, false)
		end

		PhysicsService:CollisionGroupSetCollidable(collisionGroupDefinition.name, COLLISION_GROUP_CONSTANTS.DEFAULT_COLLISION_GROUP, false)
	end

	for _, collisionGroupDefinition in COLLISION_GROUP_CONSTANTS.COLLISION_GROUP_DEFINITIONS do
		for _, collidesWith in collisionGroupDefinition.collidesWith do
			PhysicsService:CollisionGroupSetCollidable(collisionGroupDefinition.name, collidesWith, true)
		end
	end
end

function CollisionGroupService.start()
	initializeCollisionGroups()
end

return CollisionGroupService
