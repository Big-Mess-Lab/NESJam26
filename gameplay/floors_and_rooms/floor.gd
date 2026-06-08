extends Node2D

# Nodes
@export var active_spawn: Marker2D

# Transition
var transition_steps_total: int = 50
var transition_step: Vector2
var transition_steps_taken: int = 0
var transition_active: bool = false
var transition_destination: Vector2
var transition_done: bool = false
var transition_destination_room: Node

# Vars
@export var active_room: Node2D

func _ready():
	# Initialize self node on gameplay global
	Gameplay.current_floor = self
	active_room.is_active = true
	
	# Init protag
	Gameplay.protag = Gameplay.PROTAG_NODE.instantiate()
	Gameplay.protag.position = active_room.to_local(active_spawn.global_position)
	Gameplay.protag.max_health = 3
	active_room.add_child(Gameplay.protag)

func _process(delta):
	if !transition_active:
		return
	
	_transition(delta * 60)

func transition_to_room(destination: Node):
	if destination == null:
		print("WARNING: No destination room set for room transition! " + str(self))
		return
	
	transition_destination = -destination.position
	transition_destination_room = destination
	transition_step = (transition_destination - global_position) / transition_steps_total
	transition_active = true

func _transition_end():
	transition_active = false
	global_position = transition_destination
	transition_steps_taken = 0
	active_room = transition_destination_room
	transition_destination_room = null
	transition_done = true
	active_room.reset_on_reenter()

func _transition(delta: float):
	if transition_steps_taken < transition_steps_total:
		global_position += transition_step * delta
		transition_steps_taken += 1
	else:
		_transition_end()
