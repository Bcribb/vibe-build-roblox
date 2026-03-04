--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage: ServerStorage = game:GetService("ServerStorage")

local serverFolder: Instance = ServerStorage:WaitForChild("Server")
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")

local BootstrapLoader: any = require(helpersFolder:WaitForChild("BootstrapLoader"))

local servicesFolder: Instance = serverFolder:WaitForChild("Services")
local sharedSystemsFolder: Instance = sharedFolder:WaitForChild("SharedSystems")

BootstrapLoader.run({ servicesFolder, sharedSystemsFolder })
