extends EnemyAction
class_name ActionMoveSteps

@export var steps: int = 1

func run(enemy, duration: float) -> Status:
	var result: StepResult = enemy.try_step(enemy.facing, duration)
	enemy.last_step_result = result
	
	if result.outcome != enemy.Outcome.PROCEED:
		return Status.INTERRUPTED
	
	enemy.action_counter += 1
	if enemy.action_counter >= steps:
		return Status.COMPLETED
	
	return Status.RUNNING
