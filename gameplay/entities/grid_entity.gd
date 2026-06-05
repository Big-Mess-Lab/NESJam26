extends Node2D
class_name GridEntity

# Core vars
## Position
var current_cell: Vector2i
var room: Node
var spawn_cell: Vector2i
var distance_this_launch: int = 0
var is_launching: bool = false

## Direction
var facing: Vector2i

## State
enum Layer {FLOOR, ENTITY, AIR} # 0, 1, 2
@export var layer: Layer = Layer.ENTITY
static var WALL # wall flag
var is_wall: bool = false
var is_animating: bool = false
var is_alive: bool = true
var respawn_on_reenter: bool = false
var respawn_on_player_death: bool = true # if both are false, it's a one-shot enemy
signal step_finished

## Attachment
@export var has_attachment: bool = false
var attachment_offset: Vector2i = Vector2i.ZERO

## Occupancy
enum Outcome {PROCEED, BLOCKED_WALL, STRUCK_ENTITY}

# Core funcs
func _ready():
	if facing == Vector2i.ZERO:
		print("No facing direction set for " + str(self) + "!")
		return
	
	# Set owning room
	room = _find_room()
	
	# Snap to cell, register to room, set z_index, set spawn cell
	Gameplay.snap_current_cell(self)
	room.register(self, current_cell)
	z_index = layer + 1 # map tilesets are 0 by default, need to be above
	spawn_cell = current_cell

func _find_room() -> Node:
	var node: Node = get_parent()
	while node != null:
		if node is Room:
			return node
		node = node.get_parent()
	return null

func try_step(direction: Vector2i) -> StepResult:
	var target_cell: Vector2i = current_cell + direction
	var target_attachment_cell: Vector2i
	var target_cell_contents: Array
	var target_attachment_contents: Array
	
	# Get target cell contents
	target_cell_contents = room.get_cell_contents(target_cell)
	
	if has_attachment:
		target_attachment_cell = current_cell + attachment_offset + direction
		target_attachment_contents = room.get_cell_contents(target_attachment_cell)
	
	# Check for walls, early return if there's any wall
	for e in target_cell_contents:
		if e.is_wall == true:
			return StepResult.new(Outcome.BLOCKED_WALL, [])
	
	if has_attachment:
		for e in target_attachment_contents:
			if e.is_wall == true:
				return StepResult.new(Outcome.BLOCKED_WALL, [])
	
	# Scan through for target cell contents, append entities
	var strikes: Array = []
	
	for e in target_cell_contents:
		if e == self:
			continue
		if blocks(e):
			strikes.append({"entity": e, "striker": self, "direction": direction, "part": StepResult.Part.BODY})
	
	if has_attachment:
		for e in target_attachment_contents:
			if e == self:
				continue
			if blocks(e):
				strikes.append({"entity": e, "striker": self, "direction": direction, "part": StepResult.Part.ATTACHMENT})
	
	# Gather results if not empty, return results
	if !strikes.is_empty():
		return StepResult.new(Outcome.STRUCK_ENTITY, strikes)
	
	# Initiate move if empty, return PROCEED
	
	is_animating = true
	room.move_occupant(current_cell, target_cell, self)
	current_cell = target_cell
	distance_this_launch += 1
	_start_move_tween()
	return StepResult.new(Outcome.PROCEED, [])

func death():
	room.unregister(self, current_cell)
	is_alive = false
	# disable visuals

func respawn():
	current_cell = spawn_cell
	room.register(self, current_cell)
	is_alive = true
	# enable visuals

func blocks(other: GridEntity) -> bool: # Am I blocked by other?
	if other.is_wall:
		return true
	return GridEntity.layers_collide(layer, other.layer)

func _start_move_tween():
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "global_position", Gameplay.cell_to_local(current_cell), Gameplay.game_speed)
	tween.finished.connect(_on_step_finished)

func _on_step_finished():
	is_animating = false
	step_finished.emit()

static func get_wall() -> GridEntity:
	if WALL == null:
		WALL = GridEntity.new()
		WALL.is_wall = true
	return WALL

static func layers_collide(a: Layer, b: Layer) -> bool:
	return a == Layer.ENTITY and b == Layer.ENTITY

func advance_step() -> StepResult:
	var result: StepResult = try_step(facing)
	if result.outcome != Outcome.PROCEED:
		is_launching = false
	
	return result

func on_struck(strike):
	# needs to resolve for itself
	pass

func move_to_room(new_room: Node, new_global_pos: Vector2):
	room.unregister(self, current_cell)
	get_parent().remove_child(self)
	new_room.add_child(self)
	room = new_room
	global_position = new_global_pos
	Gameplay.snap_current_cell(self)
	room.register(self, current_cell)
