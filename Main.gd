extends Node2D

onready var Deck = $CardController/Deck

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var card = []
# Called when the node enters the scene tree for the first time.
func _ready():
	card = Deck.give_cards(2)
	print(card)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
