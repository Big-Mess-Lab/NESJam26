extends Node2D

# Nodes
@onready var sword_sprite: AnimatedSprite2D = $SwordSprite
@onready var protag_sprite: AnimatedSprite2D = $ProtagSprite
var active_room: Node2D = Gameplay.current_floor.active_room

# Core vars
var current_cell: Vector2i

# Face and Sword directions
enum Facing {UP, DOWN, LEFT, RIGHT}
enum Sword {UP, DOWN, LEFT, RIGHT}
var current_facing: Facing = Facing.DOWN
var current_sword: Sword = Sword.DOWN
var show_sword: bool = false
var move_aim_mode: bool = true
var coords_of_cell_in_front: Vector2i

# Launching
var launch_active: bool = false
var distance_moved: float = 0.0
var move_direction: Vector2 = Vector2.ZERO

# Funcs
func _ready():
	_update_facing(Facing.DOWN)
	Gameplay.protag = self
	_set_current_cell()

func _process(delta):
	if !launch_active:
		return
	
	_launch_move(delta * 60)

func _input(event: InputEvent):
	# Early exit if we're moving
	if launch_active:
		return
	
	# Change sword/face mode
	if event.is_action_pressed("b"):
		move_aim_mode = false
	if event.is_action_released("b"):
		move_aim_mode = true
	
	if !move_aim_mode:
		# Sword Directions
		if event.is_action_pressed("up"):
			_update_sword(Sword.UP)
		if event.is_action_pressed("down"):
			_update_sword(Sword.DOWN)
		if event.is_action_pressed("left"):
			_update_sword(Sword.LEFT)
		if event.is_action_pressed("right"):
			_update_sword(Sword.RIGHT)
	else:
		# Face Directions
		if event.is_action_pressed("up"):
			_update_facing(Facing.UP)
		if event.is_action_pressed("down"):
			_update_facing(Facing.DOWN)
		if event.is_action_pressed("left"):
			_update_facing(Facing.LEFT)
		if event.is_action_pressed("right"):
			_update_facing(Facing.RIGHT)
	
	if event.is_action_pressed("a"):
		_update_facing(current_facing)
		var object: Node = _interact_check()
		if object != null and object.has_method("interact"):
			object.interact()
		else:
			_launch_start()

func _update_facing(new_facing_direction: Facing):
	current_facing = new_facing_direction
	
	match current_facing:
		Facing.UP:
			protag_sprite.play("look_up")
			move_direction = Vector2(0, -1)
			coords_of_cell_in_front = Vector2i(global_position + Vector2(0, -16))
		Facing.DOWN:
			protag_sprite.play("look_down")
			move_direction = Vector2(0, 1)
			coords_of_cell_in_front = Vector2i(global_position + Vector2(0, 16))
		Facing.LEFT:
			protag_sprite.play("look_left")
			move_direction = Vector2(-1, 0)
			coords_of_cell_in_front = Vector2i(global_position + Vector2(-16, 0))
		Facing.RIGHT:
			protag_sprite.play("look_right")
			move_direction = Vector2(1, 0)
			coords_of_cell_in_front = Vector2i(global_position + Vector2(16, 0))

func _update_sword(new_sword_direction: Sword):
	var new_position: Vector2
	var collided: bool = true
	
	match new_sword_direction:
		Sword.UP:
			if query_for_collision(global_position + Vector2(0, -16)) == -1:
				sword_sprite.play("up")
				new_position = Vector2(0, -16)
				collided = false
		Sword.DOWN:
			if query_for_collision(global_position + Vector2(0, 16)) == -1:
				sword_sprite.play("down")
				new_position = Vector2(0, 16)
				collided = false
		Sword.LEFT:
			if query_for_collision(global_position + Vector2(-16, 0)) == -1:
				sword_sprite.play("left")
				new_position = Vector2(-16, 0)
				collided = false
		Sword.RIGHT:
			if query_for_collision(global_position + Vector2(16, 0)) == -1:
				sword_sprite.play("right")
				new_position = Vector2(16, 0)
				collided = false
	
	if show_sword and new_sword_direction == current_sword:
		_toggle_show_sword()
	elif !show_sword and !collided:
		_toggle_show_sword()
	
	if show_sword and !collided:
		sword_sprite.position = new_position
		current_sword = new_sword_direction

func _toggle_show_sword():
	if show_sword:
		show_sword = false
	else:
		show_sword = true
	
	sword_sprite.visible = show_sword

func query_for_collision(coords: Vector2) -> int:
	# -1: Null, 0: Walls
	# Check for walls first
	var tile: Vector2i = Gameplay.get_tile_coordinate(coords)
	var tileset: TileMapLayer = Gameplay.current_floor.active_room.walls
	var collided_wall: bool = tileset.get_cell_source_id(tile) != -1
	
	if collided_wall:
		return 0
	
	# Then for 
	return -1

func _set_current_cell():
	# Grid-locks current position and updates cell data
	current_cell = Gameplay.get_tile_coordinate(global_position)
	global_position = Gameplay.get_px_coordinate(current_cell)

# Interact funcs
func _interact_check() -> Node:
	var objects: Array[Node] = active_room.objects.get_children()
	var interacted_object: Node = null
	
	for o in objects:
		if Vector2i(o.global_position) == coords_of_cell_in_front:
			interacted_object = o
	
	return interacted_object

# Launch funcs
func _launch_start():
	if !launch_active and _launch_can_move():
		launch_active = true

func _launch_can_move() -> bool:
	var can_move_body: bool
	var can_move_sword: bool
	match current_facing:
		Facing.UP:
			can_move_body = query_for_collision(global_position + Vector2(0, -16)) == -1
			can_move_sword = query_for_collision(global_position + Vector2(0, -16) + sword_sprite.position) == -1
		Facing.DOWN:
			can_move_body = query_for_collision(global_position + Vector2(0, 16)) == -1
			can_move_sword = query_for_collision(global_position + Vector2(0, 16) + sword_sprite.position) == -1
		Facing.LEFT:
			can_move_body = query_for_collision(global_position + Vector2(-16, 0)) == -1
			can_move_sword = query_for_collision(global_position + Vector2(-16, 0) + sword_sprite.position) == -1
		Facing.RIGHT:
			can_move_body = query_for_collision(global_position + Vector2(16, 0)) == -1
			can_move_sword = query_for_collision(global_position + Vector2(16, 0) + sword_sprite.position) == -1
	
	# Override sword check if hidden
	if !show_sword:
		can_move_sword = true
	
	# Sum checks, return
	var can_move: bool = false
	if can_move_body and can_move_sword:
		can_move = true
	return can_move

func _launch_move(delta: float):
	if launch_active:
		var step_speed: float = 16.0 / Gameplay.game_speed
		# trigger curve lerp
		# at end of curve lerp, set current cell, check for move
		# retrigger curve if can move, early exit if not
		if distance_moved < 16:
			global_position += move_direction * step_speed * delta
			distance_moved += 1 * step_speed * delta
		else:
			distance_moved = 0
			_set_current_cell()
			if !_launch_can_move():
				_launch_stop()
				return
			global_position += move_direction * step_speed * delta
			distance_moved += 1 * step_speed * delta

func _launch_stop():
	launch_active = false
