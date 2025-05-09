extends RigidBody3D
class_name Coin

signal fallen

var text_mesh = preload("res://coin_text_mesh.tres")
var tween
@onready var sound = $AudioStreamPlayer3D

@export var number:int

func _ready() -> void:
	var numberMesh  = text_mesh.duplicate()
	numberMesh.text = "%d" % number
	$Number.mesh = numberMesh
	
	
func _physics_process(delta: float) -> void:
	if global_position.y <= -10:
		fallen.emit()
	

func reveal_coin() -> void:
	if abs(rad_to_deg(rotation.z)) >= 90:
		flip()
		
func hide_coin():
	if  abs(rad_to_deg(rotation.z)) < 90:
		flip(160)

func flip(angle=40):
	sound.play()
	tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($".", "position:y" , 1.5, 0.5)
	tween.tween_property($".", "rotation_degrees:z", angle, 0.5)
	
	#rotate_z(deg_to_rad(180))
