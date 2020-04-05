extends Button

var clean_texture = preload("res://images/ui/brush_clean.png")
var painted_texture = preload("res://images/ui/brush_paint.png")

onready var timer = $Timer

func set_painted(painted):
	if painted:
		self.icon = painted_texture
		set_button_scale(1.1)
	else:
		self.icon = clean_texture
		set_button_scale(1.0)

func set_button_scale(scal):
	self.rect_scale.x = scal
	self.rect_scale.y = scal

func set_scene(scene_file):
	get_tree().change_scene(scene_file)
