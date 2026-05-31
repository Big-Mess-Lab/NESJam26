extends Node2D

# Exports
@export var destination: Marker2D

# Funcs
func _ready():
	if !destination:
		print("WARNING: No destination set for portal! " + str(self))

func interact():
	_teleport()

func _teleport():
	print("Teleported!")
