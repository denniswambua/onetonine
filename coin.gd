extends RigidBody3D
class_name Coin

var text_mesh = preload("res://coin_text_mesh.tres")

@export var number:int
@onready var pickable = $CollisionShape3D

var face: bool = false


func _ready() -> void:
	flip()
	var numberMesh  = text_mesh.duplicate()
	numberMesh.text = "%d" % number
	$Number.mesh = numberMesh
	

func reveal_coin() -> void:
	print("revealing")
	if not face:
		flip()
		face = true
		
func hide_coin():
	if face:
		flip()
		face = false

func flip():
	rotate_z(deg_to_rad(180))
