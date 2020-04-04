extends Node2D

const BOX_SCENE = preload("res://scenes/Box.tscn")

var TEST_LEVEL = [{"x":0,"y":0,"width":450,"height":300,"color":Color(255,255,255)},{"x":0,"y":300,"width":300,"height":250,"color":Color(255,0,0)}]

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
