extends Node

var socket: WebSocketPeer = WebSocketPeer.new()

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
		print("checked in _process with current connection status to be: connected")
		
		var packet: Dictionary = {
			"type": "chat",
			"data": {
				"sender": "Godot",
				"message": "message from godot client"
			}
		} 
		
		socket.send_text(JSON.stringify(packet))
		
		#set_process(false) # don't run my _process again and again after connected.
			
			
