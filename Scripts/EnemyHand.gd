extends "res://Scripts/Hand.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func sprite_cards():
	for i in hand.size():
		hand[i].change_sprite("res://Graphics/Cards/Card_Back2.png")
