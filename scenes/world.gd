extends Node2D

onready var level = $Level

var level_messages = {1:"Welcome! A/D and space to move and jump! When standing up against a wall, hold A or D and press SHIFT to phase!",2:"You can phase downward by holding S and pressing SHIFT! Black panels are solid and cannot be entered.",3:"Different colored panels have a strange effect on gravity...",4:"If you get stuck, press R to reset the level."}

func _ready():
	start_level(1) 

func start_level(id):
	level.load_level(id)
	if id in level_messages:
		level.player_ref.display_text(level_messages[id])

func reset_level():
	level.reset()
