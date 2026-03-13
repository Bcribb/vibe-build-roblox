--!strict

local Players: Players = game:GetService("Players")
local UserInputService: UserInputService = game:GetService("UserInputService")
local Workspace: Workspace = game:GetService("Workspace")

local DEFAULT_MAX_DISTANCE: number = 1000

local RaycastHelper: any = {}

function RaycastHelper.raycastFromMouse(
	excludedInstances: { Instance }?,
	maxDistance: number?,
	collisionGroup: string?
): RaycastResult?
	local localPlayer: Player = Players.LocalPlayer
	local character: Model? = localPlayer.Character
	local camera: Camera? = Workspace.CurrentCamera

	if character == nil or camera == nil then
		return nil
	end

	local mouseLocation: Vector2 = UserInputService:GetMouseLocation()
	local mouseRay: Ray = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local usedMaxDistance: number = maxDistance or DEFAULT_MAX_DISTANCE
	local filterInstances: { Instance } = { character }

	if excludedInstances ~= nil then
		for _, instance: Instance in excludedInstances do
			table.insert(filterInstances, instance)
		end
	end

	local raycastParams: RaycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterInstances

	if collisionGroup ~= nil then
		raycastParams.CollisionGroup = collisionGroup
	end

	return Workspace:Raycast(mouseRay.Origin, mouseRay.Direction * usedMaxDistance, raycastParams)
end

return RaycastHelper
