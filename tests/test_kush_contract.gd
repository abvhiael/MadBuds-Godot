extends SceneTree
# Headless: godot --headless --path . --script res://tests/test_kush_contract.gd
func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var bud_script = load("res://scripts/kush_krusher.gd")
	var bud = bud_script.new()
	root.add_child(bud)
	assert(bud.CHARACTER_ID == &"kush-krusher")
	assert(not bud.activate_wrecking_ball())
	bud.launch(Vector2(200.0, -300.0))
	assert(bud.activate_wrecking_ball())
	assert(bud.ability_active)
	assert(not bud.activate_wrecking_ball())
	bud.end_ability()
	assert(not bud.ability_active)
	assert(not bud.activate_wrecking_ball())
	bud.reset_for_next_shot()
	assert(not bud.ability_used)
	var block_script = load("res://scripts/destructible.gd")
	var block = block_script.new()
	root.add_child(block)
	block.max_integrity = 100.0
	block._ready()
	assert(block.receive_impact(100.0, 3.5) == 0.0)
	assert(block.receive_impact(500.0, 8.75, 1.75) > 0.0)
	assert(block.broken)
	assert(block.receive_impact(500.0, 8.75) == 0.0)
	print("MB-3 focused contract tests PASS")
	quit()
