extends Node2D
class_name Room

# Nodes
@onready var floors: TileMapLayer = $Floors
@onready var walls: TileMapLayer = $Walls
@onready var main: Node = get_parent().get_parent()
@onready var objects: Node2D = $Objects
@onready var enemies: Node2D = $Enemies

# Vars
var occupants: Dictionary = {}
var is_active: bool = false

# Funcs
func _ready():
	add_to_group("room")

func register(entity: Node, cell: Vector2i):
	if !occupants.has(cell):
		var new_array = [entity]
		occupants[cell] = new_array
	else:
		if !occupants[cell].has(entity):
			occupants[cell].append(entity)

func unregister(entity: Node, cell: Vector2i):
	occupants[cell].erase(entity)
	if occupants[cell].is_empty():
		occupants.erase(cell)

func move_occupant(from: Vector2i, to: Vector2i, entity: GridEntity):
	unregister(entity, from)
	register(entity, to)

func get_cell_contents(cell: Vector2i) -> Array:
	var result: Array = []
	if walls.get_cell_source_id(cell) != -1:
		result.append(GridEntity.get_wall())
	if occupants.has(cell):
		result.append_array(occupants[cell])
	
	return result
