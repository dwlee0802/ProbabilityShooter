extends State

@export
var idle_state: State
@export
var move_state: State
@export
var attack_state: State
@export
var unconscious_state: State

var target_item: DroppedItem


func enter() -> void:
	super()
	parent.state_label.text = "Pick up"

func process_input(_event: InputEvent) -> State:
	return null

func process_frame(_delta: float) -> State:
	return null

func process_physics(_delta: float) -> State:
	# check if target item is within range
	# if it is, pick it up
	
	return null
