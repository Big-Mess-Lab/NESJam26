extends Node2D

# Nodes
@onready var floors: TileMapLayer = $Floors
@onready var walls: TileMapLayer = $Walls
@onready var main: Node = get_parent().get_parent()
@onready var objects: Node2D = $Objects

# Vars
var is_active: bool = false
