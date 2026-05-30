extends Node

# Game Settings
var game_speed: int = 100

# Nodes
const PROTAG_NODE = preload("uid://1ip0vr8umpa0")
var protag: Node2D
var current_floor: Node2D

# Functions
func get_tile_coordinate(px_coordinate: Vector2) -> Vector2i:
	if px_coordinate.x > 256 or px_coordinate.y > 240 or px_coordinate.x < 0 or px_coordinate.y < 0:
		print("WARNING: Tile Coordinate queried object is outside of level")
		return Vector2i(128, 120)
	
	@warning_ignore("integer_division")
	var tile_coordinate: Vector2i = Vector2i(int(px_coordinate.x) / 16, int(px_coordinate.y) / 16)
	
	return tile_coordinate
