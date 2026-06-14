extends Node

# Game Settings
var game_speed: float = 0.2

# Nodes
var PROTAG_NODE = load("uid://1ip0vr8umpa0")
const FLOOR_01 = preload("uid://040b4rs5m30c")
const FLOOR_02 = preload("uid://cmftho2cy6t7r")
var protag: Node2D
var current_floor: Node2D

# Vars
var score: int = 0
var keycards: int = 0
var is_dying: bool = false
var using_elevator: bool = false

# Functions
func get_tile_coordinate(px_coordinate: Vector2) -> Vector2i:
	if px_coordinate.x > 256 or px_coordinate.y > 240 or px_coordinate.x < 0 or px_coordinate.y < 0:
		print("WARNING: Tile Coordinate queried object is outside of level: " + str(px_coordinate))
	
	@warning_ignore("integer_division")
	var tile_coordinate: Vector2i = Vector2i(int(px_coordinate.x) / 16, int(px_coordinate.y) / 16)
	tile_coordinate.x = min(max(tile_coordinate.x, 0), 15)
	tile_coordinate.y = min(max(tile_coordinate.y, 0), 14)
	return tile_coordinate

func get_px_coordinate(tile_coordinate: Vector2i) -> Vector2:
	if tile_coordinate.x > 15 or tile_coordinate.y > 14 or tile_coordinate.x < 0 or tile_coordinate.y < 0:
		print("WARNING: Tile Coordinate queried object is outside of level: " + str(tile_coordinate))
	
	@warning_ignore("integer_division")
	var px_coordinate: Vector2 = Vector2(tile_coordinate.x * 16.0 + 8.0, tile_coordinate.y * 16.0 + 8.0)
	px_coordinate.x = min(max(px_coordinate.x, 0), 256)
	px_coordinate.y = min(max(px_coordinate.y, 0), 240)
	return px_coordinate

func snap_current_cell(entity: GridEntity):
	# Grid-locks current position and updates cell data
	var local: Vector2 = entity.room.to_local(entity.global_position)
	entity.current_cell = local_to_cell(local)
	entity.global_position = entity.room.to_global(cell_to_local(entity.current_cell))

func local_to_cell(local: Vector2) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(int(local.x) / 16, int(local.y) / 16)

func cell_to_local(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * 16 + 8, cell.y * 16 + 8)

func move_to_floor(floor_num: int):
	if !using_elevator:
		return
	
	# Fade to black
	HUD.transition_to_black()
	await get_tree().create_timer(2.0).timeout
	# Select new floor
	var new_floor_scene
	
	match floor_num:
		1: new_floor_scene = FLOOR_01
		2: new_floor_scene = FLOOR_02
	
	# Get rid of old floor
	if is_instance_valid(current_floor):
		current_floor.queue_free()
	
	# Instance new floor
	var new_floor = new_floor_scene.instantiate()
	get_tree().current_scene.add_child(new_floor)
	current_floor = new_floor
	
	# Fade from black
	protag.protag_sprite.visible = true
	protag.sword_sprite.visible = protag.show_sword
	HUD.transition_from_black()
	await get_tree().create_timer(1.2).timeout
	using_elevator = false
