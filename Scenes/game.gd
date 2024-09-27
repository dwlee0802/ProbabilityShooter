extends Node2D
class_name Game

@onready
var user_interface: UserInterface = $UserInterface

var enemy_scene = preload("res://Scenes/Units/enemy_unit.tscn")

var units = []

@onready
var projectiles: Node2D = $Projectiles

@onready
var shootables: Node2D = $Shootables

var time_since_start: float = 0
var pause: bool = false
@export
var spawn_radius: int = 1000

## dictionary<Mutation, int level> to store mutations
var mutations = {}
static var mutation_data
var mutation_options
@onready
var spawner_component: EnemySpawnerComponent = $EnemySpawnerComponent
@onready
var mutation_timer: Timer = $MutationTimer
## Time between mutation roulette runs
@export
var mutation_cooldown: float = 30
##endregion

## node to hold enemy units
@onready
var enemies: Node2D = $Enemies
var kill_count: int = 0
@onready
var blood_splatter: Node2D = $BloodSplatter

## resource system
#@export
#var resource_stock: int = 0
#@onready
#var resource_node: Node2D = $Resources

@export
var safe_zone_radius: float = 2000.0

@export_category("Debugging")
@export
var no_game_over: bool = false

static var upgrade_options
@onready
var upgrade_timer: Timer = $UpgradeTimer
@export
var upgrade_select_time_limit: float = 15.0

## shootable objects
var dynamite_shootable = preload("res://Scenes/Shootables/dynamite.tscn")


static func _static_init():
	var is_diabled = func(data):
		return !data.disabled
		
	upgrade_options = DW_ToolBox.ImportResources("res://Data/Items/", is_diabled, true)
	mutation_data = DW_ToolBox.ImportResources("res://Data/Mutations/", is_diabled, true) 

# Called when the node enters the scene tree for the first time.
func _ready():
	# delegate front end management to input manager
	$InputManager.game = self
	
	set_safezone_sprite(safe_zone_radius)
	
	units = $PlayerUnits.get_children()
	user_interface.core_health_bar.set_max(units[0].max_health_points)
	user_interface.core_health_bar.change_value(units[0].health_points, true)
	user_interface.core_health_label.text = "HP: " + str(units[0].health_points)
	#InputManager._select_unit(units[0])
	bind_selected_unit_signals()
	
	# set minimap parameters
	user_interface.minimap.detection_range = spawn_radius
	
	# connect mutation timer
	mutation_timer.timeout.connect(on_mutation_timer_timeout)
	mutation_timer.start(mutation_cooldown)
	user_interface.mutation_roulette.option_selected.connect(on_mutation_selected)
	
	spawner_component.stats_changed.connect(user_interface.update_enemy_spawn_info.bind(spawner_component))
	user_interface.update_enemy_spawn_info(spawner_component)
	
	# spawn first wave
	spawner_component = $EnemySpawnerComponent
	spawner_component.on_spawn_timer_timeout()
	#spawn_wave()
	
	#user_interface.update_unit_shortcut_labels(InputManager.camera.get_screen_center_position(), units)
	user_interface.restart_button.pressed.connect(start)
	
	for unit: PlayerUnit in units:
		#unit.picked_up_item.connect(user_interface.show_item_info)
		unit.experience_changed.connect(on_experience_changed)
		unit.added_experience.connect(user_interface.make_exp_popup)
		unit.was_selected.connect(bind_selected_unit_signals)
		unit.level_increased.connect(on_level_up)
		unit.stats_changed.connect(user_interface.update_bullet_menu)
		unit.stats_changed.connect(user_interface.update_bullet_generation_info_menu)
		unit.was_selected.connect(user_interface.update_bullet_menu)
		unit.actioned.connect(user_interface.update_bullet_menu)
		unit.weapon_one.bullets_changed.connect(user_interface.update_bullet_menu)
		unit.weapon_two.bullets_changed.connect(user_interface.update_bullet_menu)
		unit.weapon_one.reload_started.connect(
			user_interface.update_reload_marker.bind(user_interface.weapon_one_active_reload, unit.weapon_one))
		unit.weapon_two.reload_started.connect(
			user_interface.update_reload_marker.bind(user_interface.weapon_two_active_reload, unit.weapon_two))
	
	# randomly place dynamite on the map
	for i in range(10):
		var new_shootable: Shootable = dynamite_shootable.instantiate()
		new_shootable.global_position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randi_range(2000, spawn_radius)
		shootables.add_child(new_shootable)
		
	user_interface.update_bullet_menu(units[0].weapon_one, units[0].weapon_two)
	user_interface.update_bullet_generation_info_menu(units[0].bullet_generator_component)
	
	# auto select upgrade option if timeout
	upgrade_timer.timeout.connect(on_upgrade_timeout)
	user_interface.upgrade_timer = upgrade_timer
	
func _process(_delta):
	InputManager.camera.scale_unit_shortcut_label(units)
	InputManager.camera.scale_health_label(enemies.get_children())
	
	if !pause:
		time_since_start += _delta
	user_interface.game_time_label.text = str(int(time_since_start)) + " s"
	
	# update minimap
	if InputManager.selected_unit:
		var points: PackedVector2Array = PackedVector2Array()
		var color_arr: PackedColorArray = PackedColorArray()
		# add player units
		#for unit: PlayerUnit in units:
			#points.append(unit.global_position)
			#color_arr.append(unit.temp_color)
			
		# add camera
		#points.append(CameraControl.camera.global_position)
		#color_arr.append(Color.GREEN_YELLOW)
		
		for enemy: EnemyUnit in enemies.get_children():
			points.append(enemy.global_position)
			color_arr.append(Color.RED)
		user_interface.minimap.update_markers(InputManager.selected_unit.global_position, points, color_arr)
		
		var bullet_points = []
		var bullet_color_arr = []
		for bullet: Projectile in projectiles.get_children():
			bullet_points.append(bullet.global_position)
			bullet_color_arr.append(Color.WHITE)
			
		user_interface.minimap.update_bullet_markers(InputManager.selected_unit.global_position, bullet_points, bullet_color_arr)
		
		var shootable_points = []
		var shootable_color_arr = []
		for shootable: Shootable in shootables.get_children():
			shootable_points.append(shootable.global_position)
			shootable_color_arr.append(Color.ORANGE)
			
		user_interface.minimap.update_shootable_markers(InputManager.selected_unit.global_position, shootable_points, shootable_color_arr)
	else:
		user_interface.minimap.update_markers(InputManager.selected_unit.global_position, [], [])
		
	## Mutation timer
	if !mutation_timer.is_stopped():
		user_interface.mutation_roulette.mutation_time_label.text = "Next Mutation in: " + str(int(mutation_timer.time_left) + 1) + "s"
		if mutation_timer.time_left < 10:
			user_interface.mutation_roulette.mutation_time_label.self_modulate = Color.YELLOW
		else:
			user_interface.mutation_roulette.mutation_time_label.self_modulate = Color.WHITE
	
	## Click sound
	if Input.is_action_just_pressed("action_one") or Input.is_action_just_pressed("action_two"):
		$ClickSoundPlayer.play()
	
	## Camera panning with cursor
	var local_mouse_pos: Vector2 = InputManager.selected_unit.get_local_mouse_position()
	CameraControl.camera.position = local_mouse_pos.normalized()
	# limit the amount of camera position offset from cursor
	CameraControl.camera.position *= min(local_mouse_pos.length()/7, 300)
	
	## Active reload UI
	if InputManager.selected_unit.weapon_one.reload_timer.is_stopped():
		user_interface.weapon_one_active_reload.visible = false
	else:
		user_interface.weapon_one_active_reload.visible = true
		var timer: Timer = InputManager.selected_unit.weapon_one.reload_timer
		user_interface.weapon_one_active_reload.value = int((timer.wait_time - timer.time_left) / (timer.wait_time) * 100)
		if InputManager.selected_unit.weapon_one.active_reload_failed:
			user_interface.weapon_one_active_reload.self_modulate = Color.RED
		else:
			user_interface.weapon_one_active_reload.self_modulate = Color.WHITE
	
	if InputManager.selected_unit.weapon_two.reload_timer.is_stopped():
		user_interface.weapon_two_active_reload.visible = false
	else:
		user_interface.weapon_two_active_reload.visible = true
		var timer: Timer = InputManager.selected_unit.weapon_two.reload_timer
		user_interface.weapon_two_active_reload.value = int((timer.wait_time - timer.time_left) / (timer.wait_time) * 100)
		if InputManager.selected_unit.weapon_two.active_reload_failed:
			user_interface.weapon_two_active_reload.self_modulate = Color.RED
		else:
			user_interface.weapon_two_active_reload.self_modulate = Color.WHITE
	
	## Player outside safe zone
	if InputManager.selected_unit.global_position.length() > safe_zone_radius:
		InputManager.selected_unit.receive_hit(_delta * 10)
	
func enemy_killed()-> void:
	kill_count += 1
	user_interface.kill_count_label.text = str(int(kill_count)) + " Kills"
	user_interface.kill_count_animation.play("killcount_up")
	user_interface.enemy_count_label.text = "Enemy Count: " + str(enemies.get_child_count())
	
func add_enemy(newEnemy: EnemyUnit) -> void:
	newEnemy.game_ref = self
	enemies.add_child(newEnemy)
	if InputManager.selected_unit != null:
		newEnemy.position = InputManager.selected_unit.global_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * spawn_radius
	else:
		newEnemy.position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * spawn_radius
	newEnemy.on_death.connect(enemy_killed)
	
	user_interface.enemy_count_label.text = "Enemy Count: " + str(enemies.get_child_count())
	
func game_over() -> void:
	if no_game_over:
		return
		
	print("***GAME OVER***")
	spawner_component.spawn_timer.stop()
	mutation_timer.stop()
	user_interface.mutation_roulette.stop_roulette()
	
	# remove all remaining enemy units
	remove_child(enemies)
	enemies.queue_free()
	enemies = Node2D.new()
	add_child(enemies)
	
	# remove all remaining projectiles
	call_deferred("remove_child", projectiles)
	projectiles.queue_free()
	projectiles = Node2D.new()
	add_child(projectiles)
	
	# remove all remaining shootables
	remove_child(shootables)
	shootables.queue_free()
	shootables = Node2D.new()
	add_child(shootables)
	
	user_interface.show_game_over_screen(false)
	pause = true

func victory() -> void:
	if no_game_over:
		return
		
	print("***VICTORY***")
	# remove all remaining enemy units
	remove_child(enemies)
	enemies.queue_free()
	enemies = Node2D.new()
	add_child(enemies)
	
	# remove all remaining projectiles
	remove_child(projectiles)
	projectiles.queue_free()
	projectiles = Node2D.new()
	add_child(projectiles)
	
	# remove all remaining shootables
	remove_child(shootables)
	shootables.queue_free()
	shootables = Node2D.new()
	add_child(shootables)
	
	user_interface.show_game_over_screen(true)
	pause = true
	#change_resource(0)
	
func start() -> void:
	print("***START GAME***")
	
	# remove leftover resources
	#DW_ToolBox.RemoveAllChildren(resource_node)
	# remove blood splatter
	DW_ToolBox.RemoveAllChildren(blood_splatter)
	
	spawner_component.reset_stats()
	
	# spawn first wave
	spawner_component.on_spawn_timer_timeout()
	#spawn_wave()
	#wave_timer.start(time_between_waves)
	#linear_spawn_timer.start(linear_spawn_time)
	#elite_timer.start(elite_spawn_time)
	
	mutation_timer.start(mutation_cooldown)
	user_interface.mutation_roulette.mutation_time_label.visible = true

	user_interface.game_over_ui.visible = false
	time_since_start = 0
	kill_count = 0
	user_interface.kill_count_label.text = "Kills: " + str(kill_count)
	
	pause = false
	for unit: PlayerUnit in units:
		unit.reset_health()
		unit.reset_items()
		unit.reset_exp()
		unit.reload_action()
		unit.global_position = Vector2.ZERO
		
	spawner_component.reset_stats()

	# randomly place dynamite on the map
	for i in range(5):
		var new_shootable: Shootable = dynamite_shootable.instantiate()
		new_shootable.global_position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randi_range(2000, spawn_radius)
		shootables.add_child(new_shootable)
	
	user_interface.update_bullet_menu()

func on_core_hit() -> void:
	user_interface.core_hit_effect.play("RESET")
	user_interface.core_hit_effect.play("core_hit_animation")
	user_interface.core_health_bar.change_value(InputManager.selected_unit.health_points)
	user_interface.core_health_label.text = "HP: " + str(int(InputManager.selected_unit.health_points))

#func change_resource(amount: int) -> void:
	#resource_stock += amount
	#resource_stock = max(resource_stock, 0)
	#print("changed resource by " + str(amount))
	#user_interface.resource_label.text = "Resource: " + str(resource_stock)

## called when selected unit is changed
## bind ui element update to selected unit signals
func bind_selected_unit_signals() -> void:
	if InputManager.selected_unit != null:
		var unit: PlayerUnit = InputManager.selected_unit
		user_interface.experience_bar.set_max(unit.required_exp_amount(unit.current_level))
		user_interface.experience_bar.change_value(unit.experience_gained, true)
		user_interface.experience_label.text = "LV " + str(unit.current_level) + "  " + str(unit.experience_gained) + "/" + str(unit.required_exp_amount(unit.current_level))
		
		if unit.is_level_up_ready():
			if unit.upgrade_options == null or unit.upgrade_options.size() == 0:
				unit.upgrade_options = get_upgrade_options()
				
			user_interface.show_upgrade_menu()
		else:
			user_interface.level_up_menu.visible = false
			
		InputManager.selected_unit.knocked_out.connect(game_over)
		InputManager.selected_unit.was_attacked.connect(on_core_hit)
		user_interface.core_health_bar.set_max(InputManager.selected_unit.max_health_points)
		unit.health_changed.connect(on_core_hit)
			
func on_experience_changed() -> void:
	if InputManager.selected_unit != null:
		var unit: PlayerUnit = InputManager.selected_unit
		user_interface.experience_bar.change_value(unit.experience_gained, true)
		user_interface.experience_label.text = "LV " + str(unit.current_level) + "  " + str(unit.experience_gained) + "/" + str(unit.required_exp_amount(unit.current_level))
		
		if !user_interface.level_up_menu.visible and unit.is_level_up_ready():
			unit.upgrade_options = get_upgrade_options()
			user_interface.show_upgrade_menu()
			unit.level_up_animation.play("level_up")
			unit.level_up_sound.playing = true
			await unit.level_up_animation.animation_finished
			# start upgrade option selection timer
			upgrade_timer.start(15)
			get_tree().paused = true

func on_level_up() -> void:
	if InputManager.selected_unit != null:
		var unit: PlayerUnit = InputManager.selected_unit
		user_interface.experience_bar.set_max(unit.required_exp_amount(unit.current_level))
		user_interface.experience_bar.change_value(unit.experience_gained, true)
		user_interface.experience_label.text = "LV " + str(unit.current_level) + "  " + str(unit.experience_gained) + "/" + str(unit.required_exp_amount(unit.current_level))
		unit.upgrade_options = get_upgrade_options()
		get_tree().paused = false
		
func get_upgrade_options(count: int = 4):
	var output = []
	for i in range(count):
		output.append(Game.upgrade_options.pick_random())
	return output

func on_upgrade_timeout():
	user_interface.upgrade_option_selected(InputManager.selected_unit.upgrade_options.pick_random())
	
func pause_time(duration: float) -> void:
	get_tree().paused = true
	await get_tree().create_timer(duration).timeout
	get_tree().paused = false

#region Mutation System
func add_mutation(item: Mutation) -> void:
	# if it exists, increase level
	if mutations.find_key(item):
		item.on_exit(spawner_component, mutations[item])
		mutations[item] += 1
		item.on_enter(spawner_component, mutations[item])
	else:
		mutations[item] = 1
		item.on_enter(spawner_component, mutations[item])
	
	# reload ui
	user_interface.update_enemy_spawn_info(spawner_component)
		
func reset_mutations() -> void:
	for item: Mutation in mutations.keys():
		item.on_exit(spawner_component, mutations[item])
	mutations.clear()
	
func get_mutation_options(count: int = 4):
	var output = []
	for i in range(count):
		output.append(Game.mutation_data.pick_random())
	return output

# show mutation selection ui
# start mutation roulette
func on_mutation_timer_timeout():
	# show mutation selection ui
	user_interface.mutation_roulette.start_roulette(Game.mutation_data)

func on_mutation_selected(option: Mutation):
	mutation_timer.stop()
	add_mutation(option)
	mutation_timer.start(mutation_cooldown)
	
#endregion

func set_safezone_sprite(radius: float) -> void:
	var sprite: Sprite2D = $Safezone
	sprite.scale = Vector2(radius * 2 / 486.0, radius * 2 / 486.0)
