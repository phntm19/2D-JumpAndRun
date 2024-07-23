extends Node

var stump_scene = preload("res://stump.tscn")
var scorpion_scene = preload("res://scorpion.tscn")
var bat_scene = preload("res://bat.tscn")
var obstacle_types := [stump_scene, scorpion_scene]
var obstacles : Array
var bird_heights := [80, 260]

const DINO_START_POS := Vector2i(144,0)
const CAM_START_POS := Vector2i(310,180)
var score : int
const SCORE_MODIFIER : int = 10
var highscore : int
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 15
const SPEED_MODIFIER : int = 50000
var screen_size : Vector2i
var game_running : bool
var last_obs

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	#resets
	$CharacterBody2D.position = DINO_START_POS
	$CharacterBody2D.velocity = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	$StaticBody2D.position = Vector2i(0,-288)
	$HUD.get_node("StartLabel").show()
	$GameOver.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		print("Speed: "+str(speed))
		if speed > MAX_SPEED:
			speed = MAX_SPEED
			
			
		generate_obs()
		
		$CharacterBody2D.position.x += speed
		$Camera2D.position.x += speed
		
		score += speed
		show_score()
		
		if $Camera2D.position.x - $StaticBody2D.position.x > screen_size.x * 1.5:
			$StaticBody2D.position.x += screen_size.x
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()

func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		if (randi() % 2 == 0):
			var obs_type = obstacle_types[randi() % obstacle_types.size()]
			var obs
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 500
			var obs_y : int = screen_size.y - (obs_height * obs_scale.y / 2)
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		else:
			var obs = bat_scene.instantiate()
			var obs_x : int = screen_size.x + score + 500
			var obs_y : int = bird_heights[randi() % bird_heights.size()]
			last_obs = obs
			add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func hit_obs(body):
	if body.name == "CharacterBody2D":
		game_over()

func game_over():
	check_highscore()
	get_tree().paused = true
	game_running = false
	$GameOver.show()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)

func check_highscore():
	if score > highscore:
		highscore = score
		$HUD.get_node("HighscoreLabel").text = "HIGHSCORE: " + str(highscore / SCORE_MODIFIER)
