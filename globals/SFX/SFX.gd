extends Node

# SFX containers
@onready var elevator_ding: AudioStreamPlayer = $ElevatorDing
@onready var elevator_door: AudioStreamPlayer = $ElevatorDoor
@onready var elevator_error: AudioStreamPlayer = $ElevatorError
@onready var elevator_running_loop: AudioStreamPlayer = $ElevatorRunningLoop
@onready var enemy_death: AudioStreamPlayer = $EnemyDeath 						#
@onready var pickup: AudioStreamPlayer = $Pickup 								#
@onready var player_bump: AudioStreamPlayer = $PlayerBump						#
@onready var player_hurt: AudioStreamPlayer = $PlayerHurt						#
@onready var sword_hurt: AudioStreamPlayer = $SwordHurt 						#
@onready var sword_sheath: AudioStreamPlayer = $SwordSheath 					#
@onready var sword_turn: AudioStreamPlayer = $SwordTurn 						#
@onready var sword_unsheath: AudioStreamPlayer = $SwordUnsheath 				#
@onready var text_blip_generic: AudioStreamPlayer = $TextBlipGeneric
@onready var text_blip_goblin: AudioStreamPlayer = $TextBlipGoblin
@onready var text_blip_knight: AudioStreamPlayer = $TextBlipKnight
@onready var text_blip_wizard: AudioStreamPlayer = $TextBlipWizard
@onready var text_continue: AudioStreamPlayer = $TextContinue					#
@onready var turn_launch: AudioStreamPlayer = $TurnLaunch						#
@onready var turn_without_player: AudioStreamPlayer = $TurnWithoutPlayer		#
@onready var turn_with_player: AudioStreamPlayer = $TurnWithPlayer				#
@onready var all_sfx: Array[AudioStreamPlayer]

func _ready():
	# Append all sfx to array
	all_sfx.append_array(get_children())

func stop_all():
	for s in all_sfx:
		s.stop()
