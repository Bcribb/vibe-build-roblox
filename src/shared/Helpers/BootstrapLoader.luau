--!strict

export type BootstrapModule = {
	init: (() -> ())?,
	start: (() -> ())?,
}

local BootstrapLoader: any = {}

local function appendModulesFromFolder(folder: Instance, loadedModules: { BootstrapModule })
	local moduleScripts: { ModuleScript } = {}

	for _, child in folder:GetChildren() do
		if child:IsA("ModuleScript") then
			table.insert(moduleScripts, child)
		end
	end

	table.sort(moduleScripts, function(a: ModuleScript, b: ModuleScript): boolean
		return a.Name < b.Name
	end)

	for _, moduleScript in moduleScripts do
		local loadedModule: BootstrapModule = require(moduleScript) :: BootstrapModule
		table.insert(loadedModules, loadedModule)
	end
end

local function runPhase(loadedModules: { BootstrapModule }, methodName: "init" | "start")
	for _, loadedModule in loadedModules do
		local method: (() -> ())? = loadedModule[methodName]

		if method ~= nil then
			method()
		end
	end
end

function BootstrapLoader.run(folders: { Instance })
	local loadedModules: { BootstrapModule } = {}

	for _, folder in folders do
		appendModulesFromFolder(folder, loadedModules)
	end

	runPhase(loadedModules, "init")
	runPhase(loadedModules, "start")
end

return BootstrapLoader
