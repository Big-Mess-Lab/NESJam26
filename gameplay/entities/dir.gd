extends RefCounted
class_name Dir

# Directions
const UP: Vector2i = Vector2i(0, -1)
const DOWN: Vector2i = Vector2i(0, 1)
const LEFT: Vector2i = Vector2i(-1, 0)
const RIGHT: Vector2i = Vector2i(1, 0)
const ALL = [UP, DOWN, LEFT, RIGHT]

# Animation suffix dictionary
const suffix_anim: Dictionary = {UP: "up", DOWN: "down", LEFT: "left", RIGHT: "right"}
static func anim_suffix(d: Vector2i):
	return suffix_anim[d]

# Universal dir enum
enum Facing {UP, DOWN, LEFT, RIGHT}
static func from_facing(d: Facing) -> Vector2i:
	match d:
		Facing.UP:
			return UP
		Facing.DOWN:
			return DOWN
		Facing.LEFT:
			return LEFT
		Facing.RIGHT:
			return RIGHT
	return DOWN

# Direction change funcs
static func reverse(d: Vector2i) -> Vector2i:
	return -d

static func rotate_cw(d: Vector2i) -> Vector2i:
	return Vector2i(-d.y, d.x)

static func rotate_ccw(d: Vector2i) -> Vector2i:
	return Vector2i(d.y, -d.x)

static func mirror_x(d: Vector2i) -> Vector2i:
	return Vector2i(-d.x, d.y)

static func mirror_y(d: Vector2i) -> Vector2i:
	return Vector2i(d.x, -d.y)
