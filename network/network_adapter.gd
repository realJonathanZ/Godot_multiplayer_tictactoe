## network_adapter.gd
## Listen to events(global autoload siganls) and 
## define callback behavior(including communicate with server)

class_name NetworkAdaptor
extends Node

func _ready() -> void:
	MessageBus.local_move_requested.connect(_on_local_move_requested)
	
func _on_local_move_requested(coord: Vector2i) -> void:
	print("[NetworkAdaptor] received local move request: ", coord)
	
