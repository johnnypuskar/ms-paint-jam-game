extends Node2D

onready var level = $Level

func _ready():
	start_level(1) 

func start_level(id):
	level.load_level(id)

func reset_level():
	level.reset()
