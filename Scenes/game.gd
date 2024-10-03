extends Node2D
class_name Game

@onready
var user_interface: UserInterface = $UserInterface
@onready
var game_over_screen: GameOverScreen = $GameOverScreen
@onready
var game_paused_screen = $PauseScreen

var enemy_scene = preload("res://Scenes/Units/enemy_unit.tscn")

var player_unit: PlayerUnit

@onready
var stats_component: StatisticsComponent = $StatisticsComponent

@onready
var projectiles: Node2D = $Projectiles
@onready
var casings: Node2D = $Casings
@onready
var shootables: Node2D = $Shootables

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
@export
var mutation_disabled: bool  = false
##endregion

## node to hold enemy units
@onready
var enemies: Node2D = $Enemies
@onready
var blood_splatter: Node2D = $BloodSplatter

## resource system
#@export
#var resource_stock: int = 0
#@onready
#var resource_node: Node2D = $Resources

@export
var safe_zone_radius: float = 2000.0

@export_category("Weapon Colors")
@export_color_no_alpha
var weapon_one_color: Color = Color.DARK_ORANGE
@export_color_no_alpha
var weapon_two_color: Color = Color.NAVY_BLUE

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

var projectile_scene: PackedScene = preload("res://Scenes/Units/projectile.tscn")


static func _static_init():
	var is_diabled = func(data):
		return !data.disabled
		
	upgrade_options = DW_ToolBox.ImportResources("res://Data/Items/", is_diabled, true)
	mutation_data = DW_ToolBox.ImportResources("res://Data/Mutations/", is_diabled, true) 

# Called when the node enters the scene tree for the first time.
func _ready():
	projectile_scene.instantiate().queue_free()
	
	# delegate front end management to input manager
	$InputManager.game = self
	
	set_safezone_sprite(safe_zone_radius)
	
	player_unit = $PlayerUnit
	
	user_interface.player_health_hearts.set_hearts_count(int(player_unit.health_points), Vector2(32,32))
	bind_selected_unit_signals()
	
	# set minimap parameters
	user_interface.minimap.detection_range = spawn_radius
	
	# connect mutation timer
	mutation_timer.timeout.connect(on_mutation_timer_timeout)
	user_interface.mutation_roulette.option_selected.connect(on_mutation_selected)
	if !mutation_disabled:
		mutation_timer.start(mutation_cooldown)
	
	spawner_component.stats_changed.connect(user_interface.update_enemy_spawn_info.bind(spawner_component))
	user_interface.update_enemy_spawn_info(spawner_component)
	
	# spawn first wave
	spawner_component = $EnemySpawnerComponent
	spawner_component.on_spawn_timer_timeout()
	#spawn_wave()
	
	#user_interface.update_unit_shortcut_labels(InputManager.camera.get_screen_center_position(), units)
	user_interface.restart_button.pressed.connect(start)
	game_over_screen.restart_button.pressed.connect(start)

	user_interface.charge_bar.set_max(player_unit.max_charge)
	
	player_unit.set_eye_colors(weapon_one_color, weapon_two_color)
	player_unit.weapon_one.set_color(weapon_one_color)
	player_unit.weapon_two.set_color(weapon_two_color)
	
	#unit.picked_up_item.connect(user_interface.show_item_info)
	player_unit.experience_changed.connect(on_experience_changed)
	player_unit.charge_changed.connect(on_charge_changed)
	player_unit.added_experience.connect(user_interface.make_exp_popup)
	player_unit.was_selected.connect(bind_selected_unit_signals)
	player_unit.level_increased.connect(on_level_up)
	player_unit.stats_changed.connect(user_interface.update_bullet_menu)
	player_unit.stats_changed.connect(user_interface.update_bullet_generation_info_menu)
	player_unit.was_selected.connect(user_interface.update_bullet_menu)
	player_unit.actioned.connect(user_interface.update_bullet_menu)
	player_unit.weapon_one.bullets_changed.connect(user_interface.update_bullet_menu)
	player_unit.weapon_two.bullets_changed.connect(user_interface.update_bullet_menu)
	player_unit.weapon_one.reload_started.connect(
		user_interface.update_reload_marker.bind(user_interface.weapon_one_active_reload, player_unit.weapon_one))
	player_unit.weapon_two.reload_started.connect(
		user_interface.update_reload_marker.bind(user_interface.weapon_two_active_reload, player_unit.weapon_two))
	
	# connect player unit with stats component
	player_unit.added_experience.connect(stats_component.add_exp_gained)
	player_unit.weapon_one.shot_bullet.connect(stats_component.add_bullets_fired_count)
	player_unit.weapon_two.shot_bullet.connect(stats_component.add_bullets_fired_count)
	player_unit.weapon_one.reload_started.connect(stats_component.add_total_reload_count.bind(1))
	player_unit.weapon_two.reload_started.connect(stats_component.add_total_reload_count.bind(1))
	player_unit.weapon_one.active_reload_success.connect(stats_component.add_active_reload_success.bind(1))
	player_unit.weapon_two.active_reload_success.connect(stats_component.add_active_reload_success.bind(1))
	
	player_unit.used_ability.connect(pause_time.bind(0.1))
	
	# randomly place dynamite on the map
	#for i in range(10):
		#var new_shootable: Shootable = dynamite_shootable.instantiate()
		#new_shootable.global_position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randi_range(2000, spawn_radius)
		#shootables.add_child(new_shootable)
		
	user_interface.update_bullet_menu(player_unit.weapon_one, player_unit.weapon_two)
	user_interface.update_bullet_generation_info_menu(player_unit.bullet_generator_component)
	
	# auto select upgrade option if timeout
	upgrade_timer.timeout.connect(on_upgrade_timeout)
	user_interface.upgrade_timer = upgrade_timer
	
func _process(_delta):
	InputManager.camera.scale_health_label(enemies.get_children())
	
	user_interface.game_time_label.text = str(DW_ToolBox.TrimDecimalPoints(stats_component.survival_time, 0)) + " s"
	
	# update minimap
	if InputManager.selected_unit:
		var points: PackedVector2Array = PackedVector2Array()
		var color_arr: PackedColorArray = PackedColorArray()
		
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
			
	if Input.is_action_just_pressed("select_roulette"):
		if !mutation_timer.is_stopped() and mutation_timer.time_left > 3.0:
			mutation_timer.start(mutation_timer.time_left - 1.0)
	
	## Pause Menu
	if Input.is_action_just_pressed("pause_game"):
		if get_tree().paused == true:
			# unpause game
			get_tree().paused = false
			game_paused_screen.visible = false
			user_interface.visible = true
		else:
			get_tree().paused = true
			game_paused_screen.visible = true
			user_interface.visible = false
			
	## Click sound
	if Input.is_action_just_pressed("action_one") or Input.is_action_just_pressed("action_two"):
		$ClickSoundPlayer.play()
	
	## Camera panning with cursor
	var local_mouse_pos: Vector2 = InputManager.selected_unit.get_local_mouse_position()
	CameraControl.camera.position = local_mouse_pos.normalized()
	# limit the amount of camera position offset from cursor
	CameraControl.camera.position *= min(local_mouse_pos.length()/7, 300)
	
	## Player outside safe zone
	if player_unit.global_position.length() > safe_zone_radius:
		if player_unit.safe_zone_timer.is_stopped():
			player_unit.safe_zone_timer.start(1)
		if !user_interface.danger_zone_effect.is_playing():
			user_interface.danger_zone_effect.play("danger_zone")
	else:
		if !player_unit.safe_zone_timer.is_stopped():
			player_unit.safe_zone_timer.stop()
		if user_interface.danger_zone_effect.is_playing():
			user_interface.danger_zone_effect.stop(false)
	
	## Player charge ui update
	if player_unit.ability_on:
		user_interface.charge_bar.change_value(player_unit.charge)
	user_interface.charge_bar_shade.visible = player_unit.is_ability_ready()
	user_interface.ability_screen_effect.visible = player_unit.ability_on
		
func enemy_killed()-> void:
	stats_component.kill_count += 1
	user_interface.kill_count_label.text = str(int(stats_component.kill_count)) + " Kills"
	user_interface.kill_count_animation.play("killcount_up")
	user_interface.enemy_count_label.text = "Enemy Count: " + str(enemies.get_child_count())
	#player_unit.add_experience(100)
	
func add_enemy(newEnemy: EnemyUnit) -> void:
	newEnemy.game_ref = self
	enemies.add_child(newEnemy)
	#if InputManager.selected_unit != null:
		#newEnemy.position = InputManager.selected_unit.global_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * spawn_radius
	#else:
	newEnemy.position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * spawn_radius
	newEnemy.on_death.connect(enemy_killed)
	
	user_interface.enemy_count_label.text = "Enemy Count: " + str(enemies.get_child_count())
	
	# connect signals to stat component
	newEnemy.critical_hit.connect(stats_component.add_critical_hit_count.bind(1))
	newEnemy.received_hit.connect(stats_component.add_enemy_received_damage)
	newEnemy.bullet_hit.connect(stats_component.add_bullets_hit_count.bind(1))
	
	# add charge
	newEnemy.received_hit.connect(player_unit.add_charge_on_hit)
	
func game_over() -> void:
	if no_game_over:
		return
		
	print("***GAME OVER***")
	#spawner_component.spawn_timer.stop()
	mutation_timer.stop()
	user_interface.mutation_roulette.stop_roulette()
	
	#remove_objects()
	user_interface.visible = false
	game_over_screen.set_game_over_stats(stats_component)
	game_over_screen.visible = true

func victory() -> void:
	if no_game_over:
		return
		
	print("***VICTORY***")
	
	user_interface.show_game_over_screen(true)
	
func remove_objects() -> void:
	# remove all remaining enemy units
	call_deferred("remove_child", enemies)
	enemies.queue_free()
	enemies = Node2D.new()
	add_child(enemies)
	
	# remove all remaining shootables
	call_deferred("remove_child", shootables)
	shootables.queue_free()
	shootables = Node2D.new()
	add_child(shootables)
	
	# remove all remaining projectiles
	call_deferred("remove_child", projectiles)
	projectiles.queue_free()
	projectiles = Node2D.new()
	add_child(projectiles)
	
	# remove all remaining projectiles
	call_deferred("remove_child", casings)
	casings.queue_free()
	casings = Node2D.new()
	add_child(casings)
	
	DW_ToolBox.RemoveAllChildren(blood_splatter)
	
func start() -> void:
	print("***START GAME***")
	
	stats_component.reset_stats()
	
	user_interface.visible = true
	game_over_screen.visible = false
	
	# remove leftover resources
	remove_objects()
	
	spawner_component.reset_stats()
	
	# spawn first wave
	spawner_component.on_spawn_timer_timeout()
	
	# start mutation
	mutation_timer.start(mutation_cooldown)
	user_interface.mutation_roulette.mutation_time_label.visible = true

	# reset game stats
	user_interface.game_over_ui.visible = false
	# reset unit stats
	player_unit.reset_health()
	player_unit.reset_items()
	player_unit.reset_exp()
	player_unit.reload_action()
	player_unit.global_position = Vector2.ZERO
	
	# reset enemy stats 
	spawner_component.reset_stats()

	# randomly place dynamite on the map
	for i in range(5):
		var new_shootable: Shootable = dynamite_shootable.instantiate()
		new_shootable.global_position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randi_range(2000, spawn_radius)
		shootables.add_child(new_shootable)
	
	user_interface.kill_count_label.text = "Kills: " + str(stats_component.kill_count)
	
	user_interface.update_bullet_menu()

func on_core_hit() -> void:
	user_interface.core_hit_effect.play("RESET")
	user_interface.core_hit_effect.play("core_hit_animation")
	
	user_interface.player_health_hearts.set_hearts_count(int(player_unit.health_points), Vector2(32,32))

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
		unit.health_changed.connect(on_core_hit)
			
func on_experience_changed() -> void:
	if player_unit != null:
		var unit: PlayerUnit = player_unit
		user_interface.experience_bar.change_value(unit.experience_gained, true)
		user_interface.experience_label.text = "LV " + str(unit.current_level) + "  " + str(unit.experience_gained) + "/" + str(unit.required_exp_amount(unit.current_level))
		
		if !user_interface.level_up_menu.visible and unit.is_level_up_ready():
			unit.upgrade_options = get_upgrade_options()
			user_interface.show_upgrade_menu()
			unit.level_up_sound.playing = true
			#await unit.level_up_animation.animation_finished
			# start upgrade option selection timer
			upgrade_timer.start(15)
			get_tree().paused = true

func on_charge_changed() -> void:
	user_interface.charge_bar.change_value(player_unit.charge)
	
func on_level_up() -> void:
	if player_unit != null:
		user_interface.experience_bar.set_max(player_unit.required_exp_amount(player_unit.current_level))
		user_interface.experience_bar.change_value(player_unit.experience_gained, true)
		user_interface.experience_label.text = "LV " + str(player_unit.current_level) + "  " + str(player_unit.experience_gained) + "/" + str(player_unit.required_exp_amount(player_unit.current_level))
		player_unit.upgrade_options = get_upgrade_options()
		get_tree().paused = false
		player_unit.level_up_animation.play("level_up")
		
		stats_component.level_reached += 1
		
func get_upgrade_options(count: int = 4):
	var output = []
	var current
	for i in range(count):
		current = Game.upgrade_options.pick_random()
		var limiter: int = 100
		while !check_upgrade_prereq(current) and limiter > 0:
			current = Game.upgrade_options.pick_random()
			limiter -= 1
		if limiter <= 0:
			push_error("Upgrade option prereq check timeout.")
		output.append(current)
	return output

func check_upgrade_prereq(item: ItemData) -> bool:
	return item.prereq == null or item.prereq in player_unit.items.keys()
	
func on_upgrade_timeout():
	user_interface.upgrade_option_selected(InputManager.selected_unit.upgrade_options.pick_random())
	get_tree().paused = false
	
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
	var current
	for i in range(count):
		current = Game.mutation_data.pick_random()
		var limiter: int = 100
		while !check_upgrade_prereq(current) and limiter > 0:
			current = Game.mutation_data.pick_random()
			limiter -= 1
		if limiter <= 0:
			push_error("Mutation option prereq check timeout.")
		output.append(current)
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
	
func check_mutation_prereq(item: Mutation) -> bool:
	return item.prereq == null or item.prereq in mutations.keys()
#endregion

func set_safezone_sprite(radius: float) -> void:
	var sprite: Sprite2D = $Safezone
	sprite.scale = Vector2(radius * 2 / 486.0, radius * 2 / 486.0)
