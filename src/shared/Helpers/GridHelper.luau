--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local constantsFolder: Instance = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Constants")

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))

local GridHelper : any = {}

function GridHelper.alignPositionToGrid(position: Vector3): Vector3
    local gridWidth: number = BLOCKS.GRID_WIDTH
    local gridPosition: Vector3 = Vector3.new(
        math.round(position.X / gridWidth) * gridWidth,
        math.round(position.Y / gridWidth) * gridWidth,
        math.round(position.Z / gridWidth) * gridWidth
    )

    return gridPosition
end

return GridHelper