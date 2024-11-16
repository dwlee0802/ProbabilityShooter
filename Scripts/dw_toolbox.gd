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

### Returns the number with specified number of decimal points as a String
### Adds 0s to the end if decimal points is lower than input count
#static func TrimDecimalPointsString(num: float, count: int) -> String:
	#num = TrimDecimalPoints(num, count)
	#var decimal_part: float = num - int(num)
	## number of decimals already present
	#var decimal_count: int = str(decimal_part).length()
	#if decimal_count != 0:
		#return str(num) + "0".repeat(max(0, count - decimal_count + 2))
	#else:
		#return str(num) + "." + "0".repeat(max(0, count - decimal_count + 1))

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

## Returns a random vector that has x and y values inside the range inputted
static func RandomVector(xmin: float, xmax: float, ymin: float = xmin, ymax: float = xmax) -> Vector2:
	return Vector2(randf_range(xmin, xmax), randf_range(ymin, ymax))
