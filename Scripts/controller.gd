class_name Controller
extends Node2D

var model:Model
var view:View
var turn_label : Label # reference to a label node

## Before the game starts, do a bunch of things to connect MVC together.
func _ready() -> void:
	turn_label = $UIturnLabel # denotes reference to a label node, which is in-game-label showing whose turn it currently is.
	model = Model.new()
	view = $TileMapLayer
	view.set_model(model, turn_label) # relation between view and model
	# Let the view notify controller when <signal omited> of "cell_selected" from view.gd
	view.connect("cell_selected", Callable(self, "_on_cell_selected")) # relation between view and controller
	
	
func _on_cell_selected(coord: Vector2i):
	model.make_move(coord) # relation between controller and model
	
