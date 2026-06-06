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

func on_struck(strike):
	# Add collision events here
	print("Enemy struck by ", strike["striker"], " on ", strike["part"])

func begin_turn():
	is_launching = true
	distance_this_launch = 0
	cursor = 0
	action_counter = 0
	last_step_result = null

func advance_step(duration: float) -> StepResult:
	# Empty action sequence, or overrun
	if actions.is_empty() or cursor >= actions.size():
		is_launching = false
		return StepResult.new(Outcome.PROCEED, [])
	
	var action: EnemyAction = actions[cursor]
	last_step_result = StepResult.new(Outcome.PROCEED, [])
	var status: EnemyAction.Status = action.run(self, duration)
	
	match status:
		EnemyAction.Status.RUNNING:
			# Same action next beat
			pass 
		EnemyAction.Status.COMPLETED:
			# Move to next action
			cursor += 1
			action_counter = 0
		EnemyAction.Status.INTERRUPTED:
			# Move to next action, check if interrupted
			cursor += 1
			action_counter = 0
			if action.interrupt_sequence_if_blocked:
				is_launching = false
			elif cursor >= actions.size():
				is_launching = false
	
	return last_step_result

func _pick_new_direction():
	_update_facing(Dir.ALL.pick_random())
