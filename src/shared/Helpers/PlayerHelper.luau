--!strict

local PlayerHelper : any = {}

function PlayerHelper.getHumanoidRootPart(player: Player): BasePart?
	local character: Model? = player.Character

	if character == nil then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

return PlayerHelper