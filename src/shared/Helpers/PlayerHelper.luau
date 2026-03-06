--!strict

local PlayerHelper : any = {}

function PlayerHelper.getHumanoidRootPart(player: Player): BasePart?
	local character: Model? = player.Character

	if character == nil then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

function PlayerHelper.isPlayerAlive(player: Player): boolean
	local character: Model? = player.Character

	if character == nil then
		return false
	end

	local humanoid: Humanoid? = character:FindFirstChildOfClass("Humanoid")

	if humanoid == nil then
		return false
	end

	return humanoid.Health > 0 and humanoid:GetState() ~= Enum.HumanoidStateType.Dead
end

return PlayerHelper