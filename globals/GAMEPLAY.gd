extends Node

# Game Settings
var game_speed: int = 5

# Nodes
const PROTAG_NODE = preload("uid://1ip0vr8umpa0")
var protag: Node2D
var current_floor: Node2D

# Movement
var launch_active: bool = false

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

func launch_enemies():
	for e in current_floor.active_room.enemies.get_children():
		if e.has_method("launch"):
			e.launch()

func launch_update():
	if _check_enemy_launch_status():
		launch_active = false

func _check_enemy_launch_status() -> bool:
	if protag.launch_active:
		return false
	var done: bool = true
	for e in current_floor.active_room.enemies.get_children():
		if e.launch_done == false:
			return false
	return true
