--!strict

local CollectionService: CollectionService = game:GetService("CollectionService")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService: TextChatService = game:GetService("TextChatService")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")
local clientFolder: Instance = ReplicatedStorage:WaitForChild("Client")
local datastorageFolder: Instance = clientFolder:WaitForChild("Datastorage")

local BLOCKS: any = require(constantsFolder:WaitForChild("Blocks"))
local HURTBOX_CONSTANTS: any = require(constantsFolder:WaitForChild("HurtboxConstants"))
local TRIGGERBOX_CONSTANTS: any = require(constantsFolder:WaitForChild("TriggerboxConstants"))

local enableDebugCommand: TextChatCommand = TextChatService:WaitForChild("EnableDebug") :: TextChatCommand
local disableDebugCommand: TextChatCommand = TextChatService:WaitForChild("DisableDebug") :: TextChatCommand
local showHurtboxCommand: TextChatCommand = TextChatService:WaitForChild("ShowHurtbox") :: TextChatCommand
local showBoundsCommand: TextChatCommand = TextChatService:WaitForChild("ShowBounds") :: TextChatCommand
local showOriginCommand: TextChatCommand = TextChatService:WaitForChild("ShowOrigin") :: TextChatCommand
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

	local boundsTransparency: number = BLOCKS.DISABLED_TRANSPARENCY

	if enabled then
		boundsTransparency = BLOCKS.ENABLED_TRANSPARENCY
	end

	local boundsParts: { Instance } = CollectionService:GetTagged(BLOCKS.BOUNDS_TAG)

	for _, taggedInstance in boundsParts do
		local boundsPart: BasePart = taggedInstance :: BasePart
		boundsPart.Transparency = boundsTransparency
	end

	return nil
end

function DebugController.setShowOrigin(enabled: boolean): nil
	DebugDatastorage.showOrigin = enabled

	local originTransparency: number = BLOCKS.DISABLED_TRANSPARENCY

	if enabled then
		originTransparency = BLOCKS.ENABLED_TRANSPARENCY
	end

	local originParts: { Instance } = CollectionService:GetTagged(BLOCKS.ORIGIN_TAG)

	for _, taggedInstance in originParts do
		local originPart: BasePart = taggedInstance :: BasePart
		originPart.Transparency = originTransparency
	end

	return nil
end

function DebugController.start(): nil
	enableDebugCommand.Triggered:Connect(function(_textSource: TextSource, _unfilteredText: string)
		DebugController.setShowHurtbox(true)
		DebugController.setShowBounds(true)
		DebugController.setShowOrigin(true)
		DebugController.setShowTriggerbox(true)
	end)

	disableDebugCommand.Triggered:Connect(function(_textSource: TextSource, _unfilteredText: string)
		DebugController.setShowHurtbox(false)
		DebugController.setShowBounds(false)
		DebugController.setShowOrigin(false)
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

	showOriginCommand.Triggered:Connect(function(_textSource: TextSource, _unfilteredText: string)
		local enabled: boolean = not DebugDatastorage.showOrigin

		DebugController.setShowOrigin(enabled)
	end)

	showTriggerboxCommand.Triggered:Connect(function(_textSource: TextSource, _unfilteredText: string)
		local enabled: boolean = not DebugDatastorage.showTriggerbox

		DebugController.setShowTriggerbox(enabled)
	end)

	CollectionService:GetInstanceAddedSignal(BLOCKS.BOUNDS_TAG):Connect(function(instance: Instance)
		local boundsPart: BasePart = instance :: BasePart
		local boundsTransparency: number = DebugDatastorage.showBounds and BLOCKS.ENABLED_TRANSPARENCY or BLOCKS.DISABLED_TRANSPARENCY
		boundsPart.Transparency = boundsTransparency
	end)

	CollectionService:GetInstanceAddedSignal(BLOCKS.ORIGIN_TAG):Connect(function(instance: Instance)
		local originPart: BasePart = instance :: BasePart
		local originTransparency: number = DebugDatastorage.showOrigin and BLOCKS.ENABLED_TRANSPARENCY or BLOCKS.DISABLED_TRANSPARENCY
		originPart.Transparency = originTransparency
	end)

	CollectionService:GetInstanceAddedSignal(TRIGGERBOX_CONSTANTS.TRIGGERBOX_TAG):Connect(function(instance: Instance)
		local triggerbox: BasePart = instance :: BasePart
		local triggerboxTransparency: number = DebugDatastorage.showTriggerbox and TRIGGERBOX_CONSTANTS.ENABLED_TRANSPARENCY or TRIGGERBOX_CONSTANTS.DISABLED_TRANSPARENCY
		triggerbox.Transparency = triggerboxTransparency
	end)

	CollectionService:GetInstanceAddedSignal(HURTBOX_CONSTANTS.HURTBOX_TAG):Connect(function(instance: Instance)
		local hurtbox: BasePart = instance :: BasePart
		local hurtboxTransparency: number = DebugDatastorage.showHurtbox and HURTBOX_CONSTANTS.ENABLED_TRANSPARENCY or HURTBOX_CONSTANTS.DISABLED_TRANSPARENCY
		hurtbox.Transparency = hurtboxTransparency
	end)

	return nil
end

return DebugController
