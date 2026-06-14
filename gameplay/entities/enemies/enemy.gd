extends GridEntity

# Vars
@export var actions: Array[EnemyAction] = []
var cursor: int = 0
var last_step_result: StepResult
var action_counter: int = 0
@export var points_on_death: int = 150

# Authoring
@export var start_facing: Dir.Facing = Dir.Facing.DOWN

# Nodes
@onready var sprite: AnimatedSprite2D = $Sprite

func _ready():
	facing = Dir.from_facing(start_facing)
	layer = Layer.ENTITY
	super._ready()
	_update_facing(facing)

func _update_facing(dir: Vector2i):
	facing = dir
	_update_sprites(dir)

func _update_sprites(dir: Vector2i = facing):
	if is_launching:
		sprite.play("move_" + Dir.anim_suffix(dir))
	else:
		sprite.play("idle_" + Dir.anim_suffix(dir))

func begin_turn():
	is_launching = true
	distance_this_launch = 0
	cursor = 0
	action_counter = 0
	last_step_result = null

func advance_step(duration: float) -> StepResult:
	var guard: int = 0
	last_step_result = StepResult.new(Outcome.PROCEED, [])
	
	while true:
		# guard against exceeding length
		guard += 1
		if guard > actions.size() + 1:
			print("WARNING: Immediate action loop exceeded sequence length")

		if actions.is_empty() or cursor >= actions.size():
			is_launching = false
			break
		
		var action: EnemyAction = actions[cursor]
		var status: EnemyAction.Status = action.run(self, duration)
		var advanced: bool = false
		
		match status:
			EnemyAction.Status.RUNNING:
				# Same action
				pass 
			EnemyAction.Status.COMPLETED:
				# Move to next action
				cursor += 1
				action_counter = 0
				advanced = true
			EnemyAction.Status.INTERRUPTED:
				# Move to next action, check if interrupted
				cursor += 1
				action_counter = 0
				if action.interrupt_sequence_if_blocked:
					is_launching = false
		
		if cursor >= actions.size():
			is_launching = false
		
		# Check for immediacy, skip ending the beat if true
		if status == EnemyAction.Status.RUNNING:
			break
		if !action.immediate:
			break
		if !is_launching:
			break
	
	_update_sprites(facing)
	return last_step_result

func _pick_new_direction():
	_update_facing(Dir.ALL.pick_random())

func on_struck(strike):
	if strike["striker_part"] == StepResult.Part.ATTACHMENT:
		take_damage(1, strike["target_cell"])
		SFX.sword_hurt.play()
	else:
		strike["striker"].take_damage(1, strike["striker"].current_cell)

func death(at_cell: Vector2i = Vector2i(-1, -1)):
	if at_cell == Vector2i(-1, -1):
		at_cell = current_cell
	SFX.enemy_death.play()
	is_launching = false
	Gameplay.score += points_on_death
	HUD.update_score()
	super.death(at_cell)
	
	
	sprite.play("hit_" + Dir.anim_suffix(facing))
	await get_tree().create_timer(0.3).timeout
	sprite.visible = false
	if !respawn_on_reenter and !respawn_on_player_death:
		queue_free()

func respawn():
	super.respawn()
	sprite.visible = true
	_update_facing(Dir.from_facing(start_facing))
	cursor = 0
	action_counter = 0
