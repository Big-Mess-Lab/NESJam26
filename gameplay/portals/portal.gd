extends Node2D

# Exports
@export var destination: Marker2D

# Nodes
@onready var parent_room: Node = get_parent().get_parent()
@onready var parent_floor: Node = parent_room.get_parent()
var destination_room: Node

# Vars
var transitioning: bool = false

# Funcs
func _ready():
	if !destination:
		print("WARNING: No destination set for portal! " + str(self))
		return
	
	destination_room = destination.get_parent().get_parent()

func _process(_delta):
	if !transitioning:
		return
	
	if parent_floor.transition_done:
		_move_player()

func interact():
	_teleport()

func _teleport():
	parent_floor.transition_to_room(destination_room)
	transitioning = true

func _move_player():
	transitioning = false
	parent_floor.transition_done = false
	Gameplay.protag.global_position = destination.global_position
