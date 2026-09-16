## network_adapter.gd
## Listen to events(global autoload siganls) and 
## define callback behavior(including communicate with server)

## Global NetworkAdaptor, receiving signals from somewhere else(E.X. message bus), then
## do something based on the received signal.
## Autoload name to be: NetAdp
class_name NetworkAdaptor
extends Node

func _ready() -> void:
	MesB.local_move_requested.connect(_on_local_move_requested)
	
func _on_local_move_requested(coord: Vector2i) -> void:
	print("[NetworkAdaptor] received local move request: ", coord)
	
