extends GridEntity

# Vars
@export var actions: Array[EnemyAction] = []
var cursor: int = 0
var last_step_result: StepResult
var action_counter: int = 0

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
	sprite.play(Dir.anim_suffix(dir))

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
	
	return last_step_result

func _pick_new_direction():
	_update_facing(Dir.ALL.pick_random())

func on_struck(strike):
	if strike["striker_part"] == StepResult.Part.ATTACHMENT:
		print("Protag's SWORD hit enemy, enemy takes damage")
		VFXPool.play("explo", strike["entity"].current_cell, room)
	else:
		print("Protag's BODY hit enemy, protag loses a life")
		VFXPool.play("explo", Gameplay.protag.current_cell, room)
	pass
