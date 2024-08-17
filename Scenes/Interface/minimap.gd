extends Control
class_name Minimap

static var marker_scene = preload("res://Scenes/Interface/map_marker.tscn")

var enemy_markers: Control

@export
## max distance minimap points are away from center irl
var detection_range: int = 20000:
	set(newval):
		detection_range = newval
		print("Minimap detection range set to " + str(newval))
## radius of actual minimap display
var minimap_radius: int = 98

func _ready() -> void:
	enemy_markers = $Background/EnemyMarkers
	# premake markers
	for i in range(100):
		var new_marker: Control = marker_scene.instantiate()
		enemy_markers.add_child(new_marker)
		new_marker.modulate = Color.RED
		new_marker.position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randi_range(1, 99)
	
	#var test_positions = []
	#for i in range(2):
		#test_positions.append(Vector2.RIGHT.rotated(randf_range(0, TAU)) * randi_range(1, 20000))
	#
	#update_markers(Vector2.ZERO, test_positions)
	
## takes in vector for center point and an array of vectors for markers
## all in global space
## recalculate the relative position vectors from center point and move markers there
func update_markers(center: Vector2, points: PackedVector2Array, colors: PackedColorArray) -> void:
	for i: int in range(points.size()):
		var local_pos: Vector2 = points[i] - center
		# reduce length to fit in range
		#print("before: " + str(local_pos))
		var dist_ratio: float = local_pos.length() / detection_range
		local_pos = local_pos.normalized() * dist_ratio * minimap_radius
		#print("after: " + str(local_pos))
		
		# set marker position. if count exceeds premade markers, make more
		var current_marker: Control
		if i >= enemy_markers.get_child_count():
			var new_marker: Control = marker_scene.instantiate()
			enemy_markers.add_child(new_marker)
			current_marker = new_marker
		else:
			current_marker = enemy_markers.get_child(i)
			
		current_marker.position = local_pos
		current_marker.visible = true
		current_marker.modulate = colors[i]
	
	for i: int in range(points.size(), enemy_markers.get_child_count()):
		enemy_markers.get_child(i).visible = false
