extends GridEntity

# Exports
@export var destination: Marker2D

# Nodes
@onready var parent_floor: Node
var destination_room: Node

# Vars
var transitioning: bool = false

# Funcs
func _ready():
	facing = Dir.DOWN
	layer = Layer.ENTITY
	super._ready()
	parent_floor = room.get_parent()
	
	if !destination:
		print("WARNING: No destination set for portal! " + str(self))
		return
	
	destination_room = destination.get_parent().get_parent()

func _process(_delta):
	if !transitioning:
		return
	if parent_floor.transition_done:
		_move_player()

func interact(striker):
	_teleport()

func _teleport():
	parent_floor.transition_to_room(destination_room)
	transitioning = true

func _move_player():
	transitioning = false
	parent_floor.transition_done = false
	Gameplay.protag.move_to_room(destination_room, destination.global_position)
