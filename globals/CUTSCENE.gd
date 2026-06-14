extends Node

# Vars
var active: bool = false
var current_line: int = 0
signal continue_pressed
const FLOOR_01 = preload("uid://cmftho2cy6t7r")

# Data: Cutscene 1
var lines_01: Array[String] = [ # Lines of cutscene 01
	"One final stop and I can finally call it a night",
	"Ah, if that isn't Taxknight... Go Away!",
	"Wizard, I'm just doing my job. In the name of the king: Your taxes are overdue by a week and you need to pay now!",
	"You don't know anything, Taxknight! Leave me alone!",
	"I won't leave until you pay! I will come up your tower if I have to!",
	"Oh Yeah? I wanna see you try!",
	"What did you do? Wh- what is this?",
	"Good luck with the stairs! You'll never get to me!",
	"Just the thing I needed before the end of my shift...",
	"I can't return empty handed, the king will have my head. I need to get up that tower...",
	"Outta da way!"
]

# Logic
func start_cutscene(number: int, reveal_duration: float):
	active = true
	var lines: Array[String]
	match number:
		1:
			lines = lines_01
	
	for line in lines:
		await HUD.display_textbox(line, reveal_duration)
		if does_protag_exist():
			await Gameplay.protag.continue_pressed
		else:
			await continue_pressed
	
	end_cutscene(number)

func end_cutscene(number: int):
	active = false
	current_line = 0
	HUD.hide_textbox()
	
	# Do stuff on end of cutscene
	match number:
		1:
			var inst = FLOOR_01.instantiate()
			get_tree().root.get_node("Main").add_child(inst)

func does_protag_exist() -> bool:
	if Gameplay.protag != null and is_instance_valid(Gameplay.protag):
		return true
	else:
		return false

func _input(event: InputEvent):
	if !active:
		return
	if does_protag_exist():
		return
	
	if event.is_action_pressed("up"):
		SFX.text_continue.play()
		continue_pressed.emit()
	elif event.is_action_pressed("down"):
		SFX.text_continue.play()
		continue_pressed.emit()
	elif event.is_action_pressed("left"):
		SFX.text_continue.play()
		continue_pressed.emit()
	elif event.is_action_pressed("right"):
		SFX.text_continue.play()
		continue_pressed.emit()
	elif event.is_action_pressed("a"):
		SFX.text_continue.play()
		continue_pressed.emit()
		SFX.text_continue.play()
	elif event.is_action_pressed("b"):
		continue_pressed.emit()
		SFX.text_continue.play()
	elif event.is_action_pressed("select"):
		SFX.text_continue.play()
		continue_pressed.emit()
	elif event.is_action_pressed("start"):
		SFX.text_continue.play()
		continue_pressed.emit()
	return
