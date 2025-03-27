# Contains functions related to a Growth ability.
# All Growth abilities should preload this resource.

class_name GrowthAbility extends BaseTypeAbility

# returns a scene based on the type of reaction
func get_reaction_scene(reactant_element: String) -> Node2D:
	match reactant_element:
		"sunder": return SkillSceneHandler.get_scene_by_name("burst")
		"entropy": return SkillSceneHandler.get_scene_by_name("life")
		"construct": return SkillSceneHandler.get_scene_by_name("overgrowth")
		"flow": return SkillSceneHandler.get_scene_by_name("pursuit")
		"wither": return SkillSceneHandler.get_scene_by_name("extend")
		_: return null
