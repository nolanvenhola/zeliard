class_name ZeliardLogicalClock
extends RefCounted

const MASTER_TIMER_HZ: float = 1193182.0 / 0x13B1
const DEFAULT_TIMER_TICKS_PER_STEP: int = 20
const LOGICAL_RATE_HZ: float = MASTER_TIMER_HZ / DEFAULT_TIMER_TICKS_PER_STEP
const LOGICAL_STEP_SECONDS: float = 1.0 / LOGICAL_RATE_HZ

var accumulator_seconds: float = 0.0


func consume_steps(delta_seconds: float) -> int:
	accumulator_seconds += delta_seconds
	var steps: int = 0
	while accumulator_seconds >= LOGICAL_STEP_SECONDS:
		accumulator_seconds -= LOGICAL_STEP_SECONDS
		steps += 1
	return steps


func reset() -> void:
	accumulator_seconds = 0.0
