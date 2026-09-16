## network_adapter.gd
## Listen to events(global autoload siganls) and 
## define callback behavior(including communicate with server)

## Global NetworkAdaptor, receiving signals from somewhere else(E.X. message bus), then
## do networking relevant tasks based on the received signal.
## Autoload name to be: NetAdp
class_name NetworkAdapter
extends Node

func _ready() -> void:
	MesB.local_move_requested.connect(_on_local_move_requested)
	
func _on_local_move_requested(coord: Vector2i) -> void:
	var packet: Dictionary = {
		"type": "xo_put",
		"data": {
			"position": {
				"x": coord.x,
				"y": coord.y,
			},
		},
	}
	
	var json_message: String = JSON.stringify(packet)
	
	print("[NetworkAdapter] outgoing JSON(in str form):", json_message)
	
