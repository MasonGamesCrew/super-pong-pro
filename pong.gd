
extends Node2D

# Member variables
const INITIAL_BALL_SPEED = 350
const AIR_RESISTANCE = .1
var ball_speed = INITIAL_BALL_SPEED
var screen_size = Vector2(1910, 1070)

var sepHeight 

# Default ball direction
var direction = Vector2(-1, 0)
var pad_size = Vector2(8, 10)
const PAD_SPEED = 500


func _process(delta):
	# Get ball position and pad rectangles
	var ball_pos = get_node("ball").get_pos()
	var left_rect = Rect2(get_node("left").get_pos() - pad_size*0.5, pad_size)
	var right_rect = Rect2(get_node("right").get_pos() - pad_size*0.5, pad_size)
	
	# Integrate new ball postion
	ball_speed *= (1 - (AIR_RESISTANCE * delta))
	ball_pos += direction*ball_speed*delta
	
	# Flip when touching roof or floor
	if ((ball_pos.y < 0 and direction.y < 0) or (ball_pos.y > screen_size.y and direction.y > 0)):
		direction.y = -direction.y
	
	# Flip, change direction and increase speed when touching pads
	if ((left_rect.has_point(ball_pos) and direction.x < 0) or (right_rect.has_point(ball_pos) and direction.x > 0)):
		direction.x = -direction.x
		ball_speed =  max((ball_speed * 1.3) + 100, INITIAL_BALL_SPEED)
		direction.y = randf()*2.0 - 1
		direction = direction.normalized()
	
	# Check gameover
	if (ball_pos.x < 0 or ball_pos.x > screen_size.x):
		ball_pos = screen_size*0.5
		ball_speed = INITIAL_BALL_SPEED
		direction = Vector2(-1, 0)
	
	get_node("ball").set_pos(ball_pos)
	
	# Move left pad
	var left_pos = get_node("left").get_pos()
	
	if (left_pos.y > 0 and Input.is_action_pressed("left_move_up")):
		left_pos.y += -PAD_SPEED*delta
	if (left_pos.y < screen_size.y and Input.is_action_pressed("left_move_down")):
		left_pos.y += PAD_SPEED*delta
	
	get_node("left").set_pos(left_pos)
	
	# Move right pad
	var right_pos = get_node("right").get_pos()
	
	if (right_pos.y > 0 and Input.is_action_pressed("right_move_up")):
		right_pos.y += -PAD_SPEED*delta
	if (right_pos.y < screen_size.y and Input.is_action_pressed("right_move_down")):
		right_pos.y += PAD_SPEED*delta
	
	
	if (get_viewport_rect().size != screen_size):
		screen_size = get_viewport_rect().size # Get actual size
		right_pos.x = screen_size.width - 67
		var sep = get_node("separator")
		var sep_pos = sep.get_pos()
		sep_pos.x = screen_size.width / 2
		sep.set_scale(Vector2(1,screen_size.height / sepHeight) )
		sep_pos.y = screen_size.height / 2
		sep.set_pos(sep_pos)
	
	get_node("right").set_pos(right_pos)


func _ready():
	sepHeight =  get_node("separator").get_pos().height
	screen_size = get_viewport_rect().size # Get actual size
	pad_size = get_node("left").get_texture().get_size()
	set_process(true)
