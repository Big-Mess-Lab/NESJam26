extends EnemyAction
class_name ActionMoveUntilWall


func run(enemy, duration: float) -> Status:
	var result: StepResult = enemy.try_step(enemy.facing, duration)
	enemy.last_step_result = result
	
	if result.outcome != enemy.Outcome.PROCEED:
		return Status.INTERRUPTED
	
	return Status.RUNNING
