class_name PlayerIdentity
extends RefCounted

var player_id: String

func _init() -> void:
	player_id = _load_or_create_player_id()
	
func _load_or_create_player_id() -> String:
	"""
	intialize id, on context of this running godot client instance.
	id is either initialzed, or, obtained from user://.... a location.
	"""
	# where the player(who are executing this game exe)'s identity info is stored.
	var identity_path: String = "user://player_id.txt"  
	
	## if existing identity
	if FileAccess.file_exists(identity_path):
		var file: FileAccess = FileAccess.open(identity_path, FileAccess.READ)
		var saved_player_id: String = file.get_as_text().strip_edges() # assume for just one line id for now rn?
		file.close()
		
		print_debug("[IDENTITY] loaded existing player_id: ", saved_player_id)
		return saved_player_id
		
	## if first-time identity
	
	else:
		var new_player_id: String = str(ResourceUID.create_id())
		
		var file: FileAccess = FileAccess.open(identity_path, FileAccess.WRITE)
		file.store_string(new_player_id)
		file.close()
		
		print_debug(
			"[IDENTITY] generated new player id: ", 
			player_id, 
			" |which is saved to: ", 
			identity_path)
			
		return new_player_id
