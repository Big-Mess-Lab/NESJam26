extends EnemyAction
class_name ActionTurnRandom

@export var avoid_blocked: bool = true
@export var avoid_current: bool = true

func run(enemy, duration: float) -> Status:
	var choices: Array = []
	
	for d in Dir.ALL:
		if avoid_current and d == enemy.facing:
			continue
		if avoid_blocked and _is_blocked(enemy, d):
			continue
		choices.append(d)
	
	# Fallback in case nothing gets picked
	if choices.is_empty():
		print("WARNING: ", self, " blocked on all directions, picked random direction.")
		choices = Dir.ALL.duplicate()
	
	enemy._update_facing(choices.pick_random())
	return Status.COMPLETED

func _is_blocked(enemy, dir: Vector2i) -> bool:
	for r in enemy.room.get_cell_contents(enemy.current_cell + dir):
		if r.entity == enemy:
			continue
		if enemy.blocks(r.entity):
			return true
	
	return false
