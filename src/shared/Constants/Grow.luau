--!strict

export type GrowConstants = {
	INITIAL_SIZE: Vector3,
	TWEEN_TIME_SECONDS: number,
	TWEEN_EASING_STYLE: Enum.EasingStyle,
	TWEEN_EASING_DIRECTION: Enum.EasingDirection,
}

local GROW: GrowConstants = {
	INITIAL_SIZE = Vector3.new(0.1, 0.1, 0.1),
	TWEEN_TIME_SECONDS = 0.5,
	TWEEN_EASING_STYLE = Enum.EasingStyle.Exponential,
	TWEEN_EASING_DIRECTION = Enum.EasingDirection.Out,
}

return GROW
