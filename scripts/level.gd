extends Node2D

const BOX_SCENE = preload("res://scenes/Box.tscn")
const PLAYER = preload("res://scenes/Player.tscn")
const WARP = preload("res://scenes/LevelWarp.tscn")
const COLOR_DICT = {[226, 222, 221]:Color(0.89,0.87,0.87),[246, 70, 60]:Color(0.96,0.27,0.24),[42, 46, 119]:Color(0.16,0.18,0.47),[233, 184, 47]:Color(0.91,0.72,0.18),[50, 50, 50]:Color(0, 0, 0)}
# RED 246,70,60 : LEFT
# BLUE 42,46,119 : RIGHT
# YELLOW 233,184,47 : UP
# WHITE(?) 226 ,222, 221 : DOWN

#var TEST_LEVEL = [{"x":0,"y":0,"width":450,"height":300,"color":COLOR_DICT["WHITE"]},{"x":0,"y":300,"width":100,"height":250,"color":COLOR_DICT["RED"]},{"x":100,"y":300,"width":350,"height":250,"color":COLOR_DICT["YELLOW"]},{"x":450,"y":0,"width":150,"height":550,"color":COLOR_DICT["BLUE"]}]

var boxes = []
var current_id = -1
var player_start = Vector2()
var level_end = Vector2()

var player_ref = null
var warp_ref = null

func _ready():
	pass

func reset():
	player_ref.position = player_start
	player_ref.gravity_direction = Vector2(0,1)

func load_level(id):
	current_id = id
	generate_level(read_level_file("level" + str(id) + ".txt"))

func read_level_file(filename):
	var result = []
	var f = File.new()
	var result_code = f.open("res://scripts/levels/"+filename,File.READ)
	if result_code == 7:
		get_tree().change_scene("res://scenes/EndScreen.tscn")
		return null
	var line = f.get_line()
	var arr = line.split(",")
	player_start.x = float(arr[0])
	player_start.y = float(arr[1])
	line = f.get_line()
	arr = line.split(",")
	level_end.x = float(arr[0])
	level_end.y = float(arr[1])
	while not f.eof_reached():
		line = f.get_line()
		arr = line.split(",")
		result.append({"x":float(arr[0]),"y":float(arr[1]),"width":float(arr[2]),"height":float(arr[3]),"color":COLOR_DICT[[int(arr[6]),int(arr[5]),int(arr[4])]],"is_solid":(COLOR_DICT[[int(arr[6]),int(arr[5]),int(arr[4])]] == COLOR_DICT[[50, 50, 50]])})
	f.close()
	return result

func generate_level(level):
	while boxes.size() > 0:
		remove_child(boxes[0])
		boxes[0].queue_free()
		boxes.remove(0)
	if level == null:
		return
	for box in level:
		var new_node = BOX_SCENE.instance()
		new_node.set_data(box["x"], box["y"], box["width"], box["height"], box["color"], 10, box["is_solid"])
		add_child(new_node)
		boxes.append(new_node)
	if player_ref != null:
		player_ref.call_deferred("free")
	if warp_ref != null:
		warp_ref.call_deferred("free")
	var new_p = PLAYER.instance()
	new_p.position = player_start
	get_parent().call_deferred("add_child", new_p)
	player_ref = new_p
	var new_w = WARP.instance()
	new_w.position = level_end
	new_w.warp_id = current_id + 1
	get_parent().call_deferred("add_child", new_w)
	warp_ref = new_w
