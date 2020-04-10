extends Area2D

export var warp_id: int

var collected = false
onready var sound = $Sound

func _ready():
	pass

func _physics_process(delta):
	rotate(PI/60)
	if collected:
		rotate(PI/60)
		if scale.x > 0:
			scale.x -= 0.05
			scale.y -= 0.05
		else:
			get_tree().current_scene.start_level(warp_id)
	

func set_warp_id(new_id):
	warp_id = new_id

func warp_triggered(body):
	sound.play()
	if body.is_in_group("player"):
		collected = true
