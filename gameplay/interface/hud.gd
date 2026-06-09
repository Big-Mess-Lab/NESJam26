extends CanvasLayer

# Main subsections
@onready var text_box: Panel = $TextBox
@onready var top_hud: ColorRect = $TopHud

# Hearts
@onready var texture_heart_1: TextureRect = $TopHud/MarginContainer/HBoxContainer/VBoxContainer2/HBoxLives/HBoxLivesIcons/TextureHeartContainer1/TextureHeart1
@onready var texture_heart_2: TextureRect = $TopHud/MarginContainer/HBoxContainer/VBoxContainer2/HBoxLives/HBoxLivesIcons/TextureHeartContainer2/TextureHeart2
@onready var texture_heart_3: TextureRect = $TopHud/MarginContainer/HBoxContainer/VBoxContainer2/HBoxLives/HBoxLivesIcons/TextureHeartContainer3/TextureHeart3

# HUD numbers
@onready var text_score_value: RichTextLabel = $TopHud/MarginContainer/HBoxContainer/VBoxContainer/HBoxScore/TextScoreValue
@onready var text_floor_value: RichTextLabel = $TopHud/MarginContainer/HBoxContainer/VBoxContainer/HBoxFloor/TextFloorValue
@onready var text_keycard_value: RichTextLabel = $TopHud/MarginContainer/HBoxContainer/VBoxContainer2/HBoxKeycard/TextKeycardValue


# Funcs
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
