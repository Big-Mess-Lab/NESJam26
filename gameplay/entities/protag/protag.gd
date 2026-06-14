extends GridEntity

# Nodes
@onready var sword_sprite: AnimatedSprite2D = $SwordSprite
@onready var protag_sprite: AnimatedSprite2D = $ProtagSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Vars
var show_sword: bool = false
var current_sword: Vector2i = Dir.DOWN
var move_aim_mode: bool = true
var last_input_b: bool = false
var last_move_direction: Vector2i = Dir.DOWN
signal continue_pressed

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
	if Gameplay.is_dying:
		return
	if Gameplay.using_elevator:
		return
	
	if Cutscene.active:
		if event.is_action_pressed("up"):
			SFX.text_continue.play()
			continue_pressed.emit()
		elif event.is_action_pressed("down"):
			SFX.text_continue.play()
			continue_pressed.emit()
		elif event.is_action_pressed("left"):
			SFX.text_continue.play()
			continue_pressed.emit()
		elif event.is_action_pressed("right"):
			SFX.text_continue.play()
			continue_pressed.emit()
		elif event.is_action_pressed("a"):
			SFX.text_continue.play()
			continue_pressed.emit()
		elif event.is_action_pressed("b"):
			SFX.text_continue.play()
			continue_pressed.emit()
		elif event.is_action_pressed("select"):
			SFX.text_continue.play()
			continue_pressed.emit()
		elif event.is_action_pressed("start"):
			SFX.text_continue.play()
			continue_pressed.emit()
		return
	
	# Change sword/face mode
	if event.is_action_released("b"):
		aim_mode_deactivate()
		if last_input_b and show_sword:
			_toggle_show_sword()
			_update_sprites()
	last_input_b = false
	if event.is_action_pressed("b"):
		aim_mode_activate()
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
		take_damage(1, current_cell)
		TurnManager.start_turn()
	if event.is_action_pressed("debug_1"):
		Cutscene.start_cutscene(1, 1)

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
	var was_already_showing: bool = show_sword == true
	if show_sword and dir == current_sword:
		_toggle_show_sword()
		_update_sprites()
		return
	
	var sword_cell: Vector2i = current_cell + dir
	
	var jab_target = null
	for r in room.get_cell_contents(sword_cell):
		if r.entity == self:
			continue
		if r.entity.is_wall:
			return
		if blocks(r.entity):
			jab_target = r.entity
			break
	
	# Show sword if hidden
	if !show_sword:
		_toggle_show_sword()
	
	# Commit aim
	_set_attachment(true, dir)
	current_sword = dir
	_update_sprites()
	last_input_b = false
	if was_already_showing:
		SFX.sword_turn.play()
	
	# Jab action, if enemy present
	if jab_target != null:
		_jab(jab_target, sword_cell, dir)

func _jab(target, sword_cell: Vector2i, dir: Vector2i):
	var strike = {
		"entity": target,
		"striker": self,
		"direction": dir,
		"striker_part": StepResult.Part.ATTACHMENT,
		"target_part": StepResult.Part.BODY,
		"target_cell": sword_cell
	}
	target.on_struck(strike)
	hit_boop(dir)
	is_launching = false
	TurnManager.start_turn()

func advance_step(duration):
	var result = super.advance_step(duration)
	if result.outcome == GridEntity.Outcome.STRUCK_ENTITY:
		hit_boop(result.strikes[0]["direction"])
	return result

func _toggle_show_sword():
	show_sword = !show_sword
	sword_sprite.visible = show_sword
	
	if !show_sword:
		SFX.sword_unsheath.play()
		_set_attachment(false, Vector2i.ZERO)
	else:
		SFX.sword_sheath.play()

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
			if r.entity.is_wall:
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
	if Gameplay.score >= 10:
		Gameplay.score -= 10
		HUD.update_score()
	TurnManager.start_turn()

func on_struck(strike):
	if strike["target_part"] == StepResult.Part.ATTACHMENT:
		strike["striker"].take_damage(1, strike["target_cell"])
	else:
		take_damage(1, strike["target_cell"])

func _update_sprites(dir: Vector2i = facing):
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

func take_damage(amount: int = 1, at_cell: Vector2i = Vector2i(-1, -1)):
	if at_cell == Vector2i(-1, -1):
		at_cell = current_cell
	SFX.player_hurt.play()
	super.take_damage(amount, at_cell)
	HUD.update_hearts()
	damage_blink(1.5)

func damage_blink(duration: float):
	animation_player.play("damage_blink")
	await get_tree().create_timer(duration).timeout
	animation_player.stop()
	protag_sprite.visible = true

func aim_mode_activate():
	move_aim_mode = false
	animation_player.play("aim_mode_blink")

func aim_mode_deactivate():
	move_aim_mode = true
	animation_player.stop()
	protag_sprite.use_parent_material = true
	sword_sprite.use_parent_material = true

func death(at_cell: Vector2i = Vector2i(-1, -1)):
	Gameplay.is_dying = true
	if at_cell == Vector2i(-1, -1):
		at_cell = current_cell
	Music.stop_all_music()
	Music.jingle_death.play()
	
	await get_tree().create_timer(0.5).timeout
	
	HUD.transition_to_black()
	await get_tree().create_timer(1.2).timeout
	
	health = max_health
	Gameplay.current_floor.snap_to_room(Gameplay.current_floor.elevator_room)
	var elevator = Gameplay.current_floor.elevator_room
	move_to_room(elevator, elevator.spawn_cell.global_position)
	
	for r in Gameplay.current_floor.get_rooms():
		r.reset_on_player_death()
	
	HUD.update_hearts()
	Gameplay.score = 0
	HUD.update_score()
	_update_facing(Dir.from_facing(Gameplay.current_floor.elevator_room.spawn_dir))
	last_move_direction = Dir.from_facing(Gameplay.current_floor.elevator_room.spawn_dir)
	HUD.transition_from_black()
	await get_tree().create_timer(0.8).timeout
	Music.play_gameplay_music(Music.track_elevator)
	Gameplay.is_dying = false

func _bumped():
	SFX.player_bump.play()

func hit_boop(dir: Vector2i):
	var offset: Vector2 = Vector2(dir) * 2.0
	
	var body_rest: Vector2 = Vector2.ZERO
	var sword_rest: Vector2 = Vector2(attachment_offset) * 8.0
	
	protag_sprite.position = body_rest + offset
	sword_sprite.position = sword_rest + offset
	
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(protag_sprite, "position", body_rest, 0.1)
	tween.tween_property(sword_sprite, "position", sword_rest, 0.1)
