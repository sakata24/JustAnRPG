# Enemy represents a target that is able to recieve damage from the player
class_name Enemy extends CharacterBody2D

var damageNumber = preload("res://HUDs/DamageNumber.tscn")

# how fast i move
var speed = 0
# base speed for ref
var baseSpeed = 0
# my health
@export var health = 1
# max health
var maxHealth = 1
# last damage hit with
var lastElementsHitBy = []
# cc immune?
var cc_immune: bool = false
