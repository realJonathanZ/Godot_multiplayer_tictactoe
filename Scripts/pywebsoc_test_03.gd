# This test script, applied on a blank node(type=node2d), shows an print_debug example of:
# 1. send a join_room packet to the pywebsoc server
# 2. reeive and process(=debugprint) the room_joined info
# 3. Maintain a persistent player identity
# 4. Given player ability to send message out and display incoming other users' message in testing UI.





extends Node2D

var socket: WebSocketPeer = WebSocketPeer.new()

# has already pressed that join room button??
var has_joined_room: bool = false

# test usaged room id included in packet sent out
var room_id: String = "111"

# test usage used. Player identifier. which I want: 
# each installation/user-data directory gets one persistent player ID.
# answer when server asks "WHO you are"
# persistent player identity stored at "user://player_id.txt"
var player_id: String = ""

# test usage used, displaying later on UI later. (UUID relevent)
# not intended to be unique
var display_name: String = "BRUH_PlAYER_JO"

## ====
## (Testing) UI
## ====

@export_category("subControl")

@export var join_form_control: Control # root control node for join room
@export var chat_window_control: Control # root control node for chat room

@export_category("JoinRoom Test UI")

@export var player_id_input: LineEdit # <- although the user id is generated from in-script function,...
# .. user can still change the player id if he wants to, (only for test purpose)

@export var player_display_name_input: LineEdit
@export var player_room_id_input: LineEdit
@export var join_room_button: Button

@export_category("Chat Test UI")

@export var player_chat_log: RichTextLabel
@export var player_chat_msg_line_edit: LineEdit
@export var send_msg_button: Button




## ====
## Godot lifecycle
## ====

func _ready():
	# join button signal
	self.join_room_button.pressed.connect(self._on_join_room_button_pressed)
	
	initialize_player_identity()
	
	var error: Error = socket.connect_to_url("ws://localhost:8765")
	
	if error != OK:
		print("Websocket connection failed: ", error)
	else:
		print("Conecting to customized pywebsoc server in ready")
		
func _process(_delta):
	# for every _process, poll current connection state
	socket.poll()
		
	var state: WebSocketPeer.State = socket.get_ready_state()
		
	if state == WebSocketPeer.STATE_OPEN:
			
		# ---
		# process incoming packets
			
		process_incoming_packets()

## ====
## UI callback
## ====

func _on_join_room_button_pressed() -> void:
	send_join_room_packet()



## --
## outgoing packet(s)
## --

func send_join_room_packet() -> void:
	"""
	Construct and send a join_room packet to pywebsoc server.
	Packet including:
		-1: Which room this client wants to join. 
		-2: Which player is joining. (player with persistent identity)
		-3: What display name that player uses.
		
	The info included might, on test purpose, being modified from some places.
	"""
	
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		print_debug("[JOIN_ROOM]DENIED. Websocket is NOT OPEN.")
		return
	
	if has_joined_room:
		print_debug("already sent this join request. In this test only send one join request.(via button)")
		return
	
	# read current test values from UI user inputs.. (instead of sending raw default in it.)
	
	self.room_id = player_room_id_input.text.strip_edges()
	self.player_id = player_id_input.text.strip_edges()
	self.display_name = player_display_name_input.text.strip_edges()
	
	# dump in packet
	var packet: Dictionary = {
		"type": "join_room",
		"data": {
			"room_id": self.room_id,
			"player_id": self.player_id,
			"display_name": self.display_name,	
		}
	}
	
	# before sending
	var json_message: String = JSON.stringify(packet)
	
	# send to server
	socket.send_text(json_message)
	
	self.has_joined_room = true
	
	print("Godot sent one join_room packet, sending info is listed below:")
	print("    player_id: ", player_id)
	print("    display_name: ", display_name)
	print("    room_id: ", room_id)
			
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
	
	# retrieve 'player_id' field
	
	var a_player_id: Variant = room_joined_data.get("player_id")
	
	if not a_player_id is String:
		print_debug(" 'player_id' field inside 'data' field is not a String.")
		push_error("Malformed player_id data detected here.")
		return
		
	var joined_player_id: String = a_player_id
	
	# retrieve 'display_name' field
	var a_display_name: Variant = room_joined_data.get("display_name")
	
	if not a_display_name is String:
		print_debug("'display' field inside 'data' field is not a String")	
		push_error("Malformed display_name detected here.")
		return
	
	var joined_display_name: String = a_display_name
	
	## successfully proceed to room_joined packet
	
	print_debug(
		"godot received room_joined packet, unpacking info below: \n"
	)
	
	print("[GODOT][ROOM JOINED] player_id: ", joined_player_id)
	print("[GODOT][ROOM JOINED] display_name: ", joined_display_name)
	print("[GODOT][ROOM JOINED] joined room: ", joined_room_id)
	
## =====
## Player unique identity.
## * should be preserved around file at "user://player_id.txt"
## =====

func initialize_player_identity() -> void:
	"""
	intialize id, on context of this running godot client instance.
	id is either initialzed, or, obtained from user://.... a location.
	"""
	
	# where the player(who are executing this game exe)'s identity info is stored.
	var identity_path: String = "user://player_id.txt"  
	
	## if existing identity
	
	if FileAccess.file_exists(identity_path):
		var file: FileAccess = FileAccess.open(identity_path, FileAccess.READ)
		player_id = file.get_as_text().strip_edges() # assume for just one line id for now rn?
		file.close()
		
		print_debug("[IDENTITY] loaded existing player_id: ", player_id)
		
	## if first-time identity
	
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
	
## ====
## Player ID generation
## ====
		
func generate_player_id() -> String:
	"""
	Generate a unique player identifier, might used for being saved to a file. Player identifier.
	which currently used to tell server who is in front of one executing game exe.
	"""
	var some_UUID: String = str(ResourceUID.create_id()) # borrowed godot resourceUID generation method
	return some_UUID
