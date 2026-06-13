extends Node2D
class_name GridEntity

# Core vars
## Position
var current_cell: Vector2i
var room: Node
var spawn_cell: Vector2i
var distance_this_launch: int = 0
var is_launching: bool = false
@export var respawn_on_reenter: bool = false
@export var respawn_on_player_death: bool = true

# Health & damage
@export var max_health: int = 1
var health: int

## Direction
var facing: Vector2i

## State
enum Layer {FLOOR, ENTITY, AIR} # 0, 1, 2
@export var layer: Layer = Layer.ENTITY
static var WALL # wall flag
var is_wall: bool = false
var is_animating: bool = false
var is_alive: bool = true
signal step_finished

## Attachment
@export var has_attachment: bool = false
var attachment_offset: Vector2i = Vector2i.ZERO
var attachment_cell: Vector2i

## Occupancy
enum Outcome {PROCEED, BLOCKED_WALL, STRUCK_ENTITY}

# Core funcs
func _ready():
	if facing == Vector2i.ZERO:
		print("WARNING: No facing direction set for " + str(self) + "!")
		return
	
	# Set owning room
	room = _find_room()
	
	# Set health
	health = max_health
	
	# Snap to cell, register to room, set z_index, set spawn cell
	Gameplay.snap_current_cell(self)
	_register_self()
	z_index = layer + 1 # map tilesets are 0 by default, need to be above
	spawn_cell = current_cell

func _find_room() -> Node:
	var node: Node = get_parent()
	while node != null:
		if node is Room:
			return node
		node = node.get_parent()
	return null

func try_step(direction: Vector2i, beat_duration: float) -> StepResult:
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
	for r in target_cell_contents:
		if r.entity.is_wall == true:
			return StepResult.new(Outcome.BLOCKED_WALL, [])
	
	if has_attachment:
		for r in target_attachment_contents:
			if r.entity.is_wall == true:
				return StepResult.new(Outcome.BLOCKED_WALL, [])
	
	# Scan through for target cell contents, append entities
	var strikes: Array = []
	
	for r in target_cell_contents:
		if r.entity == self:
			continue
		if blocks(r.entity):
			strikes.append({"entity": r.entity, "striker": self, "direction": direction, "striker_part": StepResult.Part.BODY, "target_part": r.part, "target_cell": target_cell})
	
	if has_attachment:
		for r in target_attachment_contents:
			if r.entity == self:
				continue
			if blocks(r.entity):
				strikes.append({"entity": r.entity, "striker": self, "direction": direction, "striker_part": StepResult.Part.ATTACHMENT, "target_part": r.part, "target_cell": target_attachment_cell})
	
	# Gather results if not empty, return results
	if !strikes.is_empty():
		return StepResult.new(Outcome.STRUCK_ENTITY, strikes)
	
	# Initiate move if empty, return PROCEED
	is_animating = true
	# Move body record
	room.move_occupant(current_cell, target_cell, self, StepResult.Part.BODY)
	# Move attachment record, if any
	if has_attachment:
		var new_attachment_cell: Vector2i = target_cell + attachment_offset
		room.move_occupant(attachment_cell, new_attachment_cell, self, StepResult.Part.ATTACHMENT)
		attachment_cell = new_attachment_cell
	current_cell = target_cell
	distance_this_launch += 1
	_start_move_tween(beat_duration)
	return StepResult.new(Outcome.PROCEED, [])

func death(at_cell: Vector2i = Vector2i(-1, -1)):
	if at_cell == Vector2i(-1, -1):
		at_cell = current_cell
	VFXPool.play("explo", at_cell, room)
	_unregister_self()
	is_alive = false

func blocks(other: GridEntity) -> bool: # Am I blocked by other?
	if other.is_wall:
		return true
	return GridEntity.layers_collide(layer, other.layer)

func _start_move_tween(beat_duration: float):
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)#TRANS_SINE)
	tween.tween_property(self, "global_position", Gameplay.cell_to_local(current_cell), beat_duration)
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

func advance_step(beat_duration: float) -> StepResult:
	var result: StepResult = try_step(facing, beat_duration)
	if result.outcome != Outcome.PROCEED:
		is_launching = false
		if self == Gameplay.protag:
			Gameplay.protag._update_sprites()
	
	return result

func on_struck(strike):
	# needs to resolve for itself
	pass

func move_to_room(new_room: Node, new_global_pos: Vector2):
	_unregister_self()
	get_parent().remove_child(self)
	new_room.add_child(self)
	room = new_room
	global_position = new_global_pos
	Gameplay.snap_current_cell(self)
	_register_self()

func _register_self():
	room.register(self, current_cell, StepResult.Part.BODY)
	if has_attachment:
		attachment_cell = current_cell + attachment_offset
		room.register(self, attachment_cell, StepResult.Part.ATTACHMENT)

func _unregister_self():
	room.unregister(self, current_cell, StepResult.Part.BODY)
	if has_attachment:
		room.unregister(self, attachment_cell, StepResult.Part.ATTACHMENT)

func _set_attachment(active: bool, offset: Vector2i):
	if has_attachment:
		room.unregister(self, attachment_cell, StepResult.Part.ATTACHMENT)
	
	has_attachment = active
	attachment_offset = offset
	
	if has_attachment:
		attachment_cell = current_cell + attachment_offset
		room.register(self, attachment_cell, StepResult.Part.ATTACHMENT)

func take_damage(amount: int = 1, at_cell: Vector2i = Vector2i(-1, -1)):
	if at_cell == Vector2i(-1, -1):
		at_cell = current_cell
	if !is_alive:
		return
	health -= amount
	if health <= 0:
		death(at_cell)
	else:
		_on_damaged(amount, at_cell)

func _on_damaged(amount: int, at_cell: Vector2i = Vector2i(-1, -1)):
	if at_cell == Vector2i(-1, -1):
		at_cell = current_cell
	VFXPool.play("explo", at_cell, room)

func respawn():
	if is_alive:
		_unregister_self()
	current_cell = spawn_cell
	is_alive = true
	distance_this_launch = 0
	health = max_health
	_register_self()
	global_position = room.to_global(Gameplay.cell_to_local(current_cell))
