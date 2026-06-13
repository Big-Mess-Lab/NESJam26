extends Control

# Vars for the thing
@onready var texture_title: TextureRect = $TextureTitle
@onready var text_push_start: RichTextLabel = $TextPushStart
@onready var text_copyright: RichTextLabel = $TextCopyright
@onready var animated_sprite_big_mess_lab: AnimatedSprite2D = $AnimatedSpriteBigMessLab
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var intro_active: bool = true
var pressed_start: bool = false

# Run the thing
func _ready():
	text_push_start.visible = false # dumb fix, prolly cuz of animations
	await get_tree().create_timer(0.5).timeout
	
	# BML anim
	animated_sprite_big_mess_lab.visible = true
	animated_sprite_big_mess_lab.play("default")
	await animated_sprite_big_mess_lab.animation_finished
	animated_sprite_big_mess_lab.visible = false
	
	await get_tree().create_timer(0.5).timeout
	
	# Title anim
	animation_player.play("title_intro")
	await get_tree().create_timer(0.01).timeout
	texture_title.visible = true
	await animation_player.animation_finished
	
	await get_tree().create_timer(0.1).timeout
	text_copyright.visible = true
	await get_tree().create_timer(0.1).timeout
	animation_player.play("text_toggle_normal")
	intro_active = false

func _input(event: InputEvent):
	if intro_active:
		return
	if pressed_start:
		return
	if event.is_action_pressed("a"):
		start_game()
	elif event.is_action_pressed("b"):
		start_game()
	elif event.is_action_pressed("select"):
		start_game()
	elif event.is_action_pressed("start"):
		start_game()

func start_game():
	pressed_start = true
	# Fast toggle text
	animation_player.stop()
	animation_player.play("toggle_text_fast")
	await get_tree().create_timer(2.0).timeout
	
	# Black screen for cutscene
	animation_player.stop()
	texture_title.visible = false
	text_push_start.visible = false
	text_copyright.visible = false
	animated_sprite_big_mess_lab.visible = false
	
	# Run first cutscene
	await get_tree().create_timer(0.5).timeout
	Cutscene.start_cutscene(1, 0.75)
	queue_free()
