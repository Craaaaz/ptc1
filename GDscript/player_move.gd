extends CharacterBody2D


func _ready() -> void:
	pass
		
	

var direction = Vector2.ZERO
var speed = 100


func _physics_process(delta: float) -> void:
	direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		#print("成功觸發:向右移動")
		direction.x = 1
		
	if Input.is_action_pressed("ui_left"):
		#print("成功觸發:向左移動")
		direction.x = -1
		
		
	if Input.is_action_pressed("ui_up"):
		#print("成功觸發:向上移動")
		direction.y = -1
		
		
	if Input.is_action_pressed("ui_down"):
		#print("成功觸發:向下移動")
		direction.y = 1
	
	direction = direction.normalized()
	velocity = (direction * speed)
	move_and_slide()
	velocity = Vector2(0,0)
	
	
	
	
