extends Unit
class_name PlayerUnit

@onready
var state_label: Label = $StateLabel

@onready
var state_machine: StateMachine = $StateMachine

@export
var movement_speed: float = 100


func _ready() -> void:
	state_machine.init(self)
	
func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)
	
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)
