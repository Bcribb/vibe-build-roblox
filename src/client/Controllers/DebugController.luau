--!strict

local CollectionService: CollectionService = game:GetService("CollectionService")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService: TextChatService = game:GetService("TextChatService")

local sharedFolder: Instance = ReplicatedStorage:WaitForChild("Shared")
local constantsFolder: Instance = sharedFolder:WaitForChild("Constants")

local HURTBOX_CONSTANTS: any = require(constantsFolder:WaitForChild("HurtboxConstants"))

local enableDebugCommand: TextChatCommand = TextChatService:WaitForChild("EnableDebug") :: TextChatCommand
local disableDebugCommand: TextChatCommand = TextChatService:WaitForChild("DisableDebug") :: TextChatCommand
local showHurtboxCommand: TextChatCommand = TextChatService:WaitForChild("ShowHurtbox") :: TextChatCommand

local DebugController: any = {}

DebugController.showHurtbox = false

function DebugController.getShowHurtbox(): boolean
	local showHurtbox: boolean = DebugController.showHurtbox

	return showHurtbox
end

function DebugController.setShowHurtbox(enabled: boolean): nil
	DebugController.showHurtbox = enabled

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

local function setAllDebugFlags(enabled: boolean): nil
	DebugController.setShowHurtbox(enabled)

	return nil
end

function DebugController.start(): nil
	enableDebugCommand.Triggered:Connect(function(_textSource: TextSource, _unfilteredText: string)
		setAllDebugFlags(true)
	end)

	disableDebugCommand.Triggered:Connect(function(_textSource: TextSource, _unfilteredText: string)
		setAllDebugFlags(false)
	end)

	showHurtboxCommand.Triggered:Connect(function(_textSource: TextSource, _unfilteredText: string)
		local enabled: boolean = not DebugController.getShowHurtbox()

		DebugController.setShowHurtbox(enabled)
	end)

	return nil
end

return DebugController
