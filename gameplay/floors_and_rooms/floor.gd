extends Node2D

# Nodes


# Vars
@export var active_room: Node2D

func _ready():
	Gameplay.current_floor = self
	active_room.is_active = true
	Gameplay.protag = Gameplay.PROTAG_NODE.instantiate()
	Gameplay.protag.global_position = Vector2(120, 120)
	add_child(Gameplay.protag)
