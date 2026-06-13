extends Node

@export var pool_size: int = 6
const VFX_SCENE = preload("uid://db2072p7qatcu")

var _free: Array[VFXOneshotAnim] = []
var _all: Array[VFXOneshotAnim] = []

func _ready():
	for i in pool_size:
		var inst: VFXOneshotAnim = VFX_SCENE.instantiate()
		add_child(inst)
		inst.finished.connect(_on_vfx_finished)
		_all.append(inst)
		_free.append(inst)

func play(anim_name: String, cell: Vector2i, room: Node = null):
	if room == null:
		room = Gameplay.current_floor.active_room
	if _free.is_empty():
		print("WARNING: Too many anims played, pool exhausted")
		return
	
	var inst: VFXOneshotAnim = _free.pop_back()
	inst.activate(anim_name, cell, room)

func _on_vfx_finished(inst: VFXOneshotAnim):
	if inst.get_parent():
		inst.get_parent().remove_child(inst)
	add_child(inst)
	_free.append(inst)
