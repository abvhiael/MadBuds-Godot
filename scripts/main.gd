extends Node2D

const BUD_SCENE := preload("res://scenes/characters/kush_krusher.tscn")
const LAUNCH_POSITION := Vector2(145.0, 575.0)
const MAX_SPEED := 1050.0
const MIN_ANGLE := -75.0
const MAX_ANGLE := -10.0

var bud: KushKrusher
var shots := 0
var aim_angle := -35.0
var launch_power := 0.7
var target_hit := false

@onready var status_label: Label = $CanvasLayer/HUD/Status
@onready var guide_label: Label = $CanvasLayer/HUD/Guide
@onready var target: StaticBody2D = $Target

func _ready() -> void:
	spawn_bud()
	refresh_hud()

func spawn_bud() -> void:
	if is_instance_valid(bud):
		bud.queue_free()
	bud = BUD_SCENE.instantiate() as KushKrusher
	add_child(bud)
	bud.position = LAUNCH_POSITION
	bud.body_entered.connect(_on_body_entered)
	bud.ability_activated.connect(_on_ability_activated)
	bud.ability_expired.connect(_on_ability_expired)
	bud.collided_with_object.connect(_on_bud_collision)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_LEFT:
				aim_angle = clampf(aim_angle - 3.0, MIN_ANGLE, MAX_ANGLE)
			KEY_RIGHT:
				aim_angle = clampf(aim_angle + 3.0, MIN_ANGLE, MAX_ANGLE)
			KEY_UP:
				launch_power = clampf(launch_power + 0.05, 0.1, 1.0)
			KEY_DOWN:
				launch_power = clampf(launch_power - 0.05, 0.1, 1.0)
			KEY_SPACE:
				if not bud.launched:
					var direction := Vector2.RIGHT.rotated(deg_to_rad(aim_angle))
					bud.launch(direction * MAX_SPEED * launch_power * 0.9)
					_set_animation("launch")
					shots += 1
				else:
					bud.activate_wrecking_ball()
			KEY_R:
				target_hit = false
				spawn_bud()
		refresh_hud()

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(bud):
		return
	if bud.launched and (bud.position.y > 900.0 or bud.position.x > 1500.0 or bud.position.x < -150.0):
		bud.reset_for_next_shot()
		bud.position = LAUNCH_POSITION
		_set_animation("idle")
		refresh_hud()
	queue_redraw()

func _on_ability_activated() -> void:
	_set_animation("wreck")
	refresh_hud()

func _on_ability_expired() -> void:
	_set_animation("flight")
	refresh_hud()

func _set_animation(state: String) -> void:
	if is_instance_valid(bud) and bud.has_node("KushAnimation"):
		bud.get_node("KushAnimation").change_state(state)

func _on_bud_collision(body: Node, speed: float, impact_mass: float, modifier: float) -> void:
	if body is MadBudsDestructible:
		(body as MadBudsDestructible).receive_impact(speed, impact_mass, modifier)
	_set_animation("impact")

func _on_body_entered(body: Node) -> void:
	if body == target and not target_hit:
		if not (target as MadBudsDestructible).broken:
			return
		target_hit = true
		refresh_hud()

func refresh_hud() -> void:
	if not is_instance_valid(bud):
		return
	var state := "READY"
	if bud.launched:
		state = "WRECKING BALL!" if bud.ability_active else "IN FLIGHT"
	if target_hit:
		state = "TARGET HIT!"
	status_label.text = "KUSH KRUSHER  |  %s  |  Shots: %d" % [state, shots]
	guide_label.text = "Arrows: aim/power  |  SPACE: launch / Wrecking Ball  |  R: reset  |  Power %d%%  |  Angle %.0f°" % [roundi(launch_power * 100), aim_angle]

func _draw() -> void:
	draw_rect(Rect2(Vector2(0, 632), Vector2(1280, 88)), Color("283a29"))
	draw_line(LAUNCH_POSITION, LAUNCH_POSITION + Vector2.RIGHT.rotated(deg_to_rad(aim_angle)) * (80.0 + launch_power * 60.0), Color("89e27c"), 5.0)
	draw_circle(LAUNCH_POSITION, 32.0, Color("54625d"))
