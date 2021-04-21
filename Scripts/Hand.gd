extends Node2D

onready var Deck = get_node("../Deck")
onready var CardHolder = $CardHolder


var hand = []
var cardpath = "res://Graphics/Cards/"
var card_width

export var health = 3 setget set_health
export var playername = ""
export var cardscale = Vector2(1.5,1.5)

signal health_change(value)
signal dead()

func draw_cards(num):
	hand += Deck.give_cards(num)
	initialize_cards()
	place_cards()

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
		hand[i].change_sprite(cardpath+fullpart)
		hand[i].connect("active_card", self, "_active_card")
	
func place_cards():
	var path_length = $Path2D.curve.get_baked_length()
	var space
	var ideal_cardwidth
	var hand_width

	for i in hand.size():
		card_width = hand[0].card_width()
		ideal_cardwidth = card_width * 1.5
		hand_width = ideal_cardwidth * hand.size()
		CardHolder.add_child(hand[i])

		space = path_length
		$Path2D/PathFollow2D.offset = 0.0
		if hand_width < path_length:
			$Path2D/PathFollow2D.offset = (space - hand_width)/2

			print("ideal cardwidth space: " + str(ideal_cardwidth))
		else:
			ideal_cardwidth = space / hand.size()
			print("ideal cardwidth crowded: " + str(ideal_cardwidth))
		
		for card in hand.size():
			if !hand[card].dealt:
				hand[card].position = $DeckLocation.position
			hand[card].handposition = $Path2D/PathFollow2D/DeckSpawner.get_global_position()
			hand[card].handrotation = $Path2D/PathFollow2D/DeckSpawner.get_global_transform().get_rotation()
			hand[card].move_card(hand[card].handposition, hand[card].handrotation)
			hand[card].dealt = true

			$Path2D/PathFollow2D.offset += ideal_cardwidth
		$Path2D/PathFollow2D.offset = 0.0

func get_hand():
	return hand

func reset_hand():
	for i in hand.size():
		hand[i].kill_card()
	hand = []

func allow_selection(_selectable: bool):
	for i in hand.size():
		hand[i].selectable = _selectable

func search_remove_card(_card):
	var i = hand.find(_card)
	hand.remove(i)

func set_health(value):
	health = value
	emit_signal("health_change", value)
	if health <= 0: 
		emit_signal("dead")

func _active_card(card):
	for i in hand.size():
		hand[i].make_active(card)





