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
		#set_process(false) # don't eun my _process again and again after connected.
			
			
