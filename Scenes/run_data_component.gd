extends Node
class_name RunHistoryComponent

var file_path: String = "user://runs_history.save"


## takes in a dictionary of the data of a run and stores it
func save_run_data(run_data: Dictionary) -> void:
	var save_data = get_save_data()
	var save_file = FileAccess.open(file_path, FileAccess.WRITE)
	
	save_data["run history"].append(run_data)
	# check best run
	if save_data["run history"][save_data["best index"]].score <= run_data["score"]:
		save_data["best index"] = save_data["run history"].size() - 1
		print("New Best Score: " + str(save_data["run history"][save_data["best index"]].score) + " at index: " + str(save_data["best index"]))
	
	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(save_data)
	print(json_string)
	
	# Store the save dictionary as a new line in the save file.
	save_file.store_string(json_string)
	save_file.close()
	
	print("****Saved run data " + run_data["timestamp"] + "****")

# gets previous saved run history
# returns empty array if file doesn't exist
func get_save_data() -> Dictionary:
	var save_file = FileAccess.open(file_path, FileAccess.READ)
	if !save_file:
		return {
			"run history": [],
			"best index": -1
		}
	
	var json_string: String = save_file.get_as_text()
	
	var save_data = JSON.parse_string(json_string)
	
	save_file.close()
	
	return save_data

func get_best_run():
	var save_data = get_save_data()
	if save_data["best index"] < 0:
		return null
	else:
		return save_data["run history"][save_data["best index"]]
