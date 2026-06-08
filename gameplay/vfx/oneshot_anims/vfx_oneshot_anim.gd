extends AnimatedSprite2D
class_name VFXOneshotAnim

signal finished(instance)

func _ready():
	visible = false
	animation_finished.connect(_on_animation_finished)

func activate (anim_name: String, cell: Vector2i, parent_room: Node):
	if get_parent():
		get_parent().remove_child(self)
	parent_room.add_child(self)
	global_position = parent_room.to_global(Gameplay.cell_to_local(cell))
	visible = true
	play(anim_name)

func _on_animation_finished():
	visible = false
	stop()
	finished.emit(self)
