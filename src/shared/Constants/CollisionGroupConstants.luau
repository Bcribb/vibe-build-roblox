--!strict

export type CollisionGroupDefinition = {
	name: string,
	collidesWith: {string},
}

local PLAYERS_COLLISION_GROUP: string = "PLAYERS_COLLISION_GROUP"
local DEFAULT_COLLISION_GROUP: string = "Default"

local COLLISION_GROUP_DEFINITIONS: { CollisionGroupDefinition } = {
	{
		name = PLAYERS_COLLISION_GROUP,
		collidesWith = {
			DEFAULT_COLLISION_GROUP,
		},
	},
}

return {
	PLAYERS_COLLISION_GROUP = PLAYERS_COLLISION_GROUP,
	DEFAULT_COLLISION_GROUP = DEFAULT_COLLISION_GROUP,
	COLLISION_GROUP_DEFINITIONS = COLLISION_GROUP_DEFINITIONS,
}
