extends EnemyAction
class_name ActionTurnTo

@export var target: Dir.Facing = Dir.Facing.DOWN

func run(enemy, duration: float) -> Status:
	enemy._update_facing(Dir.from_facing(target))
	return Status.COMPLETED
