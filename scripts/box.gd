extends Node2D

export var width = 1
export var height = 1
export var outlineThickness = 10
export var color = Color(255, 255, 255)

onready var walls = {"top":$WallTop,"bottom":$WallBottom,"left":$WallLeft,"right":$WallRight}
onready var background = $Background
onready var outline = $Outline

func set_data(new_x, new_y, new_width, new_height, new_color, new_thickness):
	self.position = Vector2(new_x, new_y)
	self.width = new_width
	self.height = new_height
	self.color = new_color
	self.outlineThickness = new_thickness

func _ready():
	walls["top"].shape = RectangleShape2D.new()
	walls["bottom"].shape = RectangleShape2D.new()
	walls["left"].shape = RectangleShape2D.new()
	walls["right"].shape = RectangleShape2D.new()
	
	walls["top"].position.x = width/2
	walls["top"].shape.extents = Vector2(width/2+outlineThickness/2,outlineThickness/2)
	walls["right"].position = Vector2(width, height/2)
	walls["right"].shape.extents = Vector2(outlineThickness/2,height/2+outlineThickness/2)
	walls["bottom"].position = Vector2(width/2, height)
	walls["bottom"].shape.extents = Vector2(width/2+outlineThickness/2,outlineThickness/2)
	walls["left"].position.y = height/2
	walls["left"].shape.extents = Vector2(outlineThickness/2,height/2+outlineThickness/2)
	
	background.polygon = PoolVector2Array([Vector2(0,0),Vector2(width,0),Vector2(width,height),Vector2(0,height)])
	background.color = color
	
	outline.width = outlineThickness
	outline.points = PoolVector2Array([Vector2(0,0),Vector2(width,0),Vector2(width,height),Vector2(0,height),Vector2(0,0-outlineThickness/2)])
