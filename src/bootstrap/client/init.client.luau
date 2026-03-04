--!strict

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local clientFolder: Instance = ReplicatedStorage:WaitForChild("Client")
local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local helpersFolder: Instance = sharedFolder:WaitForChild("Helpers")

local BootstrapLoader: any = require(helpersFolder:WaitForChild("BootstrapLoader"))

local controllersFolder: Instance = clientFolder:WaitForChild("Controllers")
local sharedSystemsFolder: Instance = sharedFolder:WaitForChild("SharedSystems")

BootstrapLoader.run({ controllersFolder, sharedSystemsFolder })
