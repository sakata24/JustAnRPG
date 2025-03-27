# Contains functions related to a Entropy ability.
# All Entropy abilities should preload this resource.

class_name EntropyAbility extends BaseTypeAbility

# returns a scene based on the type of reaction
func get_reaction_scene(reactant_element: String) -> Node2D:
	match reactant_element:
		"sunder": return SkillSceneHandler.get_scene_by_name("blast")
		"construct": return SkillSceneHandler.get_scene_by_name("discharge")
		"growth": return SkillSceneHandler.get_scene_by_name("life")
		"flow": return SkillSceneHandler.get_scene_by_name("fork")
		"wither": return SkillSceneHandler.get_scene_by_name("sickness")
		_: return null
