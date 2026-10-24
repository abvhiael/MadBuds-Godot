extends StaticBody2D
class_name MadBudsDestructible

signal damaged(amount: float, remaining: float)
signal destroyed

@export var max_integrity := 110.0
@export var min_damage_speed := 170.0
@export var damage_scale := 0.12
@export var material_id := "wood"
var integrity := 110.0
var broken := false

func _ready() -> void:
	integrity = max_integrity

func receive_impact(relative_speed: float, impact_mass: float, impact_multiplier: float = 1.0) -> float:
	if broken or not is_finite(relative_speed) or not is_finite(impact_mass) or not is_finite(impact_multiplier):
		return 0.0
	if relative_speed < min_damage_speed or impact_mass <= 0.0 or impact_multiplier <= 0.0:
		return 0.0
	var damage: float = maxf(0.0, relative_speed - min_damage_speed) * impact_mass * impact_multiplier * damage_scale
	integrity = maxf(0.0, integrity - damage)
	damaged.emit(damage, integrity)
	if integrity <= 0.0:
		broken = true
		destroyed.emit()
		set_deferred("collision_layer", 0)
		set_deferred("collision_mask", 0)
		visible = false
	return damage
