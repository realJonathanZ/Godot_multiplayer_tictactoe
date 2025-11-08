class_name Controller
extends Node2D

var model:Model
var view:View

func _ready() -> void:
	view = $TileMapLayer
	view.connect("cell_selected", tile_selected)
	model = Model.new(5, view)
	view.set_model(model)
	model.reset_board()
	
	
func tile_selected(coord:Vector2i) -> void:
	model.toggle_tile(coord)
