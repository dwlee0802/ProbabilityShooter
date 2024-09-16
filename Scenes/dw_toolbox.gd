extends Node
class_name DW_ToolBox


static func RemoveAllChildren(node: Node):
	if node == null:
		return
		
	var children = node.get_children()
	for item in children:
		item.queue_free()

## assumes that count is not larger than list if duplicates is true
static func PickRandomNumber(list, count: int, duplicates: bool = true):
	var output = []
	if duplicates:
		for i in range(count):
			output.append(list.pick_random())
	else:
		list.shuffle()
		return list.slice(0,count)

static func TrimDecimalPoints(num: float, count: int) -> float:
	var decnum: float = pow(10, count)
	return int(num * decnum) / decnum

## reads all resources in path. Assumes all files in directory path are resources
static func ImportResources(path: String, filter: Callable = func do_nothing(_target): return true, print_output: bool = false) -> Array:
	var file_path: String = path + "/"
	var dir = DirAccess.open(file_path)
	dir.list_dir_begin()
	var filename: String = dir.get_next()
	
	var output = []
	
	var disabled_count: int = 0
	
	while filename != "":
		var fullpath: String = path + filename
		
		if '.tres.remap' in fullpath:
			fullpath = fullpath.trim_suffix('.remap')
			
		var newthing: Resource = load(fullpath)
		if filter.call(newthing):
			output.append(newthing)
		else:
			disabled_count += 1
			
		filename = dir.get_next()
		
	if print_output:
		print("***Importing Resource files***")
		print("Imported " + str(output.size()) + " resource files.")
		for item in output:
			print(item)
		print("Excluded " + str(disabled_count) + " resource files.")
		print("******\n")
	return output
