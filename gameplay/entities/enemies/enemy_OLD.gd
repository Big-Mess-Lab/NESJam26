extends Node2D

# Core
enum Facing {UP, DOWN, LEFT, RIGHT}
@export var current_facing: Facing = Facing.DOWN
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var room: Node2D = get_parent().get_parent()

# Movement
var distance_moved: float = 0.0
var move_direction: Vector2 = Vector2.ZERO
var launch_done: bool = true
var current_cell: Vector2i = Vector2i.ZERO

# Funcs
func _ready():
	_change_direction(current_facing)

func _process(delta):
	if launch_done:
		return
	if !Gameplay.launch_active:
		return
	
	_launch_move(delta * 60)

func _change_direction(direction: Facing):
	current_facing = direction
	
	match current_facing:
		Facing.UP:
			move_direction = Vector2(0, -1)
			sprite.play("up")
		Facing.DOWN:
			move_direction = Vector2(0, 1)
			sprite.play("down")
		Facing.LEFT:
			move_direction = Vector2(-1, 0)
			sprite.play("left")
		Facing.RIGHT:
			move_direction = Vector2(1, 0)
			sprite.play("right")

func _is_current_room_active() -> bool:
	var is_active: bool = false
	if Gameplay.current_floor.active_room == room:
		is_active = true
	
	return is_active

# Currently going until hits wall
func launch():
	launch_done = false

func _launch_can_move() -> bool:
	var can_move: bool
	match current_facing:
		Facing.UP:
			can_move = query_for_collision(global_position + Vector2(0, -16)) == -1
		Facing.DOWN:
			can_move = query_for_collision(global_position + Vector2(0, 16)) == -1
		Facing.LEFT:
			can_move = query_for_collision(global_position + Vector2(-16, 0)) == -1
		Facing.RIGHT:
			can_move = query_for_collision(global_position + Vector2(16, 0)) == -1
	
	return can_move

func _launch_move(delta: float):
	if Gameplay.launch_active and !launch_done:
		var step_speed: float = 16.0 / Gameplay.game_speed
		# trigger curve lerp
		# at end of curve lerp, set current cell, check for move
		# retrigger curve if can move, early exit if not
		if distance_moved < 16 and _launch_can_move():
			global_position += move_direction * step_speed * delta
			distance_moved += 1 * step_speed * delta
		else:
			distance_moved = 0
			set_current_cell()
			if !_launch_can_move():
				_launch_stop()
				return
			global_position += move_direction * step_speed * delta
			distance_moved += 1 * step_speed * delta

func _launch_stop():
	launch_done = true
	var rand_dir: Facing = randi_range(0, Facing.size()) as Facing
	_change_direction(rand_dir)
	Gameplay.launch_update()

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

func set_current_cell():
	# Grid-locks current position and updates cell data
	current_cell = Gameplay.get_tile_coordinate(global_position)
	global_position = Gameplay.get_px_coordinate(current_cell)
