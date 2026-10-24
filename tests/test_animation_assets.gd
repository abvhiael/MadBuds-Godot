extends SceneTree

const CLIPS := [
	"01_idle_annoyed", "02_idle_foot_tap", "03_cannon_loading",
	"04_compression_launch", "05_airborne_tumble", "06_wrecking_ball",
	"07_heavy_flight", "08_impact_squash", "09_stuck_recovery",
	"10_victory_fist_raise", "11_irritated_failure", "12_laughing",
	"13_angry", "14_thumbs_down", "15_thumbs_up"
]

func _initialize() -> void:
	call_deferred("_verify")

func _verify() -> void:
	var n := 0
	for clip in CLIPS:
		var folder: String = "res://assets/characters/kush-krusher/animations/kk_anim_" + clip
		var manifest_path: String = folder + "/kush_krusher_anim_" + clip + ".json"
		assert(FileAccess.file_exists(manifest_path), "missing manifest " + manifest_path)
		var data = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
		assert(data is Dictionary, "invalid manifest JSON " + manifest_path)
		assert(data["frameCount"] == 10 and data["fps"] == 10)
		assert(data["characterId"] == "kush_krusher")
		assert(data["frames"].size() == 10)
		for i in 10:
			var entry: Dictionary = data["frames"][i]
			var image_path: String = folder + "/" + entry["filename"]
			assert(entry["index"] == i + 1)
			assert(ResourceLoader.exists(image_path), "missing imported PNG " + image_path)
			var texture := load(image_path) as Texture2D
			assert(texture != null and texture.get_width() == 1024 and texture.get_height() == 1024, "invalid frame " + image_path)
			n += 1
	assert(n == 150)
	var animator_script := load("res://scripts/kush_animation.gd")
	var animator = animator_script.new()
	var host := Node2D.new()
	root.add_child(host)
	host.add_child(animator)
	animator.change_state("wreck")
	assert(animator.sprite.texture != null, "wreck frame did not render")
	animator._process(0.1)
	assert(animator.frame_index == 1, "animation did not advance at 10 FPS")
	print("PASS: 15 imported manifests, 150 PNG textures, Godot playback state and 10 FPS frame advancement")
	quit()
