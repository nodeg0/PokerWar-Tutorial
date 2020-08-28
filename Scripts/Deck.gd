extends Node


var card_names = ["Ace_Spades", "2_Spades", "3_Spades", 
				"4_Spades", "5_Spades", "6_Spades", "7_Spades", 
				"8_Spades", "9_Spades", "10_Spades", "Jack_Spades", 
				"Queen_Spades", "King_Spades", "Ace_Hearts", 
				"2_Hearts", "3_Hearts", "4_Hearts", "5_Hearts", 
				"6_Hearts", "7_Hearts", "8_Hearts", "9_Hearts", 
				"10_Hearts", "Jack_Hearts", "Queen_Hearts", 
				"King_Hearts", "Ace_Clubs", "2_Clubs", 
				"3_Clubs", "4_Clubs", "5_Clubs", "6_Clubs", 
				"7_Clubs", "8_Clubs", "9_Clubs", "10_Clubs", 
				"Jack_Clubs", "Queen_Clubs", "King_Clubs", 
				"Ace_Diamonds", "2_Diamonds", "3_Diamonds", 
				"4_Diamonds", "5_Diamonds", "6_Diamonds", 
				"7_Diamonds", "8_Diamonds", "9_Diamonds", 
				"10_Diamonds", "Jack_Diamonds", "Queen_Diamonds", 
				"King_Diamonds"]

var card_values = [1,2,3,4,5,6,7,8,9,10,11,12,13,
					1,2,3,4,5,6,7,8,9,10,11,12,13,
					1,2,3,4,5,6,7,8,9,10,11,12,13,
					1,2,3,4,5,6,7,8,9,10,11,12,13]

var card_suits = ["spade","spade","spade","spade","spade","spade","spade","spade",
				"spade","spade","spade","spade","spade",
				"heart","heart","heart","heart","heart","heart","heart","heart",
				"heart","heart","heart","heart","heart",
				"club","club","club","club","club","club","club","club",
				"club","club","club","club","club",
				"diamond","diamond","diamond","diamond","diamond","diamond","diamond","diamond",
				"diamond","diamond","diamond","diamond","diamond"]
var deck = []
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	makedeck()

func give_cards(num):
	var cardreturn = []
	for i in num:
		cardreturn.append(deck[i])
		print(cardreturn[i].cardname)
	for i in cardreturn.size():
		deck.remove(0)
	return cardreturn

func makedeck():
	var cardscene = load("res://Scenes/Card.tscn")
	var card
	for i in card_names.size():
		card = cardscene.instance()
		card.cardname = card_names[i]
		card.cardvalue = card_values[i]
		card.cardsuit = card_suits[i]
		deck.append(card)
	deck.shuffle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
