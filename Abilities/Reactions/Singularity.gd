# Singularity:
# Creation: sunder + wither
# suck enemies in towards the source

class_name SingularityReaction extends AreaReaction

var my_parent
const BASE_SINGULARITY_RADIUS = 32

func init(reaction_components: Dictionary):
	set_singularity_size()
	init_particles()
	spawn_reaction_name("singularity!", get_parent(), Color("#7a0002"), Color("#591b82"))

# calculate and set the size of the singularity reaction
func set_singularity_size():
	var furthest_distance_from_center = 0
	for point in get_parent().get_node("CollisionPolygon2D").polygon:
		furthest_distance_from_center = max(abs(point.x - self.position.x), abs(point.y - self.position.y))
	$CollisionShape2D.shape.radius = furthest_distance_from_center

# ready up the particle generator for the discharge reaction
func init_particles():
	var singularity_size = $CollisionShape2D.shape.radius
	var size_to_base_ratio = singularity_size / BASE_SINGULARITY_RADIUS
	$CPUParticles2D.emission_sphere_radius = singularity_size + (10 * size_to_base_ratio)
	$CPUParticles2D.scale_amount_min *= size_to_base_ratio
	$CPUParticles2D.scale_amount_max *= size_to_base_ratio

# re-toggle the timer every time it times out
func _on_drag_timer_timeout():
	for body in get_overlapping_bodies():
		pull_body_towards_center(body)

# pull body towards center
func pull_body_towards_center(body: Node2D):
	body.global_translate(body.global_position.direction_to(self.global_position) * 3)
