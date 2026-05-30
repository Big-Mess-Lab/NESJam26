extends Node2D

# Nodes
@onready var floors: TileMapLayer = $Floors
@onready var walls: TileMapLayer = $Walls
@onready var main: Node = get_parent().get_parent()

# Vars
var is_active: bool = false
