extends Node

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
		
			
		# How many packets waiting in ws stream..
		var available_packets_count: int = socket.get_available_packet_count()
		
		# print("in _process(), Packets waiting: ", available_packets_count)
			
		# if this client ever receives a packet back..
		if available_packets_count > 0:
			#  retrieve one packet
			var received_packet: PackedByteArray = socket.get_packet()
			var received_message: String = received_packet.get_string_from_utf8()
			
			print("Godot received raw str:", received_message)
			
			# try? parse it to dictionary (parse_string() to godot Variant)
			var parsed_packet: Variant = JSON.parse_string(received_message)
			
			if parsed_packet == null:
				print_debug("Godot received invalid JSON")
				return
			
			# if packet exist, not null, confirm it being a godot dict instead of some other Variant..
			if not parsed_packet is Dictionary:
				print_debug("godot received valid json packet, but is not a dictionary")
				push_error("Something wrong here")
				return
				
			# the json validation is teested done
			var received_dict : Dictionary = parsed_packet
			
			print_debug("the dictionary godot received from ws stream: ", received_dict)
			
			# -----
			# determine packet type
			# -----
		
			var packet_type: Variant = received_dict.get("type")
			
			# =====
			# CHAT PACKET RELATED
			# =====
			if packet_type == "chat":
				print_debug("godot received a CHAT packet")
			
				# retrieve "data"
				var data: Variant = received_dict.get("data")
				
				# data section in main json, should be itself a dict
				if not data is Dictionary:
					print_debug(" 'data' field in the main json is not itself a dictionary. ")
					push_error("Malformed chat packet detected here")
					return
					
				var chat_data: Dictionary = data
				
				# retrieve sender then
				var sender: Variant = chat_data.get("sender")
				
				if not sender is String:
					print_debug(" 'sender' field in the 'data' field is not a String")
					push_error("Malformed inside information here")
					return
					
				var chat_sender: String = sender
				
				# retrieve message then
				var message: Variant = chat_data.get("message")
				
				if not message is String:
					print_debug(" 'message' field in the 'data' field is not a String ")
					push_error("Malformed inside information here")
					return
					
				var chat_message: String = message
				
				# -----
				# All info for 'chat' typed message extracted besides validation
				
				print_debug("godot received chat packet, unpacking info below: \n")
				print("[GODOT][CHAT] sender:", chat_sender)
				print("message: ", chat_message)
					
				
