extends Label

onready var timer = $Timer

func _ready():
	pass

func _physics_process(delta):
	if self.percent_visible < 1:
		self.percent_visible += 0.01

func display(message):
	self.text = message
	self.percent_visible = 0
	timer.start()

func clear_text():
	self.text = ""
