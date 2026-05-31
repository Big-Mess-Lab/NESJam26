extends Node2D

# Transition
var transition_steps_total: int = 50
var transition_step: Vector2
var transition_steps_taken: int = 0
var transition_active: bool = false
var transition_destination: Vector2

# Vars
@export var active_room: Node2D

func _ready():
	Gameplay.current_floor = self
	active_room.is_active = true
	Gameplay.protag = Gameplay.PROTAG_NODE.instantiate()
	Gameplay.protag.global_position = Vector2(120, 120)
	add_child(Gameplay.protag)

func _process(delta):
	if !transition_active:
		return
	
	_transition(delta * 60)

func transition_to_room(destination: Node):
	if destination == null:
		print("WARNING: No destination room set for room transition! " + str(self))
		return
	
	transition_destination = destination.global_position
	transition_step = (transition_destination - global_position) / transition_steps_total
	transition_active = true

func _transition_end():
	transition_active = false
	global_position = -transition_destination
	transition_steps_taken = 0

func _transition(delta: float):
	if transition_steps_taken < transition_steps_total:
		global_position += -transition_step * delta
		transition_steps_taken += 1
	else:
		_transition_end()
