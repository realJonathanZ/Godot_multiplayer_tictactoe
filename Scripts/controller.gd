class_name Controller
extends Node

@export var view:View
@export var turn_label : Label # reference to a label node

var model:Model

## Before the game starts, do a bunch of things to connect MVC together.
func _ready() -> void:
	model = Model.new()
	view.set_model(model) # relation between view and model
	# Let the view notify controller when <signal omited> of "cell_selected" from view.gd
	view.cell_selected.connect(self._on_cell_selected) # signal wiring
	
	# if Message bus tells that this system receives some package of type Dictionary then..
	# do something in call back, in [controller?]
	MesB.network_message_received.connect(_on_network_message_received)
	
func _on_cell_selected(coord: Vector2i):
	#print_debug("about to execute _on_cell_selected..")
	MesB.local_move_requested.emit(coord)
	
func _on_network_message_received(parsed_packet: Dictionary) -> void:
	print("[Controller] received through MessageBus: ", parsed_packet)
