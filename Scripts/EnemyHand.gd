extends "res://Scripts/Hand.gd"

func pass_card():
	var passed_card
	passed_card = hand[0]
	hand.remove(0)
	return passed_card

func initialize_cards():
	var firstpart
	var secondpart
	var fullpart
	for i in hand.size():
		hand[i].cardscale = cardscale
		hand[i].cardowner = playername
		fullpart = ""
		if hand[i].cardsuit == "spade":
			firstpart = "Spades_"
		elif hand[i].cardsuit == "diamond":
			firstpart = "Diamonds_"
		elif hand[i].cardsuit == "club":
			firstpart = "Clubs_"
		elif hand[i].cardsuit == "heart":
			firstpart = "Hearts_"
		if hand[i].cardvalue == 1:
			secondpart = "Ace.png"
		elif hand[i].cardvalue == 11:
			secondpart = "Jack.png"
		elif hand[i].cardvalue == 12:
			secondpart = "Queen.png"
		elif hand[i].cardvalue == 13:
			secondpart = "King.png"
		else:
			secondpart = str(hand[i].cardvalue) + ".png"
		fullpart = firstpart + secondpart
		hand[i].front_sprite_path = cardpath+fullpart
		hand[i].change_sprite("res://Graphics/Cards/Card_Back2.png")

func reveal_cards():
	var firstpart
	var secondpart
	var fullpart
	
	for i in hand.size():
#		fullpart = firstpart + secondpart
#		hand[i].front_sprite_path = cardpath+fullpart
		hand[i].cardscale = Vector2(2.0,2.0)
		hand[i].change_sprite(hand[i].front_sprite_path)
	$Path2D/PathFollow2D.unit_offset = 0.0
	hand[0].move_card(($Path2D/PathFollow2D/DeckSpawner.get_global_position()+Vector2(0,-50)), 0.0)
	$Path2D/PathFollow2D.unit_offset = 1.0
	hand[1].move_card(($Path2D/PathFollow2D/DeckSpawner.get_global_position()+Vector2(0,-50)), 0.0)
