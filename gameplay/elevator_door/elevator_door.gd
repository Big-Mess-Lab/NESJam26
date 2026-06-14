extends GridEntity

# Exports
@export var destination_floor: int

# Nodes
@onready var parent_floor: Node
@onready var shadow_anim: AnimatedSprite2D = $ShadowAnim
@onready var door_anim: AnimatedSprite2D = $DoorAnim

# Vars
var keycard_consumed: bool = false

# Funcs
func _ready():
	facing = Dir.DOWN
	layer = Layer.ENTITY
	super._ready()
	parent_floor = room.get_parent()
	
	if !destination_floor:
		print("WARNING: No destination floor set for elevator door! " + str(self))
		return

func interact(striker):
	if striker == Gameplay.protag and !keycard_consumed:
		if Gameplay.keycards > 0:
			Gameplay.keycards -= 1
			open()
			keycard_consumed = true
			return
	
	if striker == Gameplay.protag and keycard_consumed: 
		_teleport()
		return
	
	SFX.elevator_error.play()
	await get_tree().create_timer(0.5).timeout


func _teleport():
	Gameplay.using_elevator = true
	close()
	await get_tree().create_timer(0.5).timeout
	Gameplay.move_to_floor(destination_floor)

func open():
	door_anim.play("open")
	shadow_anim.play("open")
	SFX.elevator_door.play()
	SFX.elevator_ding.play()
	
	await door_anim.animation_finished
	door_anim.play("opened")
	shadow_anim.play("opened")

func close():
	Gameplay.protag.protag_sprite.visible = false
	Gameplay.protag.sword_sprite.visible = false
	door_anim.play("close")
	shadow_anim.play("close")
	SFX.elevator_door.play()
	
	await door_anim.animation_finished
	door_anim.play("closed")
	shadow_anim.play("closed")
