extends EnemyAction
class_name ActionTurnRelative

enum Rotation {CW, CCW, REVERSE}
@export var rotation: Rotation = Rotation.CW

func run(enemy, duration: float) -> Status:
	var new_dir: Vector2i
	match rotation:
		Rotation.CW:
			new_dir = Dir.rotate_cw(enemy.facing)
		Rotation.CCW:
			new_dir = Dir.rotate_ccw(enemy.facing)
		Rotation.REVERSE:
			new_dir = Dir.reverse(enemy.facing)
	
	enemy._update_facing(new_dir)
	return Status.COMPLETED
