## network_adapter.gd
## Listen to events(global autoload siganls) and 
## define callback behavior(including communicate with server)

## Global NetworkAdaptor, receiving signals from somewhere else(E.X. message bus), then
## do networking relevant tasks based on the received signal.
## Autoload name to be: NetAdp
class_name NetworkAdapter
extends Node

# the player identity which will be invovled when a pack is sent out.
var identity: PlayerIdentity 

# websocket declaration..
var socket: WebSocketPeer = WebSocketPeer.new()

func _ready() -> void:
	identity = PlayerIdentity.new()
	MesB.local_move_requested.connect(_on_local_move_requested)
	
	var error: Error = socket.connect_to_url("ws://localhost:8765") # start to connect
	
	if error != OK:
		print("[NetworkAdapter] connection failed: ", error)
	else:
		# might not connected yet, but at least not failed.
		print("[NetworkAdapter] connecting...") 
	
func _process(_delta: float) -> void:
	socket.poll()
	
	while socket.get_available_packet_count() > 0:
		var message: String = socket.get_packet().get_string_from_utf8()
		
		#print("[NetworkAdapter] incoming JSON: ", message)
		
		var packet: Variant = JSON.parse_string(message)
		
		if packet == null or not packet is Dictionary:
			print_debug("[NetworkAdapter] invalid JSON packet")
			continue ## continue next iteration of while loop if there's still unparsed packet coming in!
			
		print("[NetworkAdapter] parsed packet: ", packet)
		
		## have received this packet from server..
		## tell MesB to emit this signal with this 'parsed packet'
		MesB.network_message_received.emit(packet)
			
		
	
func _on_local_move_requested(coord: Vector2i) -> void:
	"""
	A callback that triggers in order to send out a (type = "xo_put") package to server
	"""
	var packet: Dictionary = {
		"type": "xo_put",
		"data": {
			"player_id": identity.player_id,
			"position": {
				"x": coord.x,
				"y": coord.y,
			},
		},
	}
	
	var json_message: String = JSON.stringify(packet)
	
	print("[NetworkAdapter] outgoing JSON(in str form):", json_message)
	
	socket.send_text(json_message)
