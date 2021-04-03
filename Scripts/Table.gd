extends "res://Scripts/Hand.gd"

var carddistance = 65
onready var startpoint = $LeftPoint

func draw_flop():
	draw_cards(3)

func draw_street():
	draw_cards(1)

func place_cards():
	yield(get_tree().create_timer(0.3),"timeout")
	for i in hand.size():
		hand[i].handposition.y = startpoint.position.y
		hand[i].handposition.x = startpoint.position.x + (carddistance * i)
		add_child(hand[i])
		if !hand[i].dealt:
			hand[i].position = $Deck.position
		hand[i].dealt = true
		hand[i].move_card(hand[i].handposition, hand[i].handrotation)
#
