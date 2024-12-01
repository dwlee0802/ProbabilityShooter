extends Node2D
class_name Game

@onready
var state_machine: StateMachine = $StateMachine

@onready
var user_interface: UserInterface = $UserInterface
@onready
var end_screen: GameOverScreen = $EndScreen
@onready
var game_paused_screen = $PauseScreen

var enemy_scene = preload("res://Scenes/Units/enemy_unit.tscn")

var player_unit: PlayerUnit

@onready
var stats_component: StatisticsComponent = $StatisticsComponent

@onready
var history_component: RunHistoryComponent = $RunHistoryComponent

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
@onready
var resources: Node2D = $Resources

@export
var safe_zone_radius: float = 2000.0
@export
var safe_zone_active: bool = false
@onready
var safe_zone_sprite: Sprite2D = $Safezone

#region Teleporter System
## Teleporter system
var crystal_scene: PackedScene
@export_category("Teleporter Settings")
@export
var crystal_count: int = 3
#endregion

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

@onready
var score_component: ScoreComponent = $ScoreComponent

## shootable objects
var dynamite_shootable = preload("res://Scenes/Shootables/dynamite.tscn")
var projectile_scene: PackedScene = preload("res://Scenes/Units/projectile.tscn")
var exp_orb: PackedScene = preload("res://Scenes/Pickups/exp_orb.tscn")


static func _static_init():
	var is_diabled = func(data):
		return !data.disabled
		
	upgrade_options = DW_ToolBox.ImportResources("res://Data/Upgrade/", is_diabled, true)
	mutation_data = DW_ToolBox.ImportResources("res://Data/Mutations/", is_diabled, true) 

# Called when the node enters the scene tree for the first time.
func _ready():
	state_machine.init(self)
	
	projectile_scene.instantiate().queue_free()
	exp_orb.instantiate().queue_free()
	dynamite_shootable.instantiate().queue_free()
	
	# delegate front end management to input manager
	$InputManager.game = self
	
	set_safezone_sprite(safe_zone_radius)
	
	player_unit = $PlayerUnit
	player_unit.safe_zone_radius = safe_zone_radius
	
	player_unit.melee_weapon.game_ref = self
	
	## set high score
	history_component = $RunHistoryComponent
	score_component = $ScoreComponent
	if history_component.get_best_run():
		score_component.highscore = history_component.get_best_run()["score"]
	else:
		score_component.highscore = 0
	user_interface.score_info_ui.set_score_component(score_component)
	
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
	#user_interface.update_enemy_spawn_info(spawner_component)
	
	# spawn first wave
	spawner_component = $EnemySpawnerComponent
	#spawner_component.wave_started.connect(on_wave_start)
	#spawner_component.on_wave_timer_timeout()
	#spawn_wave()
	
	end_screen.restart_button.pressed.connect(start)

	user_interface.charge_bar.set_max(player_unit.max_charge)
	on_charge_changed()
	
	player_unit.set_eye_colors(weapon_one_color, weapon_two_color)
	player_unit.weapon_one.set_color(weapon_one_color)
	player_unit.weapon_two.set_color(weapon_two_color)
	
	player_unit.inventory_changed.connect(user_interface.update_inventory_slots.bind(player_unit.inventory))
	
	# teleporting related signals
	player_unit.teleport_started.connect(set_safezone_active_status.bind(true))
	player_unit.teleport_finished.connect(on_teleport_finished)
	player_unit.teleport_finished.connect(set_safezone_active_status.bind(false))
	
	player_unit.experience_changed.connect(on_experience_changed)
	player_unit.charge_changed.connect(on_charge_changed)
	#player_unit.added_experience.connect(user_interface.make_exp_popup)
	player_unit.upgrade_ready.connect(on_upgrade)
	player_unit.was_selected.connect(bind_selected_unit_signals)
	player_unit.level_increased.connect(on_level_up)
	player_unit.stats_changed.connect(user_interface.update_bullet_menu)
	#player_unit.stats_changed.connect(user_interface.update_bullet_generation_info_menu)
	player_unit.was_selected.connect(user_interface.update_bullet_menu)
	player_unit.actioned.connect(user_interface.update_bullet_menu)
	player_unit.weapon_one.bullets_changed.connect(user_interface.update_bullet_menu)
	player_unit.weapon_two.bullets_changed.connect(user_interface.update_bullet_menu)
	player_unit.weapon_one.reload_started.connect(
		user_interface.update_reload_marker.bind(user_interface.weapon_one_active_reload, player_unit.weapon_one))
	player_unit.weapon_two.reload_started.connect(
		user_interface.update_reload_marker.bind(user_interface.weapon_two_active_reload, player_unit.weapon_two))
	player_unit.buff_entered.connect(user_interface.buff_icon_container.add_buff_icon)
	
	player_unit.weapon_one.activated.connect(user_interface.screen_blink.play.bind("screen_blink"))
	player_unit.weapon_two.activated.connect(user_interface.screen_blink.play.bind("screen_blink"))
	
	# connect player unit with stats component
	player_unit.added_experience.connect(stats_component.add_exp_gained)
	player_unit.weapon_one.shot_bullet.connect(stats_component.add_bullets_fired_count)
	player_unit.weapon_two.shot_bullet.connect(stats_component.add_bullets_fired_count)
	player_unit.weapon_one.reload_started.connect(stats_component.add_total_reload_count.bind(1))
	player_unit.weapon_two.reload_started.connect(stats_component.add_total_reload_count.bind(1))
	player_unit.weapon_one.active_reload_success.connect(stats_component.add_active_reload_success.bind(1))
	player_unit.weapon_two.active_reload_success.connect(stats_component.add_active_reload_success.bind(1))
	
	player_unit.used_ability.connect(slow_time.bind(0.2, 0.1))
	
	# randomly place dynamite on the map
	place_shootables()
		
	#place_crystals()
	set_safezone_active_status(true)
		
	user_interface.update_bullet_menu(player_unit.weapon_one, player_unit.weapon_two)
	#user_interface.update_bullet_generation_info_menu(player_unit.bullet_generator_component)
	
	UpgradesManager.game_ref = self
	user_interface.upgrade_confirm_button.pressed.connect(on_upgrade_selected)
	
	# auto select upgrade option if timeout
	upgrade_timer.timeout.connect(on_upgrade_timeout)
	user_interface.upgrade_timer = upgrade_timer
	
	user_interface.upgrade_ui.clear_icons()
	
func _process(_delta):
	state_machine.process_frame(_delta)
	
	#InputManager.camera.scale_health_label(enemies.get_children())
	
	user_interface.game_time_label.text = str(DW_ToolBox.TrimDecimalPoints(stats_component.survival_time, 0)) + " s"
	user_interface.wave_time_label.text = "NEXT WAVE IN: " + str(int(spawner_component.wave_timer.time_left) + 1) + "s"
	if int(spawner_component.wave_timer.time_left) + 1 < 7 and (spawner_component.wave_timer.time_left - int(spawner_component.wave_timer.time_left)) > 0.95:
		user_interface.wave_time_label.get_node("AnimationPlayer").play("wave_impending")
		
	# check victory
	if !end_screen.visible and spawner_component.is_max_waves_reached() and is_all_enemies_killed():
		game_finished(true)
	
	# update minimap
	#if InputManager.selected_unit:
		#var points: PackedVector2Array = PackedVector2Array()
		#var color_arr: PackedColorArray = PackedColorArray()
		#
		#for enemy: EnemyUnit in enemies.get_children():
			#points.append(enemy.global_position)
			#color_arr.append(Color.RED)
		#user_interface.minimap.update_markers(InputManager.selected_unit.global_position, points, color_arr)
		#
		##var bullet_points = []
		##var bullet_color_arr = []
		##for bullet: Projectile in projectiles.get_children():
			##bullet_points.append(bullet.global_position)
			##bullet_color_arr.append(Color.WHITE)
			##
		##user_interface.minimap.update_bullet_markers(InputManager.selected_unit.global_position, bullet_points, bullet_color_arr)
		##
		#var shootable_points = []
		#var shootable_color_arr = []
		#for shootable: Shootable in shootables.get_children():
			#shootable_points.append(shootable.global_position)
			#shootable_color_arr.append(Color.ORANGE)
			#
		#user_interface.minimap.update_shootable_markers(InputManager.selected_unit.global_position, shootable_points, shootable_color_arr)
	#else:
		#user_interface.minimap.update_markers(InputManager.selected_unit.global_position, [], [])
		
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
	
	## Player outside safe zone front-end effects
	if player_unit.safe_zone_active:
		if !player_unit.is_inside_safe_zone():
			if !user_interface.danger_zone_effect.is_playing():
				user_interface.danger_zone_effect.play("danger_zone")
		else:
			if user_interface.danger_zone_effect.is_playing():
				user_interface.danger_zone_effect.stop(false)
				user_interface.danger_zone_effect.play("RESET")
	else:
		if user_interface.danger_zone_effect.is_playing():
			user_interface.danger_zone_effect.play("RESET")
			user_interface.danger_zone_effect.stop(false)
	
	## Player charge ui update
	if player_unit.ability_on:
		on_charge_changed()
		user_interface.ability_full_label.visible = false
	user_interface.charge_bar_shade.visible = player_unit.is_ability_ready()
	user_interface.ability_full_label.visible = player_unit.is_ability_ready()
	user_interface.ability_screen_effect.visible = player_unit.ability_on

func _input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	
func place_shootables() -> void:
	for i in range(10):
		var new_shootable: Shootable = dynamite_shootable.instantiate()
		new_shootable.global_position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randi_range(2000, spawn_radius)
		shootables.add_child(new_shootable)
	
func enemy_killed() -> void:
	stats_component.kill_count += 1
	user_interface.kill_count_label.text = str(int(stats_component.kill_count)) + " Kills"
	user_interface.kill_count_animation.play("killcount_up")
	user_interface.enemy_count_label.text = "Enemy Count: " + str(enemies.get_child_count())
	#player_unit.add_experience(100)

func is_all_enemies_killed() -> bool:
	return enemies.get_child_count() == 0
	
func add_enemy(newEnemy: EnemyUnit) -> void:
	newEnemy.game_ref = self
	newEnemy.score_component = score_component
	
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
	newEnemy.critical_hit.connect(player_unit.add_experience.bind(25))
	newEnemy.bullet_hit.connect(player_unit.add_experience.bind(10))

func add_missile(missile: Missile) -> void:
	missile.game_ref = self
	projectiles.call_deferred("add_child", missile)

func add_pickup(pickup: Pickup) -> void:
	resources.call_deferred("add_child", pickup)
	
func game_finished(victory: bool) -> void:
	# already called
	if end_screen.visible == true:
		return
		
	if no_game_over:
		return
	
	if !spawner_component.wave_timer.is_stopped():
		spawner_component.wave_timer.stop()
	
	stats_component.score = score_component.total_score
	stats_component.reached_wave = spawner_component.wave_count
	stats_component.total_waves = spawner_component.max_waves
	
	history_component.save_run_data(stats_component.export_data())
	
	user_interface.visible = false
	
	end_screen.set_game_over_stats(stats_component, score_component)
	end_screen.visible = true
	
	end_screen.set_title(victory)
	if victory:
		print("***VICTORY***")
	else:
		print("***GAME OVER***")

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
	
	# remove all remaining projectiles
	call_deferred("remove_child", resources)
	resources.queue_free()
	resources = Node2D.new()
	add_child(resources)
	
	DW_ToolBox.RemoveAllChildren(blood_splatter)
	
func start() -> void:
	print("***START GAME***")
	state_machine.init(self)
	
	stats_component.reset_stats()
	
	user_interface.visible = true
	end_screen.visible = false
	
	score_component.reset()
	
	# remove leftover resources
	remove_objects()
	
	spawner_component.reset_stats()
	
	# spawn first wave
	# reset enemy stats 
	spawner_component.reset_stats()
	spawner_component.on_wave_timer_timeout()
	
	# start mutation
	#mutation_timer.start(mutation_cooldown)
	#user_interface.mutation_roulette.mutation_time_label.visible = true

	# reset unit stats
	player_unit.reset_health()
	player_unit.reset_items()
	player_unit.reset_exp()
	player_unit.reload_action()
	player_unit.global_position = Vector2.ZERO
	player_unit.freeze = false
	player_unit.clear_inventory()
	player_unit.reset_crystals()
	player_unit.stat_component.reset_stats()
	player_unit.clear_buffs()
	
	UpgradesManager.reset_upgrades()
	
	place_shootables()
	
	set_safezone_active_status(true)
	player_unit.safe_zone_active = true
	user_interface.kill_count_label.text = str(int(stats_component.kill_count)) + " Kills"
	
	user_interface.upgrade_ui.clear_icons()

func place_crystals() -> void:
	for i in range(crystal_count):
		var new_crystal: Crystal = crystal_scene.instantiate()
		new_crystal.global_position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randi_range(2000, spawn_radius)
		resources.add_child(new_crystal)
		
func on_core_hit() -> void:
	user_interface.core_hit_effect.play("RESET")
	user_interface.core_hit_effect.play("core_hit_animation")
	
	user_interface.player_health_hearts.set_hearts_count(int(player_unit.health_points), Vector2(32,32))

#func change_resource(amount: int) -> void:
	#resource_stock += amount
	#resource_stock = max(resource_stock, 0)
	#print("changed resource by " + str(amount))
	#user_interface.resource_label.text = "Resource: " + str(resource_stock)

func on_player_heal() -> void:
	user_interface.show_vignette_effect(1.0, Color.LIME_GREEN)
	user_interface.player_health_hearts.set_hearts_count(int(player_unit.health_points), Vector2(32,32))
	
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
			
		InputManager.selected_unit.knocked_out.connect(game_finished.bind(false))
		InputManager.selected_unit.was_attacked.connect(on_core_hit)
		unit.health_changed.connect(on_core_hit)
		unit.healed.connect(on_player_heal)
			
func on_experience_changed() -> void:
	if player_unit != null:
		var unit: PlayerUnit = player_unit
		user_interface.experience_bar.change_value(unit.experience_gained, true)
		user_interface.experience_label.text = "LV " + str(unit.current_level) + "  " + str(unit.experience_gained) + "/" + str(unit.required_exp_amount(unit.current_level))
		user_interface.show_vignette_effect(0.5, Color.ROYAL_BLUE)

func on_upgrade() -> void:
	if end_screen.visible:
		return
		
	if !user_interface.level_up_menu.visible:
		player_unit.upgrade_options = get_upgrade_options()
		user_interface.show_upgrade_menu()
		upgrade_timer.start(15)
		
		#var tween = get_tree().create_tween()
		#tween.tween_property(Engine, "time_scale", 0, 0.1)
		get_tree().paused = true
		
	
func on_charge_changed() -> void:
	user_interface.charge_bar.change_value(player_unit.charge)
	user_interface.charge_bar_label.text = "ENERGY: " + str(int(player_unit.charge)) + " / " + str(player_unit.max_charge)
	
func on_level_up() -> void:
	if player_unit != null:
		user_interface.experience_bar.set_max(player_unit.required_exp_amount(player_unit.current_level))
		user_interface.experience_bar.change_value(player_unit.experience_gained, true)
		user_interface.experience_label.text = "LV " + str(player_unit.current_level) + "  " + str(player_unit.experience_gained) + "/" + str(player_unit.required_exp_amount(player_unit.current_level))
		player_unit.upgrade_options = get_upgrade_options()
		player_unit.level_up_animation.play("level_up")
		
		stats_component.level_reached += 1
	
func get_upgrade_options(count: int = 4):
	var output = []
	var current
	for i in range(count):
		current = Game.upgrade_options.pick_random()
		#var limiter: int = 100
		#while limiter > 0:
			#current = Game.upgrade_options.pick_random()
			#limiter -= 1
		#if limiter <= 0:
			#push_error("Upgrade option prereq check timeout.")
		output.append(current)
	return output

func check_upgrade_prereq(item: ItemData) -> bool:
	return item.prereq == null or item.prereq in player_unit.items.keys()
	
func on_upgrade_timeout():
	print("upgrade timer timeout. pick random option")
	user_interface.upgrade_option_selected()
	var random_option: Upgrade = Game.upgrade_options.pick_random()
	apply_upgrade(random_option)
	
	get_tree().paused = false

func apply_upgrade(upgrade: Upgrade) -> void:
	if !upgrade:
		return
		
	UpgradesManager.add_upgrade(upgrade)
	## General event that depicts some Upgrade was taken
	UpgradesManager.process_event(Event.new(player_unit, player_unit.global_position, upgrade, Event.EventCode.UPGRADE_TAKEN))
	## Static upgrades are upgrades that is a one time fire upgrade usually a stat boost to player
	UpgradesManager.process_event(Event.new(player_unit, player_unit.global_position, upgrade, Event.EventCode.STATIC_UPGRADE_TAKEN))
	player_unit.upgrades_ready_count -= 1
	
	user_interface.upgrade_ui.add_upgrade_icon(upgrade)
		
func on_upgrade_selected():
	var tween = get_tree().create_tween()
	tween.tween_property(Engine, "time_scale", 1, 0.1)
	get_tree().paused = false
	
	upgrade_timer.stop()
	var new_upgrade: Upgrade = user_interface.upgrade_button_group.get_pressed_button().data
	print("upgrade selected: " + new_upgrade.upgrade_name)
	
	apply_upgrade(new_upgrade)
	
	# if level up is still ready after leveling up, show new options
	# otherwise, hide menu
	if player_unit.is_upgrade_ready():
		on_upgrade()
		get_tree().paused = true
	
func pause_time(duration: float) -> void:
	get_tree().paused = true
	await get_tree().create_timer(duration).timeout
	get_tree().paused = false
	
func slow_time(ratio: float, duration: float) -> void:
	Engine.time_scale = ratio
	await get_tree().create_timer(duration).timeout
	Engine.time_scale = 1

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

#region Teleport System
func set_safezone_sprite(radius: float = safe_zone_radius) -> void:
	var sprite: Sprite2D = $Safezone
	sprite.scale = Vector2(radius * 2 / 486.0, radius * 2 / 486.0)

func set_safezone_active_status(activate: bool) -> void:
	safe_zone_sprite.visible = activate
	safe_zone_sprite.scale = Vector2.ZERO
	if activate:
		var tween: Tween = get_tree().create_tween()
		var final_rad: float = safe_zone_radius * 2 / 486.0
		tween.tween_property(safe_zone_sprite, "scale", Vector2(final_rad, final_rad), 2)
		safe_zone_sprite.global_position = player_unit.global_position
	else:
		pass

func on_teleport_finished():
	set_safezone_active_status(false)
	print("Load next map!")
	
#endregion

func on_wave_start():
	user_interface.wave_label.text = "WAVE " + str(spawner_component.wave_count) + "/" + str(spawner_component.max_waves)
	
