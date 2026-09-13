# This test script, applied on a blank node(type=node2d), shows an print_debug example of:
# 1. sending chat message from godot client to python websocket server.
# 2. receiving something from python server to godot client, where:
# 			the whole process is triggered by another python client sending a message to the server.

extends Node2D

var socket: WebSocketPeer = WebSocketPeer.new()

var has_sent_message: bool = false

func _ready():
	var error = socket.connect_to_url("ws://localhost:8765")
	
	if error != OK:
		print("Websocket connection failed: ", error)
	else:
		print("Conecting to customized pywebsoc server in ready")
		
func _process(_delta):
	# for every _process, poll current connection state
	socket.poll()
		
	var state = socket.get_ready_state()
		
	if state == WebSocketPeer.STATE_OPEN:
		
		# if first _process(), try send one message out for testing purpose
		if not self.has_sent_message:
			var packet: Dictionary = {
				"type": "chat",
				"data": {
					"sender": "Godot",
					"message": "message from godot client"
				}
			} 
			
			var json_message: String = JSON.stringify(packet)
			
			# send out to server
			socket.send_text(json_message)
			
			print("Godot sent one chat packet")

			has_sent_message = true # for not sending another pack		
			
		# ---
		# process incoming packets
			
		process_incoming_packets()
			
## --
## incoming websocket packets
## --
			
func process_incoming_packets() -> void:
	"""
	check whether websockets has currently got packets in stream waiting.
	If packets exists, no matter the quantity, retrieve and process the first packet.
	 
	* actually dealing with customized application-level packets defined with customized python server. 
	"""
	
	var available_packets_count: int = socket.get_available_packet_count()
	
	if available_packets_count <= 0:
		return
	
	## retrieve one packet
	
	var received_packet: PackedByteArray = socket.get_packet()
	var received_message: String = received_packet.get_string_from_utf8()
	
	#print("godot received raw str: ", received_message)	
	
	## parse json
	
	var parsed_packet: Variant = JSON.parse_string(received_message)
	
	if parsed_packet == null:
		print_debug("godot received invalid json.")
		return
		
	## validate JSON type
	
	if not parsed_packet is Dictionary:
		print_debug(
			"godot received valid JSON, " +
			"but the resulting Variant is not a Dictionary"
		)
		push_error("godot received pack, but is not a dictionary")
		return
		
	var received_dict: Dictionary = parsed_packet
	print("godot received dictionary:", received_dict)
		
	## determine packet type
	
	var packet_type: Variant = received_dict.get("type")
	
	## if -> chat packet
	
	if packet_type == "chat":
		process_chat_packet(received_dict)
		
	else:
		print_debug(
			"Godot received an unknown or unsupported packet type: ",
			packet_type
		)
	
## --
## incoming websocket packets
## --
	
func process_chat_packet(received_dict: Dictionary) -> void:
	"""
	logically process a received packet whose type is determined to be 'chat'.
	
	(TODO) might refactor it in JSON validation layer.. 
	"""
	
	# retrieve 'data' field
	
	var data: Variant = received_dict.get("data")
	
	if not data is Dictionary:
		print_debug(" 'data' field inside is not a Dictionary")
		push_error("Malformed chat packet detected here")
		return
		
	var chat_data: Dictionary = data
	
	# retrieve 'message' field
	
	var message: Variant = chat_data.get("message")
	
	if not message is String:
		print_debug(
			" 'message' field inside 'data' field is not a String"
		)
		push_error("Malformed message data detected here.")
		return
		
	var chat_message: String = message
	
	# retrieve 'sender' field
	
	var sender: Variant = chat_data.get("sender")
	
	if not sender is String:
		print_debug(
			" 'sender' field in the 'data' field is not a String"
		)
		push_error("Malformed chat sender info.")
		return
		
	var chat_sender: String = sender
	
	
	## successfully proceed to chat packet
	
	print_debug(
		"godot received chat packet, unpacking info below: \n"
	)
	
	print("[GODOT][CHAT] sender: ", chat_sender)
	print("message: ", chat_message)
	
	
	
