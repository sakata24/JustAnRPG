# This script is solely responsible for holding the data related to unique spells

extends Node

var ALL_SKILLS = {
	"skills": {
		"bolt": {
			"name": "bolt",
			"cooldown": 1.5,
			"dmg": 1.0,
			"element": "sunder",
			"lifetime": 0.5,
			"size": 1.0,
			"speed": 1.0,
			"timeout": 1.0,
			"type": "bullet",
			"price": 0,
			"description": "A particle of destruction launched in a direction"
		},
		"crack": {
			"name": "crack",
			"cooldown": 14.0,
			"dmg": 2.5,
			"element": "sunder",
			"lifetime": 0.5,
			"size": 10.0,
			"speed": 0.0,
			"timeout": 0.1,
			"type": "spell",
			"price": 25,
			"description": "Shatters the very fabric of space in a large area, dealing high damage"
		},
		"charge": {
			"name": "charge",
			"cooldown": 2.5,
			"dmg": 1.0,
			"element": "entropy",
			"lifetime": 0.5,
			"size": 1.3,
			"speed": 0.1,
			"timeout": 0.8,
			"type": "bullet",
			"price": 0,
			"description": "A bolt of pure energy that gets increased damage after a charge up"
		},
		"storm": {
			"name": "storm",
			"cooldown": 20.0,
			"dmg": 2.0,
			"element": "entropy",
			"lifetime": 5.0,
			"size": 12.0,
			"speed": 0.0,
			"timeout": 1.0,
			"type": "spell",
			"price": 25,
			"description": "Summons an indiscriminate storm that has special properties depending on the amount of targets in the area"
		},
		"cell": {
			"name": "cell",
			"cooldown": 8.0,
			"dmg": 1.0,
			"element": "growth",
			"lifetime": 0.8,
			"size": 1.0,
			"speed": 0.6,
			"timeout": 0.1,
			"type": "bullet",
			"price": 15,
			"description": "A growing cell that increases in damage and size"
		},
		"vine": {
			"name": "vine",
			"cooldown": 2.0,
			"dmg": 1.1,
			"element": "growth",
			"lifetime": 0.1,
			"size": 5.0,
			"speed": 0.0,
			"timeout": 0.1,
			"type": "spell",
			"price": 10,
			"description": "Conjures a thorny vine that pierces and instantly damages enemies"
		},
		"rock": {
			"name": "rock",
			"cooldown": 3,
			"dmg": 1.5,
			"element": "construct",
			"lifetime": 1,
			"size": 2.5,
			"speed": 0.3,
			"timeout": 1,
			"type": "bullet",
			"price": 0,
			"description": "A rock, suitable for reactions"
		},
		"fissure": {
			"name": "fissure",
			"cooldown": 12.0,
			"dmg": 0.5,
			"element": "construct",
			"lifetime": 3.5,
			"size": 4.0,
			"speed": 0.0,
			"timeout": 0.5,
			"type": "spell",
			"price": 25,
			"description": "Opens a fissure in the ground, dealing constant damage to targets whom walk into it"
		},
		"fountain": {
			"name": "fountain",
			"cooldown": 7.0,
			"dmg": 2.5,
			"element": "flow",
			"lifetime": 0.7,
			"size": 4.0,
			"speed": 0.0,
			"timeout": 0.5,
			"type": "spell",
			"price": 0,
			"description": "A burst of energy damaging all targets inside after a delay"
		},
		"displace": {
			"name": "displace",
			"cooldown": 8.0,
			"dmg": 0.8,
			"element": "flow",
			"lifetime": 0.5,
			"size": 2.0,
			"speed": 1.0,
			"timeout": 0.5,
			"type": "bullet",
			"price": 25,
			"description": "A projectile that shoves enemies on contact"
		},
		"suspend": {
			"name": "suspend",
			"cooldown": 9.0,
			"dmg": 0.1,
			"element": "wither",
			"lifetime": 1.5,
			"size": 10.0,
			"speed": 0.0,
			"timeout": 3.0,
			"type": "spell",
			"price": 15,
			"description": "Fills the area with decay, dealing damage constantly to targets"
		},
		"decay": {
			"name": "decay",
			"cooldown": 3.0,
			"dmg": 1.0,
			"element": "wither",
			"lifetime": 0.5,
			"size": 1.0,
			"speed": 0.8,
			"timeout": 0.5,
			"type": "bullet",
			"price": 10,
			"description": "Fires a bolt of decay that slows a target hit"
		}
	}
}
