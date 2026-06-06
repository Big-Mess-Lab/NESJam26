extends GridEntity

# Nodes
@onready var sword_sprite: AnimatedSprite2D = $SwordSprite
@onready var protag_sprite: AnimatedSprite2D = $ProtagSprite

# Vars
var show_sword: bool = false
var current_sword: Vector2i = Dir.DOWN
var move_aim_mode: bool = true
var last_input_b: bool = false
var last_move_direction: Vector2i = Dir.DOWN

# Funcs
func _ready():
	facing = Dir.DOWN
	super._ready() # resolves GridEntity native _ready()
	Gameplay.protag = self
	_update_facing(Dir.DOWN)

func _input(event: InputEvent):
	# Early exit if turn is still active
	if TurnManager.is_resolving:
		return
	if Gameplay.current_floor.transition_active:
		return
	
	# Change sword/face mode
	if event.is_action_released("b"):
		move_aim_mode = true
		if last_input_b and show_sword:
			_toggle_show_sword()
	last_input_b = false
	if event.is_action_pressed("b"):
		move_aim_mode = false
		last_input_b = true
	
	if !move_aim_mode:
		# Sword Directions
		if event.is_action_pressed("up"):
			_update_sword(Dir.UP)
		if event.is_action_pressed("down"):
			_update_sword(Dir.DOWN)
		if event.is_action_pressed("left"):
			_update_sword(Dir.LEFT)
		if event.is_action_pressed("right"):
			_update_sword(Dir.RIGHT)
	else:
		# Face Directions
		if event.is_action_pressed("up"):
			_press_facing(Dir.UP)
		if event.is_action_pressed("down"):
			_press_facing(Dir.DOWN)
		if event.is_action_pressed("left"):
			_press_facing(Dir.LEFT)
		if event.is_action_pressed("right"):
			_press_facing(Dir.RIGHT)

func _press_facing(dir: Vector2i):
	var is_repeat: bool = dir == last_move_direction
	_update_facing(dir)
	if is_repeat:
		_try_launch()
	last_move_direction = dir

func _update_facing(dir: Vector2i):
	facing = dir
	protag_sprite.play("look_" + Dir.anim_suffix(dir))

func _update_sword(dir: Vector2i):
	if show_sword and dir == current_sword:
		_toggle_show_sword()
		return
	
	var sword_cell: Vector2i = current_cell + dir
	var collided: bool = false
	
	for e in room.get_cell_contents(sword_cell):
		if e.is_wall:
			collided = true
			break
	
	if collided:
		return
	
	# Show sword if hidden
	if !show_sword:
		_toggle_show_sword()
	
	# Commit aim
	attachment_offset = dir
	has_attachment = true
	sword_sprite.play(Dir.anim_suffix(dir))
	sword_sprite.position = dir * 16
	current_sword = dir
	last_input_b = false

func _toggle_show_sword():
	show_sword = !show_sword
	sword_sprite.visible = show_sword
	
	if !show_sword:
		has_attachment = false

func can_launch() -> bool:
	# Protag Body check
	for e in room.get_cell_contents(current_cell + facing):
		if e == self:
			continue
		if blocks(e):
			return false
	
	# Sword check
	if has_attachment:
		for e in room.get_cell_contents(current_cell + attachment_offset + facing):
			if e == self:
				continue
			if blocks(e):
				return false
	
	return true

func _try_launch():
	# Check for interactable GridEntity
	var front_cell: Vector2i = current_cell + facing
	print("Facing cell", front_cell, " contents: ", room.get_cell_contents(front_cell), " in room ", room)
	for e in room.get_cell_contents(front_cell):
		if e.has_method("interact"):
			e.interact(self)
			return
	
	# Else, check for launch, and launch
	if !can_launch():
		return
	is_launching = true
	distance_this_launch = 0
	TurnManager.start_turn()

func on_struck(strike):
	# Player loses life
	print("Protag struck by ", strike["striker"], " from ", strike["direction"])
