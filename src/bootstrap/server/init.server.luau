--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage: ServerStorage = game:GetService("ServerStorage")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")
local EXPERIENCE: any = require(sharedFolder:WaitForChild("Constants"):WaitForChild("Experience"))

local BootstrapLoader: any = require(helpersFolder:WaitForChild("BootstrapLoader"))

local serverFolder: Instance = ServerStorage:WaitForChild("Server")
local foldersToLoad: { Instance } = {
	serverFolder:WaitForChild("Services"),
	sharedFolder:WaitForChild("SharedSystems"),
}

if game.PlaceId == EXPERIENCE.GYM_PLACE_ID then
	local testFolder: Instance = ServerStorage:WaitForChild("Test")
	local replicatedTestFolder: Instance = ReplicatedStorage:WaitForChild("Test")
	table.insert(foldersToLoad, testFolder:WaitForChild("Services"))
	table.insert(foldersToLoad, replicatedTestFolder:WaitForChild("Shared"):WaitForChild("SharedSystems"))
end

BootstrapLoader.run(foldersToLoad)
