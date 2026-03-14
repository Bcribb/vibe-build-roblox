--!strict

local ServerStorage: ServerStorage = game:GetService("ServerStorage")

local serverFolder: Instance = ServerStorage:WaitForChild("Server")
local servicesFolder: Instance = serverFolder:WaitForChild("Services")

local GoalService: any = require(servicesFolder:WaitForChild("GoalService"))
local BlockService: any = require(servicesFolder:WaitForChild("BlockService"))
local PlayerService: any = require(servicesFolder:WaitForChild("PlayerService"))

local RoundService: any = {}

local function onGoalHitSignal(player: Player): ()
	BlockService.destroyAllBlocks()
	PlayerService.resetAllPlayers()
end

function RoundService.start(): ()
	GoalService.goalHitSignal:Connect(onGoalHitSignal)
end

return RoundService