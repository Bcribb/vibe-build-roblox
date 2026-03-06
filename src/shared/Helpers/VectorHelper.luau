--!strict

local VectorHelper : any = {}

function VectorHelper.flattenedUnit(vector: Vector3): Vector3
    return Vector3.new(vector.X, 0, vector.Z).Unit
end

function VectorHelper.angleBetween(vector1: Vector3, vector2: Vector3): number
    return math.acos(vector1:Dot(vector2))
end

function VectorHelper.rotateAboutAxis(vector: Vector3, axis: Vector3, angle: number): Vector3
    local rotationCFrame = CFrame.fromAxisAngle(axis, angle)
    local newVector = rotationCFrame * vector

    return newVector
end

return VectorHelper