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
	
func _on_cell_selected(coord: Vector2i):
	MessageBus.local_move_requested.emit(coord)
	
