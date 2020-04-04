extends KinematicBody2D

const DOWN = Vector2(0,1)

export var gravity_direction = Vector2(0,1)
export var speed = 8
var terminal_velocity = 16

onready var rays = {"DL":$Ray_DownLeft,"DR":$Ray_DownRight,"FT":$Ray_ForwardTop,"FB":$Ray_ForwardBottom}
onready var collider = $Collision
onready var anim = $AnimationPlayer
onready var tween = $Tween

var movement_disabled = false
var velocity = Vector2()

func _ready():
	pass

func _physics_process(delta):
	if !movement_disabled:
		process_movement_control()

func process_movement_control():
	rotation = gravity_direction.angle_to(DOWN)
	var input_velocity = Vector2()
	if Input.is_action_pressed("move_right"):
		input_velocity.x += speed
	if Input.is_action_pressed("move_left"):
		input_velocity.x -= speed
	if input_velocity.x != 0:
		rays["FT"].position.x = collider.shape.extents.x * sign(input_velocity.x)
		rays["FT"].cast_to.x = sign(input_velocity.x)
		rays["FB"].position.x = collider.shape.extents.x * sign(input_velocity.x)
		rays["FB"].cast_to.x = sign(input_velocity.x)
	
	var fall_speed_limiter = terminal_velocity
	if on_ground():
		if Input.is_action_just_pressed("move_jump"):
			velocity.y = -25
		else:
			velocity.y = 0
			if Input.is_action_just_pressed("move_shift") and (input_velocity.x != 0 || Input.is_action_pressed("move_duck")):
				#TODO: change 10 below to get the thickness of the current box
				shift(input_velocity.normalized(),10)
	else:
		if against_wall():
			if Input.is_action_just_pressed("move_jump"):
				velocity.y = -20
				velocity.x = -1 * sign(rays["FT"].cast_to.x) * 20
				rays["FT"].cast_to.x = -rays["FT"].cast_to.x
				rays["FT"].position.x = -rays["FT"].position.x
				rays["FB"].cast_to.x = -rays["FT"].cast_to.x
				rays["FB"].position.x = -rays["FT"].position.x
			if sign(input_velocity.x) == sign(rays["FT"].cast_to.x) and velocity.y >= 0:
				velocity.y += 1
				fall_speed_limiter = 4
			else:
				velocity.y += 3
		else:
			velocity.y += 3
	
	if against_wall() and sign(rays["FT"].cast_to.x) == sign(input_velocity.x):
		input_velocity.x = 0
	velocity = speed_adjust(velocity,input_velocity,1.5)
	velocity.y = min(fall_speed_limiter, velocity.y)
	
	var final_velocity = velocity.rotated(gravity_direction.angle_to(DOWN))
	var fv_x = Vector2(final_velocity.x, 0)
	move_and_collide(fv_x)
	var fv_y = Vector2(0, final_velocity.y)
	move_and_collide(fv_y)

func shift(input_velocity, distance):
	var shift_dir = null
	if input_velocity.x != 0:
		if Input.is_action_pressed("move_left"):
			shift_dir = Vector2(-1,0)
			anim.play("shift_horizontal")
		elif Input.is_action_pressed("move_right"):
			shift_dir = Vector2(1,0)
			anim.play("shift_horizontal")
		else:
			return
	elif Input.is_action_pressed("move_duck"):
		shift_dir = Vector2(0,1)
		anim.play("shift_vertical")
	if shift_dir == null:
		return
	movement_disabled = true
	tween.interpolate_property(self, 'position', position, position + shift_dir*(64+distance),0.4)
	tween.start()

func enable_movement():
	movement_disabled = false

func on_ground():
	return rays["DL"].is_colliding() || rays["DR"].is_colliding()

func against_wall():
	return rays["FT"].is_colliding() || rays["FB"].is_colliding()

func speed_adjust(current: Vector2, target: Vector2, value: float):
	if abs(current.x - target.x) > value:
		current.x -= value * sign(current.x - target.x)
	else:
		current.x = target.x
	return current
