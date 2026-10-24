extends SceneTree
# Level 2: instantiate actual gameplay scene, verify animation, launch, ability,
# destructible target, HUD state and end-of-shot lifecycle in combination.
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	assert(scene != null, "main scene must load")
	var game = scene.instantiate()
	root.add_child(game)
	await process_frame
	assert(game.bud != null and game.bud.has_node("KushAnimation"))
	var anim = game.bud.get_node("KushAnimation")
	assert(anim.sprite.texture != null, "approved idle frame must load")
	assert(anim.state == "idle")
	var aim := InputEventKey.new()
	aim.keycode = KEY_SPACE
	aim.pressed = true
	game._unhandled_input(aim)
	assert(not game.bud.launched and game.preparing_launch and game.shots == 1, "loading must precede flight")
	assert(anim.state == "loading", "cannon loading plays while stationary")
	game._unhandled_input(aim)
	assert(game.shots == 1, "loading must not accept duplicate launches")
	game._physics_process(game.LOADING_SECONDS + 0.01)
	assert(game.bud.launched and not game.preparing_launch, "shot releases after loading")
	assert(anim.state == "launch", "compression launch must play in flight")
	anim._process(0.5)
	assert(anim.state == "launch" and anim.frame_index == 3, "launch sequence extended to 6 FPS")
	anim._process(1.2)
	assert(anim.state == "flight", "launch transitions automatically to airborne flight")
	game._unhandled_input(aim)
	assert(game.bud.ability_used and game.bud.ability_active, "in-flight space must activate Wrecking Ball")
	assert(anim.state == "wreck" and anim.sprite.texture != null, "wreck frame must load")
	assert(not game.bud.activate_wrecking_ball(), "ability must be one-shot")
	var target = game.target as MadBudsDestructible
	assert(target != null and not target.broken)
	game._on_bud_collision(target, 600.0, 8.75, 1.75)
	assert(target.broken and game.target_hit, "authoritative collision must destroy target")
	assert(game.status_label.text.contains("TARGET DESTROYED"), "HUD must reflect authoritative destruction")
	game._physics_process(0.016)
	assert(not game.bud.launched, "completed shot must resolve")
	assert(anim.state == "idle", "resolution must restore idle")
	assert(game.shots == 1, "shot counter must be retained")
	assert(target.receive_impact(900.0, 20.0) == 0.0, "broken target cannot take repeated damage")
	game._unhandled_input(aim)
	assert(game.shots == 2 and game.preparing_launch and not game.bud.launched, "next turn re-enters loading")
	print("PASS MB3 Level 2: real scene, imported sprite, launch, Wrecking Ball, one-shot restriction, destruction, HUD, resolution, replay launch")
	quit()
