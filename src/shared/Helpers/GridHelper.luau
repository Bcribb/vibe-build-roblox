--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local constantsFolder: Instance = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Constants")

local GRID: any = require(constantsFolder:WaitForChild("Grid"))

local GridHelper : any = {}

function GridHelper.positionToGrid(position: Vector3): Vector3
    local gridWidth: number = GRID.GRID_WIDTH
    local gridPosition: Vector3 = Vector3.new(
        math.floor(position.X / gridWidth),
        math.floor(position.Y / gridWidth),
        math.floor(position.Z / gridWidth)
    )

    return gridPosition
end

function GridHelper.gridToPosition(gridPosition: Vector3): Vector3
    local gridWidth: number = GRID.GRID_WIDTH
    local position: Vector3 = Vector3.new(
        gridPosition.X * gridWidth,
        gridPosition.Y * gridWidth,
        gridPosition.Z * gridWidth
    )

    return position
end

function GridHelper.alignPositionToGrid(position: Vector3): Vector3
    local gridWidth: number = GRID.GRID_WIDTH
    local gridPosition: Vector3 = Vector3.new(
        math.floor(position.X / gridWidth) * gridWidth,
        math.floor(position.Y / gridWidth) * gridWidth,
        math.floor(position.Z / gridWidth) * gridWidth
    )
    
    return gridPosition
end

return GridHelper