extends Node2D
class_name KushAnimation

const CLIPS := {
	"idle": "01_idle_annoyed",
	"impatient": "02_idle_foot_tap",
	"loading": "03_cannon_loading",
	"launch": "04_compression_launch",
	"tumble": "05_airborne_tumble",
	"flight": "07_heavy_flight",
	"wreck": "06_wrecking_ball",
	"impact": "08_impact_squash",
	"recovery": "09_stuck_recovery",
	"victory": "10_victory_fist_raise",
	"failure": "11_irritated_failure",
	"laughing": "12_laughing",
	"angry": "13_angry",
	"thumbs_down": "14_thumbs_down",
	"thumbs_up": "15_thumbs_up"
}
@export var frames_per_second := 10.0
var state := "idle"
var frame_index := 0
var elapsed := 0.0
var sprite: Sprite2D
var cache := {}
var fallback: CanvasItem

func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.scale = Vector2(0.085, 0.085)
	add_child(sprite)
	fallback = get_parent().get_node_or_null("PlaceholderBody") as CanvasItem
	change_state("idle")

func change_state(next: String) -> void:
	if not CLIPS.has(next):
		push_warning("Unknown Kush Krusher animation: " + next)
		return
	if next == state and sprite.texture != null:
		return
	state = next
	frame_index = 0
	elapsed = 0.0
	_render_frame()

func _process(delta: float) -> void:
	elapsed += delta
	var duration := 1.0 / maxf(1.0, frames_per_second)
	if elapsed >= duration:
		var advances := int(elapsed / duration)
		elapsed = fmod(elapsed, duration)
		frame_index = (frame_index + advances) % 10
		_render_frame()

func _render_frame() -> void:
	var label: String = CLIPS[state]
	var frame_name: String = "kush_krusher_anim_%s_frame_%02d.png" % [label, frame_index + 1]
	var folder: String = "kk_anim_" + label
	var resource_path: String = "res://assets/characters/kush-krusher/animations/%s/%s" % [folder, frame_name]
	if ResourceLoader.exists(resource_path):
		if not cache.has(resource_path):
			cache[resource_path] = load(resource_path)
		sprite.texture = cache[resource_path]
		sprite.visible = true
	else:
		sprite.visible = false
	if fallback != null:
		fallback.visible = not sprite.visible
