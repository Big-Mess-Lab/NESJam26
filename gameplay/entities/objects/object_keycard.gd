extends GridEntity

# Nodes
@onready var sprite: AnimatedSprite2D = $Sprite

func _ready():
	facing = Dir.DOWN
	layer = Layer.ENTITY
	super._ready()

func on_struck(strike):
	if strike["striker_part"] == StepResult.Part.ATTACHMENT:
		if strike["striker"] == Gameplay.protag:
			death(current_cell)
	else:
		if strike["striker"] == Gameplay.protag:
			death(current_cell)

func death(at_cell: Vector2i = Vector2i(-1, -1)):
	if at_cell == Vector2i(-1, -1):
		at_cell = current_cell
	SFX.pickup.play()
	VFXPool.play("explo", current_cell, room)
	Gameplay.keycards += 1
	HUD.update_keycards()
	queue_free()
