extends Node2D

enum Facing {UP, DOWN, LEFT, RIGHT}
enum Sword {UP, DOWN, LEFT, RIGHT}
var current_facing: Facing = Facing.DOWN
var current_sword: Sword = Sword.DOWN
var show_sword: bool = false
var move_aim_mode: bool = true

func _update_direction(new_facing_direction: Facing = current_facing, new_sword_direction: Sword = current_sword, new_show_sword: bool = show_sword):
	# Draw character direction, and then sword at right direction if sword true. 
	# Also manage sword collision area 
	
	# Set vars, toggle sword if valid
	current_facing = new_facing_direction
	show_sword = new_show_sword
	current_sword = new_sword_direction
	
	# 
	match current_facing:
		Facing.UP:
			pass
		Facing.DOWN:
			pass
		Facing.LEFT:
			pass
		Facing.RIGHT:
			pass
	
	if show_sword:
		match current_sword:
			Sword.UP:
				pass
			Sword.DOWN:
				pass
			Sword.LEFT:
				pass
			Sword.RIGHT:
				pass
	
	print("Facing: " + str(current_facing) + ", Sword: " + str(current_sword) + ", Show Sword: " + str(show_sword))

func _input(event: InputEvent):
	# Change sword/face mode
	if event.is_action_pressed("a"):
		_change_mode()
	
	if show_sword:
		# Sword Directions
		if event.is_action_pressed("up"):
			_update_direction(current_facing, Sword.UP)
		if event.is_action_pressed("down"):
			_update_direction(current_facing, Sword.DOWN)
		if event.is_action_pressed("left"):
			_update_direction(current_facing, Sword.LEFT)
		if event.is_action_pressed("right"):
			_update_direction(current_facing, Sword.RIGHT)
	else:
		# Face Directions
		if event.is_action_pressed("up"):
			_update_direction(Facing.UP)
		if event.is_action_pressed("down"):
			_update_direction(Facing.DOWN)
		if event.is_action_pressed("left"):
			_update_direction(Facing.LEFT)
		if event.is_action_pressed("right"):
			_update_direction(Facing.RIGHT)


func _change_mode():
	if show_sword:
		show_sword = false
	else:
		show_sword = true
