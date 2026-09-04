# This test script, applied on a blank node(type=node2d), shows an print_debug example of:
# 1. send a join_room packet to the pywebsoc server
# 2. print_debug once the room is changed.


extends Node2D

var socket: WebSocketPeer = WebSocketPeer.new()

# whether has already sent one test message to the server
var has_sent_message: bool = false

# test usaged room id included in packet sent out
var room_id: String = "111"

# test usaged client name included in packet sent out
var client_name: String = "A"

# test usage used. Player identifier. which I want each godot exe possess one. (UUID relevant)
var player_id: String = ""

# test usage used, displaying later on UI later. (UUID relevent)
var display_name: String = "BRUH_PlAYER_JO"


func _ready():
	initialize_player_identity()
	
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
				"type": "join_room",
				"data": {
					"room_id" : self.room_id,
					"client_name" : self.client_name
				}
			} 
			
			var json_message: String = JSON.stringify(packet)
			
			# send out to server
			socket.send_text(json_message)
			
			print("Godot sent one join_room packet")

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
	
	## conditional dispatcher
	
	if packet_type == "chat":
		process_chat_packet(received_dict)
		
	elif packet_type == "room_joined":
		process_room_joined_packet(received_dict)
	
	else:
		print_debug(
			"Godot received an unknown or unsupported packet type: ",
			packet_type
		)
	
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
	
func process_room_joined_packet(received_dict: Dictionary) -> void:
	"""
	logically process a received packet whose type is determined to be 'room_joined'.
	
	(TODO) might refactor it in JSON validation layer.. 
	"""
	
	# retrieve 'data' field
	
	var data: Variant = received_dict.get("data")
	
	if not data is Dictionary:
		print_debug(" 'data' field inside is not a Dictionary. ")
		push_error("Malformed room_joined packet detected here. ")
		return
		
	var room_joined_data: Dictionary = data
	
	# retrieve 'room_id' field
	
	var a_room_id: Variant = room_joined_data.get("room_id")
	
	if not a_room_id is String:
		print_debug(" 'room_id' field inside 'data' field is not a String. ")
		push_error("Malform room_id detected here. ")
		return
		
	var joined_room_id: String = a_room_id
	
	# retrieve 'client_name' field
	
	var a_client_name: Variant = room_joined_data.get("client_name")
	
	if not a_client_name is String:
		print_debug(" 'client_name' field inside 'data' field is not a String.")
		push_error("Malformed client_name data detected here.")
		return
		
	var joined_client_name: String = a_client_name
	
	## successfully proceed to room_joined packet
	
	print_debug(
		"godot received room_joined packet, unpacking info below: \n"
	)
	
	print("[GODOT][ROOM JOINED] client: ", joined_client_name)
	print("joined room: ", joined_room_id)
	
## =====
## Player universally unique identity.
## * should be preserved around file at "user://player_id.txt"
## =====

func initialize_player_identity() -> void:
	# where the player(who are executing this game exe)'s identity info is stored.
	var identity_path: String = "user://player_id.txt"  
	
	if FileAccess.file_exists(identity_path):
		var file: FileAccess = FileAccess.open(identity_path, FileAccess.READ)
		player_id = file.get_as_text().strip_edges() # assume for just one line id for now rn?
		file.close()
		
		print_debug("[IDENTITY] loaded existing player_id", player_id)
		
	else:
		player_id = generate_player_id()
		
		var file: FileAccess = FileAccess.open(identity_path, FileAccess.WRITE)
		file.store_string(player_id)
		file.close()
		
		print_debug(
			"[IDENTITY] generated new player id: ", 
			player_id, 
			" |which is saved to: ", 
			identity_path)
			
func generate_player_id() -> String:
	"""
	Generate random UUID, might used for being saved to a file. Player identifier.
	which currently used to tell server who is in front of one executing game exe.
	"""
	var some_UUID: String = str(ResourceUID.create_id()) # borrowed godot resourceUID generation method
	return some_UUID
