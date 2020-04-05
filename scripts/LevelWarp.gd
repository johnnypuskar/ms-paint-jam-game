extends Area2D

export var warp_id: int

func _ready():
	pass

func _physics_process(delta):
	rotate(PI/60)

func set_warp_id(new_id):
	warp_id = new_id

func warp_triggered(body):
	if body.is_in_group("player"):
		get_tree().current_scene.start_level(warp_id)
