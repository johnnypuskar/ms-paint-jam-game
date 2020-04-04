extends Node2D

export var width = 1
export var height = 1
export var outlineThickness = 10
export var color = Color(1.0, 1.0, 1.0)

# RED 246,70,60 : LEFT
# BLUE 42,46,119 : RIGHT
# YELLOW 233,184,47 : UP
# WHITE(?) 226 ,222, 221 : DOWN
const GRAV_DICT = {Color(0.89,0.87,0.87):Vector2(0,1),Color(0.96,0.27,0.24):Vector2(1,0),Color(0.16,0.18,0.47):Vector2(-1,0),Color(0.91,0.72,0.18):Vector2(0,-1)}
export var gravity = Vector2(0,1)

onready var walls = {"top":$WallTop,"bottom":$WallBottom,"left":$WallLeft,"right":$WallRight}
onready var background = $Background
onready var outline = $Outline
onready var area_shape = $GravityArea/CollisionZone

func set_data(new_x, new_y, new_width, new_height, new_color, new_thickness):
	self.position = Vector2(new_x, new_y)
	self.width = new_width
	self.height = new_height
	self.color = new_color
	self.outlineThickness = new_thickness
	self.gravity = GRAV_DICT[color]

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
	background.color = self.color
	
	area_shape.shape = RectangleShape2D.new()
	area_shape.position = Vector2(width/2,height/2)
	area_shape.shape.extents = area_shape.position
	
	outline.width = outlineThickness
	outline.points = PoolVector2Array([Vector2(0,0),Vector2(width,0),Vector2(width,height),Vector2(0,height),Vector2(0,0-outlineThickness/2)])
