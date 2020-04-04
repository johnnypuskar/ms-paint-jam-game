extends Node2D

const BOX_SCENE = preload("res://scenes/Box.tscn")
const COLOR_DICT = {"WHITE":Color(0.89,0.87,0.87),"RED":Color(0.96,0.27,0.24),"BLUE":Color(0.16,0.18,0.47),"YELLOW":Color(0.91,0.72,0.18)}
# RED 246,70,60 : LEFT
# BLUE 42,46,119 : RIGHT
# YELLOW 233,184,47 : UP
# WHITE(?) 226 ,222, 221 : DOWN

var TEST_LEVEL = [{"x":0,"y":0,"width":450,"height":300,"color":COLOR_DICT["WHITE"]},{"x":0,"y":300,"width":100,"height":250,"color":COLOR_DICT["RED"]},{"x":100,"y":300,"width":350,"height":250,"color":COLOR_DICT["YELLOW"]},{"x":450,"y":0,"width":150,"height":550,"color":COLOR_DICT["BLUE"]}]

var boxes = []

func _ready():
	generate_level(TEST_LEVEL)

func generate_level(level):
	while boxes.size() > 0:
		remove_child(boxes[0])
		boxes[0].free()
		boxes.remove(0)
	for box in level:
		var new_node = BOX_SCENE.instance()
		new_node.set_data(box["x"], box["y"], box["width"], box["height"], box["color"], 10)
		add_child(new_node)
		boxes.append(new_node)
