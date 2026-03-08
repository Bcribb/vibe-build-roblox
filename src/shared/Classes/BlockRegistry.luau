--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local classesFolder: Instance = sharedFolder:WaitForChild("Classes")
local blocksClassesFolder: Instance = classesFolder:WaitForChild("Blocks")

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))

local BLOCK_CLASS_MODULES: { [string]: Instance } = {
	BouncyCube = blocksClassesFolder:WaitForChild("BouncyCube"),
	BridgeBox = blocksClassesFolder:WaitForChild("BridgeBox"),
}

local classMap: { [number]: any } = {}

for name: string, moduleScript: Instance in BLOCK_CLASS_MODULES do
	local definitionNumber: number = BLOCKS.getDefinitionNumberByName(name)
	classMap[definitionNumber] = require(moduleScript)
end

local BlockRegistry: any = {}

function BlockRegistry.getClass(blockDefinitionNumber: number): any
	local blockClass: any? = classMap[blockDefinitionNumber]

	return blockClass
end

return BlockRegistry
