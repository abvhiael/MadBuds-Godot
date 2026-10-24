extends RigidBody2D
class_name KushKrusher

signal ability_activated
signal ability_expired
signal collided_with_object(body: Node, speed: float, mass_at_impact: float, multiplier: float)

const CHARACTER_ID: StringName = &"kush-krusher"
const ABILITY_ID: StringName = &"wrecking-ball"
const DEFAULT_MASS := 3.5
const ABILITY_MASS_MULTIPLIER := 2.5
const ABILITY_DURATION := 1.25

var launched := false
var ability_used := false
var ability_active := false
var ability_remaining := 0.0

func _ready() -> void:
	mass = DEFAULT_MASS
	linear_damp = 0.35
	angular_damp = 1.0
	contact_monitor = true
	body_entered.connect(_on_body_entered)
	max_contacts_reported = 8
	freeze = true

func launch(velocity: Vector2) -> void:
	if launched:
		return
	freeze = false
	launched = true
	linear_velocity = velocity

func activate_wrecking_ball() -> bool:
	if not launched or ability_used or sleeping:
		return false
	ability_used = true
	ability_active = true
	ability_remaining = ABILITY_DURATION
	mass = DEFAULT_MASS * ABILITY_MASS_MULTIPLIER
	angular_damp = 2.0
	ability_activated.emit()
	return true

func _physics_process(delta: float) -> void:
	if not ability_active:
		return
	ability_remaining -= delta
	if ability_remaining <= 0.0:
		end_ability()

func end_ability() -> void:
	if not ability_active:
		return
	ability_active = false
	mass = DEFAULT_MASS
	angular_damp = 1.0
	ability_expired.emit()

func reset_for_next_shot() -> void:
	end_ability()
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze = true
	launched = false
	ability_used = false
	ability_remaining = 0.0

func _on_body_entered(body: Node) -> void:
	var multiplier := 1.75 if ability_active else 1.0
	collided_with_object.emit(body, linear_velocity.length(), mass, multiplier)
