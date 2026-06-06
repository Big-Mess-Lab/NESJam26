extends Node

var is_resolving: bool = false
@export var player_resolves_first: bool = true

func start_turn():
	if is_resolving:
		return
	
	is_resolving = true
	_begin_enemies()
	await _run_turn()
	is_resolving = false
	_turn_end()

func _begin_enemies():
	var room = Gameplay.current_floor.active_room
	for e in room.enemies.get_children():
		if e is GridEntity and e.has_method("begin_turn"):
			e.begin_turn()

func _gather_movers() -> Array:
	var movers: Array = []
	var room = Gameplay.current_floor.active_room
	
	# Protag
	var protag = Gameplay.protag
	
	# Enemies
	for e in room.enemies.get_children():
		if e is GridEntity and e.is_launching:
			movers.append(e)
	
	# Enemy registration order == launching order
	
	if protag.is_launching:
		if player_resolves_first:
			movers.push_front(protag)
		else:
			movers.push_back(protag)
	
	return movers

func _run_turn():
	while true:
		var movers = _gather_movers()
		if movers.is_empty():
			return
		
		var beat_duration: float = Gameplay.game_speed
		if !Gameplay.protag.is_launching:
			beat_duration = Gameplay.game_speed * 0.5
		
		var all_strikes: Array = []
		
		# 1: Move every mover in order
		for m in movers:
			var result = m.advance_step(beat_duration)
			if result.outcome == GridEntity.Outcome.STRUCK_ENTITY:
				all_strikes.append_array(result.strikes)
		
		# 2: Resolve struck targets
		for strike in all_strikes:
			var target = strike["entity"]
			target.on_struck(strike)
		
		# 3: Wait for all anims in this turn
		await _await_beat(movers, beat_duration)

func _await_beat(movers: Array, beat_duration: float):
	for m in movers:
		if m.is_animating:
			await get_tree().create_timer(beat_duration).timeout
			return

func _turn_end():
	# tick conditionals
	# handle respawns & cleanup
	# reset per-launch counters
	pass
