extends Node3D

var coin_instance = preload("res://coin.tscn")
@onready var coinCollection = $CoinGroup
@onready var markers = $MarkersGroup
var layout = []
var game = []
var next_number 
@onready var main_timer =  $Timer
@onready var main_timer_label = $Gui/HBoxContainer/NinePatchRect/Timer
@onready var reset_timer = $ResetTimer
@onready var gauge = $Gui/HBoxContainer/Gauge
@onready var gui = $Gui
@onready var menu = $Menu
@onready var conti = $Menu/HBoxContainer/VBoxContainer/MenuOptions/Continue
@onready var winner =  $Menu/HBoxContainer/VBoxContainer/MenuOptions/Winner

@onready var menu_sound = $MenuSound
@onready var game_sound = $GameSound

var enabled: bool
var started: bool

var total_time_in_secs: int = 0

func setup(size=3):
	"""
	This setups the game according to size provided.
	"""
	layout = []
	for i in range(1, (size**2) + 1):
		layout.append(i)
	next_number = 1
	
	layout.shuffle()
	
	var index = 0
	for mark in markers.get_children():
		var coin: Coin = coin_instance.instantiate()
		coin.number = layout[index]
		coin.position = mark.position
		coin.fallen.connect(fail)
		coinCollection.add_child(coin)
		index += 1

func _ready() -> void:
	enabled = false
	started = false
	menu_sound.play()
	

func start()-> void:
	if started:
		reset()
	setup()
	winner.hide()
	next_number = 1
	total_time_in_secs = 0
	main_timer.start()
	enabled = true
	started = true
	menu.hide()
	gui.show()
	menu_sound.stop()
	game_sound.play()
	
	get_tree().paused = false


func pause():
	if get_tree().paused:
		menu.hide()
		get_tree().paused = false
		menu_sound.stop()
		game_sound.play()
	else:
		conti.show()
		menu.show()
		get_tree().paused = true
		menu_sound.play()
		game_sound.stop()

	main_timer.paused = !main_timer.paused
	
func reset():
	for child in coinCollection.get_children():
		child.queue_free()
	main_timer.paused = false
	started = false
	main_timer.stop()
	enabled = false
	

func _process(delta: float) -> void:
	if not reset_timer.is_stopped():
		var left = reset_timer.time_left
		var total = reset_timer.wait_time
		gauge.value = left/total*100

	
func reset_board():
	for child in coinCollection.get_children():
		child.hide_coin()
	
func evaluate(revealed: int)-> bool:
	if next_number == revealed:
		next_number += 1
		return true
	else:
		next_number = 1
		return false
		

func check_plate():
	var mousepos = get_viewport().get_mouse_position()
	var space = get_world_3d().direct_space_state
	var cam = $Camera3D
	
	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * 10
	var query = PhysicsRayQueryParameters3D.create(origin, end)

	var result = space.intersect_ray(query)
	if result and result.collider.has_method("flip"):
		var coin = result.collider
		
		coin.reveal_coin()
		var res = evaluate(coin.number)
		
		if next_number > 9:
			win()
			
		
		if not res:
			enabled = false
			reset_timer.start()
			

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and enabled:
		check_plate()
		

func _on_timer_timeout() -> void:
	total_time_in_secs += 1
	var m = int(total_time_in_secs / 60.0)
	var s = int(total_time_in_secs % 60) #- (m * 60)
	main_timer_label.text = "%02d:%02d" % [m, s]


func _on_reset_timer_timeout() -> void:
	reset_board()
	enabled = true
	reset_timer.stop()


func _on_new_game_pressed() -> void:
	start()


func _on_pause_pressed() -> void:
	pause()


func _on_continue_pressed() -> void:
	pause()
	
func win():
	enabled = false
	var m = int(total_time_in_secs / 60.0)
	var s = int(total_time_in_secs % 60)
	
	menu.show()
	gui.hide()
	winner.show()
	conti.hide()
	var txt = "Well Done!\nYour time: %02d:%02d"  % [m, s]
	winner.text = txt 
	
func fail():
	enabled = false
	
	menu.show()
	gui.hide()
	winner.show()
	var txt = "Sorry!\n You have failed."
	winner.text = txt
