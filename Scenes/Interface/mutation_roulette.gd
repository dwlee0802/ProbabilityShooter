extends Control
class_name Roulette

var options = []
var roulette_timer: Timer = Timer.new()
@export
var option_wait_time: float = 2.0
## max rolls generated option is auto selected
@export
var max_rolls: int = 10
var current_count: int = 0
var current_option

@onready
var option_icon: TextureRect = $VBoxContainer/TextureRect
@onready
var option_label: Label = $VBoxContainer/Label

@onready
var selection_animation: AnimationPlayer = $AnimationPlayer

@onready
var mutation_time_label: Label = $MutationTimeLabel

signal option_selected(option)


func _process(_delta: float) -> void:
	if !roulette_timer.is_stopped() and Input.is_action_just_pressed("select_roulette"):
		select_current_option()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	roulette_timer.autostart = false
	roulette_timer.one_shot = true
	add_child(roulette_timer)
	roulette_timer.timeout.connect(on_roulette_timer_timeout)

func on_roulette_timer_timeout() -> void:
	# check if we are at max rolls and select current option if timeout
	if current_count >= max_rolls:
		# choose current option
		select_current_option()
		return
		
	# if we have rolls left, load new option
	load_option(true)
	current_count += 1
	print("Roll count: " + str(current_count))
	
	# start roulette timer again
	roulette_timer.start(option_wait_time)
	return

func start_roulette(_options) -> void:
	print("Starting roulette with " + str(_options.size()) + " options")
	mutation_time_label.visible = false
	$VBoxContainer.visible = true
	
	options = _options
	if options.size() == 0:
		push_warning("No options given for roulette!")
	load_option()
	current_count += 1
	
	roulette_timer.start(option_wait_time)
	
func select_current_option() -> void:
	print("Selected " + str(current_option))
	roulette_timer.stop()
	#selection_animation.play("roulette_selected")
	
	mutation_time_label.visible = true
	$VBoxContainer.visible = false
	
	option_selected.emit(current_option)
	
func load_option(no_duplicates: bool = false) -> void:
	var new_option = options.pick_random()
	if no_duplicates:
		while current_option == new_option:
			new_option = options.pick_random()
			if options.size() == 1:
				break
				
	current_option = new_option
	
	# update ui elements
	option_label.text = str(current_option)
	if current_option.icon != null:
		option_icon.texture = current_option.icon
	# temp color
	option_icon.self_modulate = current_option.color
