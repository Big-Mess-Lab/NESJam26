extends Node2D
class_name Floor

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
@export var elevator_room: Node2D
@export var key_room: Node2D

func _ready():
	# Initialize self node on gameplay global
	Gameplay.current_floor = self
	active_room.is_active = true
	
	# Init protag
	Gameplay.protag = Gameplay.PROTAG_NODE.instantiate()
	transition_destination_room = active_room
	Gameplay.protag.position = active_room.to_local(active_spawn.global_position)
	Gameplay.protag.max_health = 3
	active_room.add_child(Gameplay.protag)
	
	# Init elevator room if not set, play music
	if elevator_room == null:
		elevator_room = active_room
	Music.play_gameplay_music(Music.track_elevator)
	
	# Dirty fixes, this is to show the hud when we're jumping into the game - should be dealt with by a gamestate handler
	HUD.top_hud.visible = true

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
	
	# Play audio
	if transition_destination_room == elevator_room:
		Music.play_gameplay_music(Music.track_elevator)
	else:
		Music.play_gameplay_music(Music.track_dungeon)
	
	if transition_destination_room == key_room:
		Music.jingle_key_room.play()
	
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

func get_rooms() -> Array[Room]:
	var rooms: Array[Room] = []
	for child in get_children():
		if child is Room:
			rooms.append(child)
	return rooms

func snap_to_room(destination: Node):
	if destination == null:
		return
	global_position = -destination.position   # same formula transition_to_room targets
	transition_steps_taken = 0
	transition_active = false
	active_room.is_active = false
	destination.is_active = true
	active_room = destination
	transition_destination_room = null
	transition_done = true
