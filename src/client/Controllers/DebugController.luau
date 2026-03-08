--!strict

local CollectionService: CollectionService = game:GetService("CollectionService")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService: TextChatService = game:GetService("TextChatService")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local clientFolder: Instance = ReplicatedStorage:WaitForChild("Client")
local datastorageFolder: Instance = clientFolder:WaitForChild("Datastorage")

local HURTBOX_CONSTANTS: any = require(constantsFolder:WaitForChild("HurtboxConstants"))
local TRIGGERBOX_CONSTANTS: any = require(constantsFolder:WaitForChild("TriggerboxConstants"))

local BlockController: any = require(clientFolder:WaitForChild("Controllers"):WaitForChild("BlockController"))

local enableDebugCommand: TextChatCommand = TextChatService:WaitForChild("EnableDebug") :: TextChatCommand
local disableDebugCommand: TextChatCommand = TextChatService:WaitForChild("DisableDebug") :: TextChatCommand
local showHurtboxCommand: TextChatCommand = TextChatService:WaitForChild("ShowHurtbox") :: TextChatCommand
local showBoundsCommand: TextChatCommand = TextChatService:WaitForChild("ShowBounds") :: TextChatCommand
local showTriggerboxCommand: TextChatCommand = TextChatService:WaitForChild("ShowTriggerbox") :: TextChatCommand

local DebugDatastorage: any = require(datastorageFolder:WaitForChild("DebugDatastorage"))

local DebugController: any = {}

function DebugController.setShowHurtbox(enabled: boolean): nil
	DebugDatastorage.showHurtbox = enabled

	local hurtboxTransparency: number = HURTBOX_CONSTANTS.DISABLED_TRANSPARENCY

	if enabled then
		hurtboxTransparency = HURTBOX_CONSTANTS.ENABLED_TRANSPARENCY
	end

	local hurtboxes: { Instance } = CollectionService:GetTagged(HURTBOX_CONSTANTS.HURTBOX_TAG)

	for _, taggedInstance in hurtboxes do
		local hurtbox: BasePart = taggedInstance :: BasePart
		hurtbox.Transparency = hurtboxTransparency
	end

	return nil
end

function DebugController.setShowTriggerbox(enabled: boolean): nil
	DebugDatastorage.showTriggerbox = enabled

	local triggerboxTransparency: number = TRIGGERBOX_CONSTANTS.DISABLED_TRANSPARENCY

	if enabled then
		triggerboxTransparency = TRIGGERBOX_CONSTANTS.ENABLED_TRANSPARENCY
	end

	local triggerboxes: { Instance } = CollectionService:GetTagged(TRIGGERBOX_CONSTANTS.TRIGGERBOX_TAG)

	for _, taggedInstance in triggerboxes do
		local triggerbox: BasePart = taggedInstance :: BasePart
		triggerbox.Transparency = triggerboxTransparency
	end

	return nil
end

function DebugController.setShowBounds(enabled: boolean): nil
	DebugDatastorage.showBounds = enabled

	for _, block: any in BlockController.blocks do
		block:showBounds(enabled)
	end

	return nil
end

function DebugController.start(): nil
	enableDebugCommand.Triggered:Connect(function(_textSource: TextSource, _unfilteredText: string)
		DebugController.setShowHurtbox(true)
		DebugController.setShowBounds(true)
		DebugController.setShowTriggerbox(true)
	end)

	disableDebugCommand.Triggered:Connect(function(_textSource: TextSource, _unfilteredText: string)
		DebugController.setShowHurtbox(false)
		DebugController.setShowBounds(false)
		DebugController.setShowTriggerbox(false)
	end)

	showHurtboxCommand.Triggered:Connect(function(_textSource: TextSource, _unfilteredText: string)
		local enabled: boolean = not DebugDatastorage.showHurtbox

		DebugController.setShowHurtbox(enabled)
	end)

	showBoundsCommand.Triggered:Connect(function(_textSource: TextSource, _unfilteredText: string)
		local enabled: boolean = not DebugDatastorage.showBounds

		DebugController.setShowBounds(enabled)
	end)

	showTriggerboxCommand.Triggered:Connect(function(_textSource: TextSource, _unfilteredText: string)
		local enabled: boolean = not DebugDatastorage.showTriggerbox

		DebugController.setShowTriggerbox(enabled)
	end)

	return nil
end

return DebugController
