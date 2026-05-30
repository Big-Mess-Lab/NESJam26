extends Node2D

# Exports
enum Direction {UP, DOWN, LEFT, RIGHT, ALL}
@export var destination: Marker2D
## Direction protag must face to interact with this object
@export var interact_direction: Direction

# Funcs
func _ready():
	if !destination:
		print("WARNING: No destination set for portal! " + str(self))
	if !interact_direction:
		print("WARNING: No interact direction set for portal! " + str(self))

func interact():
	if !interact_direction == 5:
		if Gameplay.protag.current_facing == interact_direction:
			_teleport()
	else:
		_teleport()

func _teleport():
	print("Teleported!")
