extends Node2D

# Exports
@export var destination: Marker2D

# Nodes
@onready var parent_room: Node = get_parent().get_parent()
@onready var parent_floor: Node = parent_room.get_parent()
var destination_room: Node

# Funcs
func _ready():
	if !destination:
		print("WARNING: No destination set for portal! " + str(self))
		return
	
	destination_room = destination.get_parent().get_parent()

func interact():
	_teleport()

func _teleport():
	parent_floor.transition_to_room(destination_room)
