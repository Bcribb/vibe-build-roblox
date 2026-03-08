--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")
local EXPERIENCE: any = require(sharedFolder:WaitForChild("Constants"):WaitForChild("Experience"))

local BootstrapLoader: any = require(helpersFolder:WaitForChild("BootstrapLoader"))

local clientFolder: Instance = ReplicatedStorage:WaitForChild("Client")
local foldersToLoad: { Instance } = {
	clientFolder:WaitForChild("Controllers"),
	sharedFolder:WaitForChild("SharedSystems"),
}

if game.PlaceId == EXPERIENCE.GYM_PLACE_ID then
	local testFolder: Instance = ReplicatedStorage:WaitForChild("Test")
	table.insert(foldersToLoad, testFolder:WaitForChild("Client"):WaitForChild("Controllers"))
	table.insert(foldersToLoad, testFolder:WaitForChild("Shared"):WaitForChild("SharedSystems"))
end

BootstrapLoader.run(foldersToLoad)
