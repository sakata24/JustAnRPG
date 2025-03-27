extends Node2D

@export var DELAY_TIME := 1.0
@export var IMPACT_DISTANCE := 20
@export var RADIUS := 10

var player: Player = null

func _ready() -> void:
	var mesh = SphereMesh.new()
	$Area2D/CollisionShape2D.shape.radius = RADIUS
	mesh.radius = 1
	mesh.height = 2
	$Meter.mesh = mesh
	$Projectile.visible = false
	$Projectile.position.y -= IMPACT_DISTANCE
	$Projectile.visible = true
	var tween = create_tween()
	$DelayTimer.start(DELAY_TIME)
	tween.parallel().tween_property($Projectile, "position", Vector2.ZERO, DELAY_TIME+0.5).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property($Meter.mesh, "radius", RADIUS, DELAY_TIME).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property($Meter.mesh, "height", RADIUS*2, DELAY_TIME).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property($Projectile, "scale", Vector2.ONE, DELAY_TIME).set_trans(Tween.TRANS_LINEAR)
	

func _explode():
	$Range.visible = false
	$Meter.visible = false
	$Projectile.visible = false
	$GPUParticles2D.emitting = true
	if player != null:
		player.hit(3)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
