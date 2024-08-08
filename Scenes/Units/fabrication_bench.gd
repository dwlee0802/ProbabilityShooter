extends Interactable
class_name FabricationBench

var wait_time: float = 1
var time_holder: float = 0

@export
var add_damage: int = 0
@export
var add_projectile_speed: int = 0

@onready
var progress_bar: DelayedProgressBar = $HealthBar

@onready
var item_sprite: TextureRect = $ItemImage
@onready
var slot_timer: Timer = $Timer
var current_item: ItemData = null

static var item_data_list = []
## stop and pick current item after this number of rolls
static var max_roll_count: int = 10
static var slot_roll_seconds: float = 0.3
var current_roll_count: int = 0
var is_rolling: bool = false
var dropped_item_scene = preload("res://Scenes/Units/dropped_item.tscn")


static func _static_init():
	FabricationBench.item_data_list = DW_ToolBox.ImportResources("res://Data/Items/", true)

func _ready():
	progress_bar.set_max(wait_time)
	progress_bar.change_value(0, true)
	progress_bar.visible = false
	slot_timer.timeout.connect(load_new_item)
	
# called every frame by the interactor
# returns false if process is finished
# if called when slot machine is rolling, pick that item
func active(_delta: float, _user: PlayerUnit) -> bool:
	if is_rolling:
		# pick current item and return it
		print("picked " + current_item.item_name)
		slot_timer.stop()
		is_rolling = false
		item_sprite.visible = false
		make_dropped_item()
		
		return false
		
	progress_bar.change_value(time_holder, true)
	time_holder += _delta
	if time_holder >= wait_time:
		print("complete")
		start_slot_machine()
		
		return false
	return true
	
func on_activate():
	progress_bar.visible = true
	time_holder = 0
	progress_bar.change_value(wait_time, true)
	
func on_exit():
	time_holder = 0
	progress_bar.visible = false

func start_slot_machine():
	is_rolling = true
	progress_bar.visible = false
	item_sprite.visible = true
	current_roll_count = 0
	load_new_item()
	slot_timer.start(slot_roll_seconds)

func load_new_item() -> void:
	var new_item = FabricationBench.item_data_list.pick_random()
	while true:
		if new_item != current_item:
			current_item = new_item
			break
		new_item = FabricationBench.item_data_list.pick_random()
		
	#item_sprite.texture = current_item.icon
	item_sprite.get_node("NameLabel").text = current_item.item_name
	item_sprite.self_modulate = current_item.color
	current_roll_count += 1
	if current_roll_count == max_roll_count:
		slot_timer.stop()
		print("time out. picked " + current_item.item_name)
		item_sprite.visible = false
		is_rolling = false
		make_dropped_item()

func make_dropped_item():
	var new_item: DroppedItem = dropped_item_scene.instantiate()
	new_item.set_data(current_item)
	new_item.global_position = global_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * randi_range(300, 600)
	get_tree().root.add_child(new_item)
	
