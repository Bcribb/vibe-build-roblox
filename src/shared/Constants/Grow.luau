--!strict

export type GrowConstants = {
	INITIAL_SIZE: Vector3,
	GROW_TWEEN_TIME_SECONDS: number,
	GROW_TWEEN_EASING_STYLE: Enum.EasingStyle,
	GROW_TWEEN_EASING_DIRECTION: Enum.EasingDirection,
	SHRINK_TWEEN_TIME_SECONDS: number,
	SHRINK_TWEEN_EASING_STYLE: Enum.EasingStyle,
	SHRINK_TWEEN_EASING_DIRECTION: Enum.EasingDirection,
}

local GROW: GrowConstants = {
	INITIAL_SIZE = Vector3.new(0.1, 0.1, 0.1),

	GROW_TWEEN_TIME_SECONDS = 0.5,
	GROW_TWEEN_EASING_STYLE = Enum.EasingStyle.Exponential,
	GROW_TWEEN_EASING_DIRECTION = Enum.EasingDirection.Out,

	SHRINK_TWEEN_TIME_SECONDS = 0.5,
	SHRINK_TWEEN_EASING_STYLE = Enum.EasingStyle.Exponential,
	SHRINK_TWEEN_EASING_DIRECTION = Enum.EasingDirection.In,
}

return GROW
