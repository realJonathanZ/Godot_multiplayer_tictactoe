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
				
			# the json validation is teested done
			var received_dict : Dictionary = parsed_packet
			
			print_debug("the dictionary godot received from ws stream: ", received_dict)
			
			# determine the packet type (i.e. chat? join_room? other?)
			var packet_type: Variant = received_dict.get("type")
			
			# verify if it is of type "chat" specifically for the received packet
			if packet_type == "chat":
				print_debug("godot received a CHAT packet")
				
				
			
			
			
			
			
