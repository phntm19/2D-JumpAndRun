extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1400

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:
			if Input.is_action_pressed("ui_accept"):
				velocity.y = JUMP_SPEED
				$AudioStreamPlayer.play()
			elif Input.is_action_pressed("ui_down"):
				$AnimatedSprite2D.play("walk")
			else:
				$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("jump")
		
	move_and_slide()
