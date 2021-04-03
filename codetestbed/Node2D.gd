extends Node2D

#var card_values = [1,2,3,4,5,6,7,8,9,10,11,12,13,
#					1,2,3,4,5,6,7,8,9,10,11,12,13,
#					1,2,3,4,5,6,7,8,9,10,11,12,13,
#					1,2,3,4,5,6,7,8,9,10,11,12,13]
#
#var card_suits = ["spade","spade","spade","spade","spade","spade","spade","spade",
#				"spade","spade","spade","spade","spade",
#				"heart","heart","heart","heart","heart","heart","heart","heart",
#				"heart","heart","heart","heart","heart",
#				"club","club","club","club","club","club","club","club",
#				"club","club","club","club","club",
#				"diamond","diamond","diamond","diamond","diamond","diamond","diamond","diamond",
#				"diamond","diamond","diamond","diamond","diamond"]


# str8flush
#var card_values = [1,2,3,10,13,11,12]
#
#var card_suits = ["spade","diamond","diamond", "spade","spade","spade","spade"]

## quads
#var card_values = [1,2,10,10,10,10,12]
#
#var card_suits = ["spade","diamond","club", "heart","diamond","spade","spade"]

# boat
#var card_values = [1,1,3,3,11,11,11]
#
#var card_suits = ["spade","diamond","diamond", "spade","heart","diamond","spade"]

# flush
#var card_values = [1,2,3,5,10,11,11]
#
#var card_suits = ["diamond","diamond","diamond", "diamond","diamond","spade","diamond"

## str8
#var card_values = [1,2,3,4,5,11,11]
#
#var card_suits = ["diamond","diamond","club", "club","diamond","spade","diamond"]

## trips
#var card_values = [1,1,1,5,7,11,12]
#
#var card_suits = ["diamond","heart","club", "club","heart","spade","diamond"]

# 2pair
var card_values = [1,1,4,5,7,12,12]

var card_suits = ["diamond","heart","club", "club","heart","spade","diamond"]

var deck = []
var holecards = []
var tablecards = []

var besthand
var handrank = 0
var main_value = 0
var second_value = 0
var kicker
var fourthCard
var fifthCard

func _ready():
	randomize()
	makedeck()
	tablecards = give_cards(5)
	holecards= give_cards(2)
	evaluate_hand(tablecards, holecards)

func makedeck():
	var cardscene = load("res://Card.tscn")
	var card

	for i in card_values.size():
		card = cardscene.instance()
		card.cardvalue = card_values[i]
		card.cardsuit = card_suits[i]
		deck.append(card)
	deck.shuffle()
#	print_card_suits(deck)
#	print_card_values(deck)
	print("deck made")

func give_cards(num):
	var cardreturn = []
	for i in num:
		cardreturn.append(deck[i])
	for i in cardreturn.size():
		deck.remove(0)
#		print(cardreturn[i].cardname)
#		print (cardreturn[i].cardname)
#	remove_drawn_cards(cardreturn)
	return cardreturn

func evaluate_hand(_table_cards, _holecards):
	var cardcombos

	cardcombos = build_cardcombos(_table_cards, _holecards)
	straight_flush_check(cardcombos)
	if handrank <9:
		quad_check(cardcombos)
	if handrank <8:
		boat_check(cardcombos) 
	if handrank <7:
		flush_check(cardcombos)
	if handrank <6:
		str8_check(cardcombos)
	if handrank <5:
		trips_check(cardcombos)
	if handrank <4:
		two_pair_check(cardcombos)
	if handrank <3:
		pair_check(cardcombos)
	if handrank <2:
		high_card_check(cardcombos)

func build_cardcombos(table, hole):
	var combos = []
	combos.append([table[0],table[1],table[2],table[3],table[4]])
	
	combos.append([hole[0],table[0],table[1],table[2],table[3]])
	combos.append([hole[0],table[0],table[1],table[2],table[4]])
	combos.append([hole[0],table[0],table[1],table[3],table[4]])
	combos.append([hole[0],table[0],table[2],table[3],table[4]])
	combos.append([hole[0],table[1],table[2],table[3],table[4]])
	
	combos.append([hole[1],table[0],table[1],table[2],table[3]])
	combos.append([hole[1],table[0],table[1],table[2],table[4]])
	combos.append([hole[1],table[0],table[1],table[3],table[4]])
	combos.append([hole[1],table[0],table[2],table[3],table[4]])
	combos.append([hole[1],table[1],table[2],table[3],table[4]])
	
	combos.append([hole[0], hole[1], table[0], table[1], table[2]])
	combos.append([hole[0], hole[1], table[0], table[1], table[3]])
	combos.append([hole[0], hole[1], table[0], table[2], table[3]])
	combos.append([hole[0], hole[1], table[1], table[2], table[3]])
	
	combos.append([hole[0], hole[1], table[0], table[1], table[4]])
	combos.append([hole[0], hole[1], table[0], table[2], table[4]])
	combos.append([hole[0], hole[1], table[1], table[2], table[4]])
	
	combos.append([hole[0], hole[1], table[0], table[3], table[4]])
	combos.append([hole[0], hole[1], table[1], table[3], table[4]])
	
	combos.append([hole[0], hole[1], table[2], table[3], table[4]])
	return combos
		
func straight_flush_check(cardcombos):
	print("str8 flush check")
	for hands in cardcombos.size():
		ace_check_straight(cardcombos[hands])
		cardcombos[hands].sort_custom(self, "sort_by_value")
		if straight_evaluate(cardcombos[hands]) && flush_evaluate(cardcombos[hands]):
			besthand = cardcombos[hands]
			kicker = cardcombos[hands][4].cardvalue
			print("str8 flush found")
			print("kicker " + str(kicker))
			handrank = 9

func quad_check(cardcombos):
	var quadsfound = false
	print("quad check started")
	for hands in cardcombos.size():
		cardcombos[hands].sort_custom(self, "sort_by_value")
		make_ace_high(cardcombos[hands])
		if (cardcombos[hands][1].cardvalue == cardcombos[hands][2].cardvalue && cardcombos[hands][2].cardvalue 
				== cardcombos[hands][3].cardvalue && cardcombos[hands][3].cardvalue == cardcombos[hands][4].cardvalue):
			if !quadsfound:
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][1].cardvalue
				kicker = cardcombos[hands][0].cardvalue
				print("end quads found")
				print_card_values(cardcombos[hands])
				print("kicker " + str(kicker))
				handrank = 8
				quadsfound = true
			else: 
				if cardcombos[hands][0].cardvalue > kicker:
					besthand = cardcombos[hands]
					main_value = cardcombos[hands][1].cardvalue
					kicker = cardcombos[hands][0].cardvalue
					print("end quads found")
					print_card_values(cardcombos[hands])
					print("kicker " + str(kicker))
					handrank = 8
		elif (cardcombos[hands][0].cardvalue == cardcombos[hands][1].cardvalue && cardcombos[hands][1].cardvalue 
				== cardcombos[hands][2].cardvalue && cardcombos[hands][2].cardvalue == cardcombos[hands][3].cardvalue):
			if !quadsfound:
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][0].cardvalue
				kicker = cardcombos[hands][4].cardvalue
				print("start quads found")
				print_card_values(cardcombos[hands])
				print("kicker " + str(kicker))
				handrank = 8
				quadsfound = true
			else:
				if cardcombos[hands][4].cardvalue > kicker.cardvalue:
					besthand = cardcombos[hands]
					main_value = cardcombos[hands][0].cardvalue
					kicker = cardcombos[hands][4].cardvalue
					print("start quads found")
					print_card_values(cardcombos[hands])
					print("kicker " + str(kicker))
					handrank = 8

func boat_check(cardcombos):
	var boatfound = false
	print("boat check started")
	for hands in cardcombos.size():
		print_card_values(cardcombos[hands])
		cardcombos[hands].sort_custom(self, "sort_by_value")
		make_ace_high(cardcombos[hands])
		if (cardcombos[hands][0].cardvalue == cardcombos[hands][1].cardvalue && cardcombos[hands][2].cardvalue 
				== cardcombos[hands][3].cardvalue && cardcombos[hands][3].cardvalue == cardcombos[hands][4].cardvalue):
			print("initial boatfound check--end")
			if !boatfound:
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][4].cardvalue
				second_value = cardcombos[hands][0].cardvalue
				kicker = 0
				print("end boat found(1st boat found)")
				print_card_values(cardcombos[hands])
				print("value " + str(main_value))
				print("pair value " + str(kicker))
				handrank = 7
				boatfound = true
			elif (cardcombos[hands][4].cardvalue > main_value) || (cardcombos[hands][4].cardvalue 
						== main_value && cardcombos[hands][0].cardvalue > kicker):
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][4].cardvalue
				second_value = cardcombos[hands][0].cardvalue
				kicker = 0
				print("2nd+ end boat found")
				print_card_values(cardcombos[hands])
				print("value " + str(main_value))
				print("pair value " + str(second_value))
				handrank = 7
				boatfound = true
		elif (cardcombos[hands][0].cardvalue == cardcombos[hands][1].cardvalue && cardcombos[hands][1].cardvalue 
				== cardcombos[hands][2].cardvalue) && (cardcombos[hands][3].cardvalue == cardcombos[hands][4].cardvalue):
			print("initial boatfound check--start")
			if !boatfound:
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][0].cardvalue
				second_value = cardcombos[hands][4].cardvalue
				kicker = 0
				print("start boat found(first boat found)")
				print_card_values(cardcombos[hands])
				print("value " + str(main_value))
				print("pair value " + str(second_value))
				handrank = 7
				boatfound = true
			elif (cardcombos[hands][0].cardvalue > main_value) || (cardcombos[hands][0].cardvalue 
					== main_value && cardcombos[hands][4].cardvalue > kicker):
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][0].cardvalue
				second_value = cardcombos[hands][4].cardvalue
				kicker = 0
				print("2nd + start boat found")
				print_card_values(cardcombos[hands])
				print("value " + str(main_value))
				print("pair value " + str(second_value))
				handrank = 7
				boatfound = true

func flush_check(cardcombos):
	var flushfound = false
	print("flush check started")
	for hands in cardcombos.size():
		cardcombos[hands].sort_custom(self, "sort_by_value")
		make_ace_high(cardcombos[hands])
		if flush_evaluate(cardcombos[hands]):
			if !flushfound:
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][4].cardvalue
				second_value = cardcombos[hands][3].cardvalue
				kicker = cardcombos[hands][2].cardvalue
				fourthCard = cardcombos[hands][1].cardvalue
				fifthCard = cardcombos[hands][0].cardvalue
				handrank = 6
				flushfound = true
#				print("Flush found")
#				print_card_values(cardcombos[hands])
#				print("kicker", str(kicker))
			else:
				if cardcombos[hands][4].cardvalue > main_value:
					besthand = cardcombos[hands]
					main_value = cardcombos[hands][4].cardvalue
					second_value = cardcombos[hands][3].cardvalue
					kicker = cardcombos[hands][2].cardvalue
					fourthCard = cardcombos[hands][1].cardvalue
					fifthCard = cardcombos[hands][0].cardvalue
					handrank = 6
					print("Better flush found", print_card_values(cardcombos[hands]))
				elif cardcombos[hands][4].cardvalue == main_value && (cardcombos[hands][3].cardvalue 
					> second_value):
					besthand = cardcombos[hands]
					main_value = cardcombos[hands][4].cardvalue
					second_value = cardcombos[hands][3].cardvalue
					kicker = cardcombos[hands][2].cardvalue
					fourthCard = cardcombos[hands][1].cardvalue
					fifthCard = cardcombos[hands][0].cardvalue
					handrank = 6
				elif cardcombos[hands][4].cardvalue == main_value && (cardcombos[hands][3].cardvalue 
					== second_value) && (cardcombos[hands][2].cardvalue > kicker):
					besthand = cardcombos[hands]
					main_value = cardcombos[hands][4].cardvalue
					second_value = cardcombos[hands][3].cardvalue
					kicker = cardcombos[hands][2].cardvalue
					fourthCard = cardcombos[hands][1].cardvalue
					fifthCard = cardcombos[hands][0].cardvalue
					handrank = 6
				elif cardcombos[hands][4].cardvalue == main_value && (cardcombos[hands][3].cardvalue 
					== second_value) && (cardcombos[hands][2].cardvalue == kicker) && (cardcombos[hands][1].cardvalue 
					> fourthCard):
					besthand = cardcombos[hands]
					main_value = cardcombos[hands][4].cardvalue
					second_value = cardcombos[hands][3].cardvalue
					kicker = cardcombos[hands][2].cardvalue
					fourthCard = cardcombos[hands][1].cardvalue
					fifthCard = cardcombos[hands][0].cardvalue
					handrank = 6
				elif cardcombos[hands][4].cardvalue == main_value && (cardcombos[hands][3].cardvalue 
					== second_value) && (cardcombos[hands][2].cardvalue == kicker) && (cardcombos[hands][1].cardvalue 
					== fourthCard) && (cardcombos[hands][0].cardvalue > fifthCard):
					besthand = cardcombos[hands]
					main_value = cardcombos[hands][4].cardvalue
					second_value = cardcombos[hands][3].cardvalue
					kicker = cardcombos[hands][2].cardvalue
					fourthCard = cardcombos[hands][1].cardvalue
					fifthCard = cardcombos[hands][0].cardvalue
					handrank = 6

func str8_check(cardcombos):
	var str8found = false
	print("Str8 check started")
	for hands in cardcombos.size():
		print_card_values(cardcombos[hands])
		ace_check_straight(cardcombos[hands])
		if straight_evaluate(cardcombos[hands]) && !str8found:
			besthand = cardcombos[hands]
			main_value = cardcombos[hands][4].cardvalue
			print("str8 found")
			print_card_values(cardcombos[hands])
			handrank = 5
			str8found = true
		elif straight_evaluate(cardcombos[hands]) && cardcombos[hands][4].cardvalue > main_value:
			besthand = cardcombos[hands]
			main_value = cardcombos[hands][4].cardvalue
			print("higher str8 found")
			print_card_values(cardcombos[hands])
			handrank = 5

func trips_check(cardcombos):

	var tripsfound = false
	print("trips check started")
	for hands in cardcombos.size():
		cardcombos[hands].sort_custom(self, "sort_by_value")
		make_ace_high(cardcombos[hands])
		if (cardcombos[hands][2].cardvalue == cardcombos[hands][3].cardvalue && cardcombos[hands][3].cardvalue 
			== cardcombos[hands][4].cardvalue):
			if !tripsfound:
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][2].cardvalue
				kicker = cardcombos[hands][1].cardvalue
				print("end trips found")
				print_card_values(cardcombos[hands])
				print("kicker " + str(kicker))
				handrank = 4
				tripsfound = true
			else: 
				if cardcombos[hands][1].cardvalue > kicker:
					besthand = cardcombos[hands]
					main_value = cardcombos[hands][2].cardvalue
					kicker = cardcombos[hands][1].cardvalue
					print("end trips found")
					print_card_values(cardcombos[hands])
					print("kicker " + str(kicker))
					handrank = 4		
		elif (cardcombos[hands][1].cardvalue == cardcombos[hands][2].cardvalue && cardcombos[hands][2].cardvalue 
			== cardcombos[hands][3].cardvalue):
			if !tripsfound:
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][1].cardvalue
				kicker = cardcombos[hands][4].cardvalue
				print("middle trips found")
				print_card_values(cardcombos[hands])
				print("kicker " + str(kicker))
				handrank = 4
				tripsfound = true
			else: 
				if cardcombos[hands][4].cardvalue > kicker:
					besthand = cardcombos[hands]
					main_value = cardcombos[hands][2].cardvalue
					kicker = cardcombos[hands][0].cardvalue
					print("middle trips found")
					print_card_values(cardcombos[hands])
					print("kicker " + str(kicker))
					handrank = 4
		elif (cardcombos[hands][0].cardvalue == cardcombos[hands][1].cardvalue && cardcombos[hands][1].cardvalue 
				== cardcombos[hands][2].cardvalue):
			if !tripsfound:
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][0].cardvalue
				kicker = cardcombos[hands][4].cardvalue
				print("start trips found")
				print_card_values(cardcombos[hands])
				print("kicker " + str(kicker))
				handrank = 4
				tripsfound = true
			else:
				if cardcombos[hands][4].cardvalue > kicker:
					besthand = cardcombos[hands]
					main_value = cardcombos[hands][0].cardvalue
					kicker = cardcombos[hands][4].cardvalue
					print("start trips found")
					print_card_values(cardcombos[hands])
					print("kicker " + str(kicker))
					handrank = 4
					tripsfound = true

func two_pair_check(cardcombos):
	var twopairfound = false
	print("2pair check started")
	for hands in cardcombos.size():
		print_card_values(cardcombos[hands])
		cardcombos[hands].sort_custom(self, "sort_by_value")
		make_ace_high(cardcombos[hands])
		if (cardcombos[hands][0].cardvalue == cardcombos[hands][1].cardvalue && cardcombos[hands][2].cardvalue 
				== cardcombos[hands][3].cardvalue):
			print("initial twopair found start")
			if !twopairfound:
				besthand = cardcombos[hands]
				kicker = cardcombos[hands][4].cardvalue
				main_value = cardcombos[hands][2].cardvalue
				second_value = cardcombos[hands][0].cardvalue
				print("2pair start found(1st found)")
				print_card_values(cardcombos[hands])
				print("high pair " + str(main_value))
				print("low pair" + str(second_value))
				print("kicker" + str(kicker))
				handrank = 3
				twopairfound = true
			elif (cardcombos[hands][2].cardvalue > main_value) || (cardcombos[hands][0].cardvalue > second_value
					&& cardcombos[hands][2].cardvalue == main_value)|| (cardcombos[hands][2].cardvalue==main_value 
					&& cardcombos[hands][4].cardvalue > kicker) || (cardcombos[hands][0].cardvalue == second_value
					&& cardcombos[hands][4].cardvalue > kicker):
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][4].cardvalue
				second_value = cardcombos[hands][2].cardvalue
				kicker = cardcombos[hands][0].cardvalue
				print("2nd+ start 2pair found")
				print_card_values(cardcombos[hands])
				print("high pair value " + str(main_value))
				print("low pair value " + str(second_value))
				print("kicker " + str(kicker))
				handrank = 3
				twopairfound = true
		elif (cardcombos[hands][0].cardvalue == cardcombos[hands][1].cardvalue && cardcombos[hands][3].cardvalue 
				== cardcombos[hands][4].cardvalue):
			print("initial twopair found split")
			if !twopairfound:
				besthand = cardcombos[hands]
				kicker = cardcombos[hands][2].cardvalue
				main_value = cardcombos[hands][3].cardvalue
				second_value = cardcombos[hands][0].cardvalue
				print("2pair split found(1st found)")
				print_card_values(cardcombos[hands])
				print("high pair " + str(main_value))
				print("low pair" + str(second_value))
				print("kicker" + str(kicker))
				handrank = 3
				twopairfound = true
			elif (cardcombos[hands][3].cardvalue > main_value) || (cardcombos[hands][0].cardvalue > second_value
					&& cardcombos[hands][3].cardvalue == main_value)|| (cardcombos[hands][3].cardvalue==main_value 
					&& cardcombos[hands][2].cardvalue > kicker) || (cardcombos[hands][0].cardvalue == second_value
					&& cardcombos[hands][2].cardvalue > kicker):
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][3].cardvalue
				second_value = cardcombos[hands][0].cardvalue
				kicker = cardcombos[hands][2].cardvalue
				print("2nd+ split 2pair found")
				print_card_values(cardcombos[hands])
				print("high pair value " + str(main_value))
				print("low pair value " + str(second_value))
				print("kicker " + str(kicker))
				handrank = 3
				twopairfound = true
		elif (cardcombos[hands][1].cardvalue == cardcombos[hands][2].cardvalue && cardcombos[hands][3].cardvalue 
				== cardcombos[hands][4].cardvalue):
			print("initial twopair found end")
			if !twopairfound:
				besthand = cardcombos[hands]
				kicker = cardcombos[hands][0].cardvalue
				main_value = cardcombos[hands][3].cardvalue
				second_value = cardcombos[hands][1].cardvalue
				print("2pair end found(1st found)")
				print_card_values(cardcombos[hands])
				print("high pair " + str(main_value))
				print("low pair" + str(second_value))
				print("kicker" + str(kicker))
				handrank = 3
				twopairfound = true
			elif (cardcombos[hands][3].cardvalue > main_value) || (cardcombos[hands][1].cardvalue > second_value
					&& cardcombos[hands][3].cardvalue == main_value)|| (cardcombos[hands][3].cardvalue==main_value 
					&& cardcombos[hands][0].cardvalue > kicker) || (cardcombos[hands][1].cardvalue == second_value
					&& cardcombos[hands][0].cardvalue > kicker):
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][3].cardvalue
				second_value = cardcombos[hands][1].cardvalue
				kicker = cardcombos[hands][0].cardvalue
				print("2nd+ split 2pair found")
				print_card_values(cardcombos[hands])
				print("high pair value " + str(main_value))
				print("low pair value " + str(second_value))
				print("kicker " + str(kicker))
				handrank = 3
				twopairfound = true

func pair_check(cardcombos):
	var pairfound = false
	print("pair check started")
	for hands in cardcombos.size():
		print_card_values(cardcombos[hands])
		cardcombos[hands].sort_custom(self, "sort_by_value")
		make_ace_high(cardcombos[hands])
		if (cardcombos[hands][0].cardvalue == cardcombos[hands][1].cardvalue):
			print("pair found 1st position")
			if !pairfound:
				besthand = cardcombos[hands]
				kicker = cardcombos[hands][4].cardvalue
				main_value = cardcombos[hands][0].cardvalue
				print("pair 1st pos found(1st found)")
				print_card_values(cardcombos[hands])
				print("pair " + str(main_value))
				print("kicker " + str(kicker))
				handrank = 2
				pairfound = true
			elif (cardcombos[hands][0].cardvalue > main_value) ||  (cardcombos[hands][0].cardvalue==main_value 
					&& cardcombos[hands][4].cardvalue > kicker):
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][0].cardvalue
				kicker = cardcombos[hands][4].cardvalue
				print("2nd+ start pair found")
				print_card_values(cardcombos[hands])
				print("pair value " + str(main_value))
				print("kicker " + str(kicker))
				handrank = 2
				pairfound = true
		elif (cardcombos[hands][1].cardvalue == cardcombos[hands][2].cardvalue):
			print("pair found 2nd position")
			if !pairfound:
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][1].cardvalue
				kicker = cardcombos[hands][4].cardvalue
				print("pair 2nd pos found(1st found)")
				print_card_values(cardcombos[hands])
				print("pair " + str(main_value))
				print("kicker " + str(kicker))
				handrank = 2
				pairfound = true
			elif (cardcombos[hands][1].cardvalue > main_value) || (cardcombos[hands][1].cardvalue==main_value 
					&& cardcombos[hands][4].cardvalue > kicker):
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][1].cardvalue
				kicker = cardcombos[hands][4].cardvalue
				print("2nd+ 2nd pos pair found")
				print_card_values(cardcombos[hands])
				print("pair value " + str(main_value))
				print("kicker " + str(kicker))
				handrank = 2
				pairfound = true
		elif (cardcombos[hands][2].cardvalue == cardcombos[hands][3].cardvalue):
			print("pair found 3rd position")
			if !pairfound:
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][2].cardvalue
				kicker = cardcombos[hands][4].cardvalue
				print("pair 3rd pos found(1st found)")
				print_card_values(cardcombos[hands])
				print("pair " + str(main_value))
				print("kicker " + str(kicker))
				handrank = 2
				pairfound = true
			elif (cardcombos[hands][2].cardvalue > main_value) || (cardcombos[hands][2].cardvalue==main_value 
					&& cardcombos[hands][4].cardvalue > kicker):
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][2].cardvalue
				kicker = cardcombos[hands][4].cardvalue
				print("2nd+ 3rd pos pair found")
				print_card_values(cardcombos[hands])
				print("pair value " + str(main_value))
				print("kicker " + str(kicker))
				handrank = 2
				pairfound = true
		elif (cardcombos[hands][3].cardvalue == cardcombos[hands][4].cardvalue):
			print("pair found end position")
			if !pairfound:
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][3].cardvalue
				kicker = cardcombos[hands][2].cardvalue
				print("pair end pos found(1st found)")
				print_card_values(cardcombos[hands])
				print("pair " + str(main_value))
				print("kicker " + str(kicker))
				handrank = 2
				pairfound = true
			elif (cardcombos[hands][3].cardvalue > main_value) || (cardcombos[hands][3].cardvalue==main_value 
					&& cardcombos[hands][2].cardvalue > kicker):
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][3].cardvalue
				kicker = cardcombos[hands][2].cardvalue
				print("2nd+ end pos pair found")
				print_card_values(cardcombos[hands])
				print("pair value " + str(main_value))
				print("kicker " + str(kicker))
				handrank = 2
				pairfound = true

func high_card_check(cardcombos):
	var highcardstarted = false
	print("highcard started")
	for hands in cardcombos.size():
		make_ace_high(cardcombos[hands])
		if !highcardstarted:
			besthand = cardcombos[hands]
			main_value = cardcombos[hands][4].cardvalue
			second_value = cardcombos[hands][3].cardvalue
			kicker = cardcombos[hands][2].cardvalue
			fourthCard = cardcombos[hands][1].cardvalue
			fifthCard = cardcombos[hands][0].cardvalue
			handrank = 1
			highcardstarted = true
		else:
			if cardcombos[hands][4].cardvalue > main_value:
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][4].cardvalue
				second_value = cardcombos[hands][3].cardvalue
				kicker = cardcombos[hands][2].cardvalue
				fourthCard = cardcombos[hands][1].cardvalue
				fifthCard = cardcombos[hands][0].cardvalue
				handrank = 1
			elif cardcombos[hands][4].cardvalue == main_value && (cardcombos[hands][3].cardvalue 
				> second_value):
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][4].cardvalue
				second_value = cardcombos[hands][3].cardvalue
				kicker = cardcombos[hands][2].cardvalue
				fourthCard = cardcombos[hands][1].cardvalue
				fifthCard = cardcombos[hands][0].cardvalue
				handrank = 1
			elif cardcombos[hands][4].cardvalue == main_value && (cardcombos[hands][3].cardvalue 
				== second_value) && (cardcombos[hands][2].cardvalue > kicker):
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][4].cardvalue
				second_value = cardcombos[hands][3].cardvalue
				kicker = cardcombos[hands][2].cardvalue
				fourthCard = cardcombos[hands][1].cardvalue
				fifthCard = cardcombos[hands][0].cardvalue
				handrank = 1
			elif cardcombos[hands][4].cardvalue == main_value && (cardcombos[hands][3].cardvalue 
				== second_value) && (cardcombos[hands][2].cardvalue == kicker) && (cardcombos[hands][1].cardvalue 
				> fourthCard):
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][4].cardvalue
				second_value = cardcombos[hands][3].cardvalue
				kicker = cardcombos[hands][2].cardvalue
				fourthCard = cardcombos[hands][1].cardvalue
				fifthCard = cardcombos[hands][0].cardvalue
				handrank = 1
			elif cardcombos[hands][4].cardvalue == main_value && (cardcombos[hands][3].cardvalue 
				== second_value) && (cardcombos[hands][2].cardvalue == kicker) && (cardcombos[hands][1].cardvalue 
				== fourthCard) && (cardcombos[hands][0].cardvalue > fifthCard):
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][4].cardvalue
				second_value = cardcombos[hands][3].cardvalue
				kicker = cardcombos[hands][2].cardvalue
				fourthCard = cardcombos[hands][1].cardvalue
				fifthCard = cardcombos[hands][0].cardvalue
				handrank = 1

func sort_by_value(a,b):
	if a.cardvalue < b.cardvalue:
		return true
	else: 
		return false

func ace_check_straight(_cards):
	var ace_low = false
#	var cards = _cards
#	print(cards[3].cardvalue)
#	print("ace check str8")
	if _cards[3].cardvalue <= 4 or _cards[4].cardvalue == 14 and _cards[3].cardvalue <= 5:
#		print("ace low value used")
		ace_low = true
	if !ace_low:
#		print("ace high value used")
		for i in _cards.size():
			if _cards[i].cardvalue == 1:
				_cards[i].cardvalue = 14	
	elif ace_low:
		for i in _cards.size():
			if _cards[i].cardvalue == 14:
				_cards[i].cardvalue = 1
	_cards.sort_custom(self, "sort_by_value")
#	print("ace_check complete")
#	print_card_values(cards)

func make_ace_high(cards):
	for i in cards.size():
		if cards[i].cardvalue == 1:
			cards[i].cardvalue = 14

func make_ace_low(cards):
	for i in cards.size():
		if cards[i].cardvalue == 14:
			cards[i].cardvalue = 1

func print_card_values(_hand):
	var output = ""
	for i in _hand.size():
		output += str(_hand[i].cardvalue) + " "

	print(output)

func straight_evaluate(cards):
	var one = cards[0].cardvalue
	var two = cards[1].cardvalue -1
	var three = cards[2].cardvalue -2
	var four = cards[3].cardvalue -3
	var five = cards[4].cardvalue -4

	if one == two && two == three && three == four && four == five:
		return true
	else:
		return false

func flush_evaluate(cards):
	var one = cards[0].cardsuit
	var two = cards[1].cardsuit
	var three = cards[2].cardsuit
	var four = cards[3].cardsuit
	var five = cards[4].cardsuit

	if one == two && two == three && three == four && four == five:
		return true
	else:
		return false
