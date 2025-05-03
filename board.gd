extends Node3D

var coin_instance = preload("res://coin.tscn")
@onready var coinCollection = $CoinGroup
@onready var start_point = $Marker3D
var layout = []
var game = []
var next_number 

func setup(size=3):
	"""
	This setups the game according to size provided.
	"""
	for i in range(1, (size**2) + 1):
		layout.append(i)
	next_number = 1
	
	layout.shuffle()
	
	for i in range(len(layout)):
		var coin: Coin = coin_instance.instantiate()
		coin.number = layout[i]
		var x = start_point.position.x + i % 3
		var y =  start_point.position.y
		var z = start_point.position.z + i / 3
		coin.position = Vector3(x, y, z)
		coinCollection.add_child(coin)

func _ready() -> void:
	setup()

func _physics_process(delta: float) -> void:
	pass
	
	
func reset_board():
	print("Reseting board")
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
		
		if not res:
			await get_tree().create_timer(2.0).timeout
			reset_board()
			

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		check_plate()
