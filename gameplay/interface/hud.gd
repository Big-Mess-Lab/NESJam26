extends CanvasLayer

# Main subsections
@onready var text_box: Panel = $TextBox
@onready var top_hud: ColorRect = $TopHud
@onready var transition_screen: ColorRect = $TransitionScreen
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Hearts
@onready var texture_heart_1: TextureRect = $TopHud/MarginContainer/HBoxContainer/VBoxContainer2/HBoxLives/HBoxLivesIcons/TextureHeartContainer1/TextureHeart1
@onready var texture_heart_2: TextureRect = $TopHud/MarginContainer/HBoxContainer/VBoxContainer2/HBoxLives/HBoxLivesIcons/TextureHeartContainer2/TextureHeart2
@onready var texture_heart_3: TextureRect = $TopHud/MarginContainer/HBoxContainer/VBoxContainer2/HBoxLives/HBoxLivesIcons/TextureHeartContainer3/TextureHeart3

# HUD numbers
@onready var text_score_value: RichTextLabel = $TopHud/MarginContainer/HBoxContainer/VBoxContainer/HBoxScore/TextScoreValue
@onready var text_floor_value: RichTextLabel = $TopHud/MarginContainer/HBoxContainer/VBoxContainer/HBoxFloor/TextFloorValue
@onready var text_keycard_value: RichTextLabel = $TopHud/MarginContainer/HBoxContainer/VBoxContainer2/HBoxKeycard/TextKeycardValue

# Textbox stuff
@onready var text_field: RichTextLabel = $TextBox/MarginContainer/TextField
@onready var continue_arrow: AnimatedSprite2D = $TextBox/MarginContainer/ContinueArrow

# Screen transition stuff

# Funcs
func _ready():
	animation_player.play("RESET")

func update_hearts():
	var hearts: int = Gameplay.protag.health
	
	match hearts:
		0:
			texture_heart_3.visible = false
			texture_heart_2.visible = false
			texture_heart_1.visible = false
		1:
			texture_heart_3.visible = false
			texture_heart_2.visible = false
			texture_heart_1.visible = true
		2:
			texture_heart_3.visible = false
			texture_heart_2.visible = true
			texture_heart_1.visible = true
		3:
			texture_heart_3.visible = true
			texture_heart_2.visible = true
			texture_heart_1.visible = true

func update_score():
	var new_score: int = Gameplay.score
	var score_text: String
	if new_score < 1000:
		score_text = "0" + str(new_score)
	else:
		score_text = str(new_score)
	
	text_score_value.text = score_text

func update_keycards():
	text_keycard_value.text = str(Gameplay.keycards)

func display_textbox(text: String, reveal_duration: float):
	# Initialize nodes
	text_field.visible_ratio = 0.0
	text_field.text = text
	continue_arrow.visible = false
	
	# Make visible, start showing text
	text_box.visible = true
	var tween: Tween = create_tween()
	tween.tween_property(text_field, "visible_ratio", 1.0, reveal_duration)
	# loop sound here
	await tween.finished
	
	# Display continue arrow on end, expect input
	continue_arrow.visible = true
	continue_arrow.play("arrow")

func hide_textbox():
	text_box.visible = false
	continue_arrow.visible = false

func transition_to_black():
	animation_player.play("to_black")

func transition_from_black():
	animation_player.play("from_black")
	await animation_player.animation_finished
	animation_player.play("RESET")
