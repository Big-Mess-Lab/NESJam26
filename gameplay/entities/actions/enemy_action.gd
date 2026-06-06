extends Resource
class_name EnemyAction

enum Status {RUNNING, COMPLETED, INTERRUPTED}

@export var interrupt_sequence_if_blocked: bool = false

@warning_ignore("unused_parameter")
func run(enemy, duration: float) -> Status:
	return Status.COMPLETED # needs per-action override
