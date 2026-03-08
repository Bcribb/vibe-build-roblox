--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local classesFolder: Instance = sharedFolder:WaitForChild("Classes")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local BLOCK_CONSTANTS: any = require(constantsFolder:WaitForChild("BlockConstants"))

local Block: any = require(classesFolder:WaitForChild("Block"))

local BouncyCube: any = {}
BouncyCube.__index = BouncyCube
setmetatable(BouncyCube, { __index = Block })

function BouncyCube.new(blockDefinitionNumber: number): any
	local self: any = setmetatable(Block.new(blockDefinitionNumber), BouncyCube)

    print("BouncyCubeMade!")

	return self
end

function BouncyCube.fromModel(model: Model): any
	local bouncyCube: any = BouncyCube.new(model:GetAttribute(BLOCK_CONSTANTS.BLOCK_DEFINITION_ATTRIBUTE) :: number)
	bouncyCube:setModel(model)

	return bouncyCube
end

return BouncyCube
