# Contains functions related to a Flow ability.
# All Flow abilities should preload this resource.

class_name FlowAbility extends BaseTypeAbility

# returns a scene based on the type of reaction
func get_reaction_scene(reactant_element: String) -> Node2D:
	match reactant_element:
		"sunder": return SkillSceneHandler.get_scene_by_name("break")
		"entropy": return SkillSceneHandler.get_scene_by_name("fork")
		"construct": return SkillSceneHandler.get_scene_by_name("justice")
		"growth": return SkillSceneHandler.get_scene_by_name("pursuit")
		"wither": return SkillSceneHandler.get_scene_by_name("swarm")
		_: return null
