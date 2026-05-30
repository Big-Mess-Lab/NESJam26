extends Node2D

# Nodes
@onready var sword_sprite: AnimatedSprite2D = $SwordSprite
@onready var protag_sprite: AnimatedSprite2D = $ProtagSprite
@onready var protag_collision: CollisionShape2D = $ProtagCollision
@onready var sword_collision: CollisionShape2D = $SwordCollision

# Face and Sword directions
enum Facing {UP, DOWN, LEFT, RIGHT}
enum Sword {UP, DOWN, LEFT, RIGHT}
var current_facing: Facing = Facing.DOWN
var current_sword: Sword = Sword.DOWN
var show_sword: bool = false
var move_aim_mode: bool = true

func _input(event: InputEvent):
	# Change sword/face mode
	if event.is_action_pressed("a"):
		_change_mode()
	
	if move_aim_mode:
		# Sword Directions
		if event.is_action_pressed("up"):
			_update_sword(Sword.UP)
		if event.is_action_pressed("down"):
			_update_sword(Sword.DOWN)
		if event.is_action_pressed("left"):
			_update_sword(Sword.LEFT)
		if event.is_action_pressed("right"):
			_update_sword(Sword.RIGHT)
	else:
		# Face Directions
		if event.is_action_pressed("up"):
			_update_facing(Facing.UP)
		if event.is_action_pressed("down"):
			_update_facing(Facing.DOWN)
		if event.is_action_pressed("left"):
			_update_facing(Facing.LEFT)
		if event.is_action_pressed("right"):
			_update_facing(Facing.RIGHT)
	
	if event.is_action_pressed("b"):
		pass # launch

func _update_facing(new_facing_direction: Facing):
	current_facing = new_facing_direction
	
	match current_facing:
		Facing.UP:
			protag_sprite.play("look_up")
		Facing.DOWN:
			protag_sprite.play("look_down")
		Facing.LEFT:
			protag_sprite.play("look_left")
		Facing.RIGHT:
			protag_sprite.play("look_right")

func _update_sword(new_sword_direction: Sword):
	if show_sword and new_sword_direction == current_sword:
		_toggle_show_sword()
	elif !show_sword:
		_toggle_show_sword()
	
	current_sword = new_sword_direction
	
	match current_sword:
		Sword.UP:
			sword_sprite.play("up")
			sword_sprite.position = Vector2(0, -16)
			sword_collision.position = Vector2(0, -16)
		Sword.DOWN:
			sword_sprite.play("down")
			sword_sprite.position = Vector2(0, 16)
			sword_collision.position = Vector2(0, 16)
		Sword.LEFT:
			sword_sprite.play("left")
			sword_sprite.position = Vector2(-16, 0)
			sword_collision.position = Vector2(-16, 0)
		Sword.RIGHT:
			sword_sprite.play("right")
			sword_sprite.position = Vector2(16, 0)
			sword_collision.position = Vector2(16, 0)

func _change_mode():
	if move_aim_mode:
		move_aim_mode = false
	else:
		move_aim_mode = true

func _toggle_show_sword():
	if show_sword:
		show_sword = false
	else:
		show_sword = true
	
	sword_sprite.visible = show_sword
	sword_collision.disabled = !show_sword
