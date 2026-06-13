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

func register(entity: Node, cell: Vector2i, part: StepResult.Part):
	if !occupants.has(cell):
		occupants[cell] = [{"entity": entity, "part": part}]
	else:
		for r in occupants[cell]:
			if r.entity == entity and r.part == part:
				return
		occupants[cell].append({"entity": entity, "part": part})

func unregister(entity: Node, cell: Vector2i, part: StepResult.Part):
	if !occupants.has(cell):
		return
	for r in occupants[cell]:
		if r.entity == entity and r.part == part:
			occupants[cell].erase(r)
			break
	if occupants[cell].is_empty():
		occupants.erase(cell)

func move_occupant(from: Vector2i, to: Vector2i, entity: GridEntity, part: StepResult.Part):
	unregister(entity, from, part)
	register(entity, to, part)

func get_cell_contents(cell: Vector2i) -> Array:
	var result: Array = []
	if walls.get_cell_source_id(cell) != -1:
		result.append({"entity": GridEntity.get_wall(), "part": StepResult.Part.BODY})
	if occupants.has(cell):
		result.append_array(occupants[cell])
	
	return result

func reset_on_reenter():
	for e in enemies.get_children():
		if e is GridEntity and e.respawn_on_reenter:
			e.respawn()

func reset_on_player_death():
	for e in enemies.get_children():
		if e is GridEntity and !e.is_alive and e.respawn_on_player_death:
			e.respawn()
