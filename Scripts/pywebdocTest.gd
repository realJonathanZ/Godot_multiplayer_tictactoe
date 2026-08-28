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
	socket.poll()
		
	var state = socket.get_ready_state()
		
	if state == WebSocketPeer.STATE_OPEN:
		
		if not self.has_sent_message:
			var packet: Dictionary = {
				"type": "chat",
				"data": {
					"sender": "Godot",
					"message": "message from godot client"
				}
			} 
			
			var json_message: String = JSON.stringify(packet)
			
			socket.send_text(json_message)
			
			print("Godot sent one chat packet")

			has_sent_message = true # for not sending another pack		
		
			
		# How many packets waiting in ws stream..
		var available_packets_count: int = socket.get_available_packet_count()
		
		print("in _process(), Packets waiting: ", available_packets_count)
			
		# if this client ever receives a message back..
		if available_packets_count > 0:
			var received_packet: PackedByteArray = socket.get_packet()
			var received_message: String = received_packet.get_string_from_utf8()
			
			print("Godot received:", received_message)
			
			
			
