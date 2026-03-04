--!strict

export type ToolProviderConstants = {
	PROVIDER_TAG: string,
	POLL_INTERVAL_SECONDS: number,
}

local TOOL_PROVIDER: ToolProviderConstants = {
	PROVIDER_TAG = "ToolProvider",
	POLL_INTERVAL_SECONDS = 0.2,
}

return TOOL_PROVIDER
