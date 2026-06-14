extends Node

# AudioStreamPlayers
@onready var jingle_death: AudioStreamPlayer = $JingleDeath
@onready var jingle_key_room: AudioStreamPlayer = $JingleKeyRoom
@onready var jingle_press_start: AudioStreamPlayer = $JinglePressStart
@onready var track_dungeon: AudioStreamPlayer = $TrackDungeon
@onready var track_elevator: AudioStreamPlayer = $TrackElevator
@onready var track_theme: AudioStreamPlayer = $TrackTheme

@onready var all_players: Array[AudioStreamPlayer] = [
	jingle_death,
	jingle_key_room,
	jingle_press_start,
	track_dungeon,
	track_elevator,
	track_theme
]

func play_press_start():
	for a in all_players:
		a.stop()
	jingle_press_start.play()

func play_gameplay_music(track: AudioStreamPlayer):
	track_dungeon.volume_db = -INF
	track_elevator.volume_db = -INF
	
	if track.is_playing():
		track.volume_db = 0
	else:
		track.volume_db = 0
		track.play()

func stop_all_music():
	for a in all_players:
		a.stop()
