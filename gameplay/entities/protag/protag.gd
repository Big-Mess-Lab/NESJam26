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
	
	if event.is_action_pressed("debug_0"):
		TurnManager.start_turn()

func _press_facing(dir: Vector2i):
	var is_repeat: bool = dir == last_move_direction
	_update_facing(dir)
	if is_repeat:
		_try_launch()
	last_move_direction = dir

func _update_facing(dir: Vector2i):
	facing = dir
	_update_sprites()

func _update_sword(dir: Vector2i):
	if show_sword and dir == current_sword:
		_toggle_show_sword()
		_update_sprites()
		return
	
	var sword_cell: Vector2i = current_cell + dir
	var collided: bool = false
	
	for r in room.get_cell_contents(sword_cell):
		if r.entity.is_wall:
			collided = true
			break
	
	if collided:
		return
	
	# Show sword if hidden
	if !show_sword:
		_toggle_show_sword()
	
	# Commit aim
	_set_attachment(true, dir)
	current_sword = dir
	_update_sprites()
	last_input_b = false

func _toggle_show_sword():
	show_sword = !show_sword
	sword_sprite.visible = show_sword
	
	if !show_sword:
		_set_attachment(false, Vector2i.ZERO)

func can_launch() -> bool:
	# Protag Body check
	for r in room.get_cell_contents(current_cell + facing):
		if r.entity == self:
			continue
		if blocks(r.entity):
			return false
	
	# Sword check
	if has_attachment:
		for r in room.get_cell_contents(current_cell + attachment_offset + facing):
			if r.entity == self:
				continue
			if blocks(r.entity):
				return false
	
	return true

func _try_launch():
	# Check for interactable GridEntity
	var front_cell: Vector2i = current_cell + facing
	for r in room.get_cell_contents(front_cell):
		if r.entity.has_method("interact"):
			r.entity.interact(self)
			return
	
	# Else, check for launch, and launch
	if !can_launch():
		return
	is_launching = true
	distance_this_launch = 0
	_update_sprites()
	TurnManager.start_turn()

func on_struck(strike):
	if strike["target_part"] == StepResult.Part.ATTACHMENT:
		# Struck something with my sword
		print("Enemy hit protag's SWORD, enemy should take damage")
	else:
		# I was hit, get damaged
		print("Enemy hit protag's BODY, protag loses a life")

func _update_sprites():
	var motion: String = "move" if is_launching else "idle"
	var facing_suffix: String = Dir.anim_suffix(facing)
	
	# Protag part
	var armed_state: String = "armed" if show_sword else "unarmed"
	protag_sprite.play(armed_state + "_" + motion + "_" + facing_suffix)
	
	# Sword part
	if show_sword:
		var sword_suffix: String = Dir.anim_suffix(attachment_offset)
		sword_sprite.play(motion + "_" + sword_suffix + "_plr_" + facing_suffix)
		
		sword_sprite.position = attachment_offset * 8
