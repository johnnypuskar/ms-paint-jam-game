extends KinematicBody2D

const DOWN = Vector2(0,1)

export var gravity_direction = Vector2(0,1)
export var speed = 8
var terminal_velocity = 16

onready var rays = {"DL":$Ray_DownLeft,"DR":$Ray_DownRight,"FT":$Ray_ForwardTop,"FB":$Ray_ForwardBottom}
onready var center = $CenterPoint
onready var collider = $Collision
onready var sprite = $Body
onready var anim = $AnimationPlayer
onready var tween = $Tween
onready var label = $Camera/CanvasLayer/InfoText
onready var shift_areas = {Vector2(0,1):$ShiftCollision_Down,Vector2(-1,0):$ShiftCollision_Left,Vector2(1,0):$ShiftCollision_Right}
const SHIFT_ANIM_DICT = {Vector2(-1,0):"shift_horizontal",Vector2(1,0):"shift_horizontal",Vector2(0,1):"shift_vertical"}

onready var player = $Sound
var SOUND_LIB = {"walk":preload("res://sound/step.ogg"),"shift":preload("res://sound/shift.ogg"),"jump":preload("res://sound/jump.ogg")}

var movement_disabled = false
var velocity = Vector2()
var spawn_message = ""

func _ready():
	label.display(spawn_message)

func _physics_process(delta):
	if !movement_disabled:
		process_movement_control()
	set_gravity()
	if Input.is_action_just_pressed("reset"):
		reset_level()

func force_play_sound(sound):
	if SOUND_LIB.has(sound):
			player.stream = SOUND_LIB[sound]
			player.play(0)

func play_sound(sound):
	if !player.playing and SOUND_LIB.has(sound):
		player.stream = SOUND_LIB[sound]
		player.play()

func process_movement_control():
	rotation = DOWN.angle_to(gravity_direction)
	var input_velocity = Vector2()
	if Input.is_action_pressed("move_right"):
		input_velocity.x += speed
	if Input.is_action_pressed("move_left"):
		input_velocity.x -= speed
	var grounded = on_ground()
	if input_velocity.x != 0:
		rays["FT"].position.x = collider.shape.extents.x * sign(input_velocity.x)
		rays["FT"].cast_to.x = sign(input_velocity.x)
		rays["FB"].position.x = collider.shape.extents.x * sign(input_velocity.x)
		rays["FB"].cast_to.x = sign(input_velocity.x)
		sprite.scale.x = 0.75 * sign(input_velocity.x)
	
	var fall_speed_limiter = terminal_velocity
	var on_wall = against_wall()
	if grounded:
		if Input.is_action_just_pressed("move_jump"):
			force_play_sound("jump")
			velocity.y = -25
		else:
			if !movement_disabled and velocity.x != 0:
				anim.play("run")
			else:
				anim.play("idle")
			velocity.y = 0
			if Input.is_action_just_pressed("move_shift") and (input_velocity.x != 0 || Input.is_action_pressed("move_duck")):
				#TODO: change 10 below to get the thickness of the current box
				shift(input_velocity.normalized(),10)
	else:
		if on_wall:
			anim.play("wall_slide")
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
			if velocity.y <= 0:
				anim.play("jump")
			else:
				anim.play("fall")
			velocity.y += 3
	if on_wall and sign(rays["FT"].cast_to.x) == sign(input_velocity.x):
		input_velocity.x = 0
	velocity = speed_adjust(velocity,input_velocity,1.5)
	velocity.y = min(fall_speed_limiter, velocity.y)
	if velocity.x != 0 and grounded:
		play_sound("walk")
	var final_velocity = velocity.rotated(-gravity_direction.angle_to(DOWN))
	var fv_x = Vector2(final_velocity.x, 0)
	move_and_collide(fv_x)
	var fv_y = Vector2(0, final_velocity.y)
	move_and_collide(fv_y)

func shift(input_velocity, distance):
	if !(against_wall() and input_velocity.x != 0) and !(Input.is_action_pressed("move_duck")):
		return
	var shift_dir = Vector2()
	if input_velocity.x != 0:
		shift_dir.x = sign(input_velocity.x)
	elif Input.is_action_pressed("move_duck"):
		shift_dir.y = 1
	shift_dir = shift_dir.normalized()
	var grav_angle = DOWN.angle_to(gravity_direction)
	if shift_areas[shift_dir].get_overlapping_bodies().size() > 0:
		return
	if shift_areas[shift_dir].get_overlapping_areas().size() > 0:
		for area in shift_areas[shift_dir].get_overlapping_areas():
			if area.get_parent().solid:
				return
	force_play_sound("shift")
	anim.play(SHIFT_ANIM_DICT[shift_dir])
	shift_dir = shift_dir.rotated(grav_angle)
	movement_disabled = true
	tween.interpolate_property(self, 'position', position, position + shift_dir*(32+distance),0.4)
	tween.start()

func enable_movement():
	movement_disabled = false

func display_text(message):
	spawn_message = message

func set_gravity():
	if center.is_colliding():
		var new_grav = center.get_collider().get_parent().gravity
		if new_grav != null:
			gravity_direction = new_grav

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

func reset_level():
	if get_parent().is_in_group("world"):
		get_parent().reset_level()
