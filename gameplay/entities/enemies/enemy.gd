extends GridEntity

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

func advance_step() -> StepResult:
	var result = super.advance_step()
	if !is_launching:
		_pick_new_direction()
	
	return result

func _pick_new_direction():
	_update_facing(Dir.ALL.pick_random())
