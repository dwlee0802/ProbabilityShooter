extends Node
class_name RunHistoryComponent

## takes in a dictionary of the data of a run and stores it
func save_run_data(run_data: Dictionary) -> void:
	var run_history = get_run_history()
	
	var save_file = FileAccess.open("user://runs_history.save", FileAccess.WRITE)
	run_history.append(run_data)
	
	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(run_history)
	print(json_string)
	
	# Store the save dictionary as a new line in the save file.
	save_file.store_string(json_string)
	save_file.close()
	
	print("****Saved run data " + run_data["timestamp"] + "****")

func get_run_history() -> Array:
	var save_file = FileAccess.open("user://runs_history.save", FileAccess.READ)
	
	var json_string: String = save_file.get_as_text()
	
	var save_data = JSON.parse_string(json_string)
	
	save_file.close()
	
	return save_data
