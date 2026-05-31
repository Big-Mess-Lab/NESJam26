extends Node
class_name Enemy

# Core
enum Facing {UP, DOWN, LEFT, RIGHT}
@export var current_facing: Facing = Facing.DOWN
