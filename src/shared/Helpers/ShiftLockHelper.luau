--!strict

-- Approximates mouse lock (center lock + hidden cursor) without forked PlayerModule.
-- Does not replicate full Roblox shift lock (camera offset, character yaw vs camera).

local RunService: RunService = game:GetService("RunService")
local UserInputService: UserInputService = game:GetService("UserInputService")

local ShiftLockHelper: any = {}

function ShiftLockHelper.setForcedShiftLockEnabled(enabled: boolean): ()
	if not RunService:IsClient() then
		return
	end

	if enabled then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false
	else
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	end
end

return ShiftLockHelper
