extends Node2D

onready var Deck = $CardController/Deck
onready var Player = $CardController/PlayerHand
onready var Enemy = $CardController/EnemyHand
onready var Table = $CardController/Table
onready var Warcards = $CardController/WarCards
onready var UI = $UI
onready var EndWarTimer = $EndWarTimer

enum {
	SETUP
	SELECT_CARD
	DRAW_STREET
	ENDROUND
	POKER_EVALUATE
	START
	FLOP
	TURN
	RIVER
}

var gamestate = SETUP
var currentround = START
var card_selected = false
var player_card
var enemy_card 
var poker_calculating = true
var endround = false

var playerPokerData = {
	"name": "player",
	"high_card": false,
	"hole_cards": [],
	"table_cards": [],
	"all_cards": [],
	"besthand": [],
	"handrank": 0,
	"main_value": 0,
	"second_value": 0,
	"fourth_card": 0,
	"fifth_card": 0,
	"kicker": 0	
}
var enemyPokerData = {
	"name": "enemy",
	"high_card": false,
	"hole_cards": [],
	"table_cards": [],
	"all_cards": [],
	"besthand": [],
	"handrank": 0,
	"main_value": 0,
	"second_value": 0,
	"fourth_card": 0,
	"fifth_card": 0,
	"kicker": 0	
}
# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree().create_timer(1.0),"timeout")
	get_tree().call_group("players", "draw_cards", 3)
	Table.draw_flop()
	yield(get_tree().create_timer(1.0),"timeout")
	UI.send_alert("select war card!")
	enemy_card = Enemy.pass_card()
	Warcards.enemy_card = enemy_card
	gamestate = SELECT_CARD

func _process(delta: float) -> void:
	match gamestate:
		SELECT_CARD:
			if currentround == START:
				Player.allow_selection(true)
				currentround = FLOP
			if card_selected:
				Warcards.play_war()
				card_selected = false
		DRAW_STREET:
				get_tree().call_group("players", "draw_cards", 1)
				Table.draw_street()
				if currentround == TURN:
					UI.send_alert("turn - select warcard")
				elif currentround == RIVER:
					UI.send_alert(("river - select warcard"))
				enemy_card = Enemy.pass_card()
				Warcards.enemy_card = enemy_card
				call_deferred("allow_selection")
				gamestate = SELECT_CARD

		POKER_EVALUATE:
			if poker_calculating:
				Enemy.reveal_cards()
				playerPokerData["hole_cards"] = Player.get_hand()
				enemyPokerData["hole_cards"] = Enemy.get_hand()
				playerPokerData["table_cards"] = Table.get_hand()
				enemyPokerData["table_cards"] = Table.get_hand()
#				print_card_values(playerPokerData["hole_cards"])
				evaluate_hand(playerPokerData)
				evaluate_hand(enemyPokerData)
				calc_poker_winner()
				poker_calculating = false

		ENDROUND:
			UI.send_alert("game over")

func deal_damage(cardowner):
	if Player.playername == cardowner:
		Enemy.health -= 1
	elif Enemy.playername == cardowner:
		Player.health -= 1	

func allow_selection():
	Player.allow_selection(true)

### POKER LOGIC

func evaluate_hand(dict):
	print("evaluating hands")
	var cardcombos
	var table_cards = dict["table_cards"]
	print(table_cards)
	print("eval table cards")
	print_card_values(table_cards)
	print("eval_table_cards fm dict")
	print_card_values(dict["table_cards"])
	var hole_cards = dict["hole_cards"]
	print_card_values(dict["table_cards"])
	print_card_values(dict["hole_cards"])
	cardcombos = build_cardcombos(table_cards, hole_cards)
	straight_flush_check(dict, cardcombos)
	if dict["handrank"] <9:
		quad_check(dict, cardcombos)
	if dict["handrank"] <8:
		boat_check(dict, cardcombos) 
	if dict["handrank"] <7:
		flush_check(dict, cardcombos)
	if dict["handrank"] <6:
		str8_check(dict, cardcombos)
	if dict["handrank"] <5:
		trips_check(dict, cardcombos)
	if dict["handrank"] <4:
		two_pair_check(dict, cardcombos)
	if dict["handrank"] <3:
		pair_check(dict, cardcombos)
	if dict["handrank"] <2:
		high_card_check(dict, cardcombos)


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

func straight_flush_check(dict,cardcombos):
	var besthand = dict["besthand"]
#	var handrank = dict["handrank"]
#	var main_value = dict["main_value"]
#	print("str8 flush check")
	for hands in cardcombos.size():
		ace_check_straight(cardcombos[hands])
		cardcombos[hands].sort_custom(self, "sort_by_value")
		if straight_evaluate(cardcombos[hands]) && flush_evaluate(cardcombos[hands]):
			besthand = cardcombos[hands]
			dict["main_value"] = cardcombos[hands][4].cardvalue
			print("str8 flush found")
			print(str(dict["handrank"]))
			dict["handrank"] = 9
			print(str(dict["handrank"]))


func quad_check(dict, cardcombos):
	var quadsfound = false
	var besthand = dict["besthand"]

#	var kicker = dict["kicker"]
#	var handrank = dict["handrank"]
#	print("quad check started")
	for hands in cardcombos.size():
		cardcombos[hands].sort_custom(self, "sort_by_value")
		make_ace_high(cardcombos[hands])
		if (cardcombos[hands][1].cardvalue == cardcombos[hands][2].cardvalue && cardcombos[hands][2].cardvalue 
				== cardcombos[hands][3].cardvalue && cardcombos[hands][3].cardvalue == cardcombos[hands][4].cardvalue):
			if !quadsfound:
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][1].cardvalue
				dict["kicker"] = cardcombos[hands][0].cardvalue
				print("end quads found")
#				print_card_values(cardcombos[hands])
#				print("kicker " + str(kicker))
				dict["handrank"] = 8
				quadsfound = true
			else: 
				if cardcombos[hands][0].cardvalue > dict["kicker"]:
					besthand = cardcombos[hands]
					dict["main_value"] = cardcombos[hands][1].cardvalue
					dict["kicker"] = cardcombos[hands][0].cardvalue
					print("end quads found")
#					print_card_values(cardcombos[hands])
#					print("kicker " + str(kicker))
					dict["handrank"] = 8
		elif (cardcombos[hands][0].cardvalue == cardcombos[hands][1].cardvalue && cardcombos[hands][1].cardvalue 
				== cardcombos[hands][2].cardvalue && cardcombos[hands][2].cardvalue == cardcombos[hands][3].cardvalue):
			if !quadsfound:
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][0].cardvalue
				dict["kicker"] = cardcombos[hands][4].cardvalue
				print("start quads found")
#				print_card_values(cardcombos[hands])
#				print("kicker " + str(kicker))
				dict["handrank"] = 8
				quadsfound = true
			else:
				if cardcombos[hands][4].cardvalue > dict["kicker"]:
					besthand = cardcombos[hands]
					dict["main_value"] = cardcombos[hands][0].cardvalue
					dict["kicker"] = cardcombos[hands][4].cardvalue
					print("start quads found")
#					print_card_values(cardcombos[hands])
#					print("kicker " + str(kicker))
					dict["handrank"] = 8

func boat_check(dict, cardcombos):
	var boatfound = false

	var besthand = dict["besthand"]
#	var main_value = dict["main_value"]
#	var kicker = dict["kicker"]
#	var handrank = dict["handrank"]
#	var second_value = dict["second_value"]

#	print("boat check started")
	for hands in cardcombos.size():
#		print_card_values(cardcombos[hands])
		cardcombos[hands].sort_custom(self, "sort_by_value")
		make_ace_high(cardcombos[hands])
		if (cardcombos[hands][0].cardvalue == cardcombos[hands][1].cardvalue && cardcombos[hands][2].cardvalue 
				== cardcombos[hands][3].cardvalue && cardcombos[hands][3].cardvalue == cardcombos[hands][4].cardvalue):
#			print("initial boatfound check--end")
			if !boatfound:
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][4].cardvalue
				dict["second_value"] = cardcombos[hands][0].cardvalue
				dict["kicker"] = 0
				print("end boat found(1st boat found)")
#				print_card_values(cardcombos[hands])
#				print("value " + str(dict["main_value"]))
#				print("pair value " + str(kicker))
				dict["handrank"] = 7
				boatfound = true
			elif (cardcombos[hands][4].cardvalue > dict["main_value"]) || (cardcombos[hands][4].cardvalue 
						== dict["main_value"] && cardcombos[hands][0].cardvalue > dict["kicker"]):
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][4].cardvalue
				dict["second_value"] = cardcombos[hands][0].cardvalue
				dict["kicker"] = 0
#				print("2nd+ end boat found")
#				print_card_values(cardcombos[hands])
#				print("value " + str(dict["main_value"]))
#				print("pair value " + str(second_value))
				dict["handrank"] = 7
				boatfound = true
		elif (cardcombos[hands][0].cardvalue == cardcombos[hands][1].cardvalue && cardcombos[hands][1].cardvalue 
				== cardcombos[hands][2].cardvalue) && (cardcombos[hands][3].cardvalue == cardcombos[hands][4].cardvalue):
			print("initial boatfound check--start")
			if !boatfound:
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][0].cardvalue
				dict["second_value"] = cardcombos[hands][4].cardvalue
				dict["kicker"] = 0
#				print("start boat found(first boat found)")
#				print_card_values(cardcombos[hands])
#				print("value " + str(dict["main_value"]))
#				print("pair value " + str(second_value))
				dict["handrank"] = 7
				boatfound = true
			elif (cardcombos[hands][0].cardvalue > dict["main_value"]) || (cardcombos[hands][0].cardvalue 
					== dict["main_value"] && cardcombos[hands][4].cardvalue > dict["kicker"]):
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][0].cardvalue
				dict["second_value"] = cardcombos[hands][4].cardvalue
				dict["kicker"] = 0
#				print("2nd + start boat found")
#				print_card_values(cardcombos[hands])
#				print("value " + str(dict["main_value"]))
#				print("pair value " + str(second_value))
				dict["handrank"] = 7
				boatfound = true

func flush_check(dict, cardcombos):
	var flushfound = false
	
	var besthand = dict["besthand"]
	var main_value = dict["main_value"]
#	var kicker = dict["kicker"]
#	var handrank = dict["handrank"]
#	var second_value = dict["second_value"]
#	var fourthCard = dict["fourth_card"]
#	var fifthCard = dict["fifth_card"]
	
#	print("flush check started")
	for hands in cardcombos.size():
		cardcombos[hands].sort_custom(self, "sort_by_value")
		make_ace_high(cardcombos[hands])
		if flush_evaluate(cardcombos[hands]):
			if !flushfound:
				besthand = cardcombos[hands]
				main_value = cardcombos[hands][4].cardvalue
				dict["second_value"] = cardcombos[hands][3].cardvalue
				dict["kicker"] = cardcombos[hands][2].cardvalue
				dict["fourth_card"] = cardcombos[hands][1].cardvalue
				dict["fifth_card"] = cardcombos[hands][0].cardvalue
				dict["handrank"] = 6
				flushfound = true
				print("Flush found")
#				print_card_values(cardcombos[hands])
#				print("kicker", str(kicker))
			else:
				if cardcombos[hands][4].cardvalue > main_value:
					besthand = cardcombos[hands]
					main_value = cardcombos[hands][4].cardvalue
					dict["second_value"] = cardcombos[hands][3].cardvalue
					dict["kicker"] = cardcombos[hands][2].cardvalue
					dict["fourth_card"] = cardcombos[hands][1].cardvalue
					dict["fifth_card"] = cardcombos[hands][0].cardvalue
					dict["handrank"] = 6
#					print("Better flush found", print_card_values(cardcombos[hands]))
				elif cardcombos[hands][4].cardvalue == main_value && (cardcombos[hands][3].cardvalue 
					> dict["second_value"]):
					besthand = cardcombos[hands]
					main_value = cardcombos[hands][4].cardvalue
					dict["second_value"] = cardcombos[hands][3].cardvalue
					dict["kicker"] = cardcombos[hands][2].cardvalue
					dict["fourth_card"] = cardcombos[hands][1].cardvalue
					dict["fifth_card"] = cardcombos[hands][0].cardvalue
					dict["handrank"] = 6
				elif cardcombos[hands][4].cardvalue == main_value && (cardcombos[hands][3].cardvalue 
					== dict["second_value"]) && (cardcombos[hands][2].cardvalue > dict["kicker"]):
					besthand = cardcombos[hands]
					main_value = cardcombos[hands][4].cardvalue
					dict["second_value"] = cardcombos[hands][3].cardvalue
					dict["kicker"] = cardcombos[hands][2].cardvalue
					dict["fourth_card"] = cardcombos[hands][1].cardvalue
					dict["fifth_card"] = cardcombos[hands][0].cardvalue
					dict["handrank"] = 6
				elif cardcombos[hands][4].cardvalue == main_value && (cardcombos[hands][3].cardvalue 
					== dict["second_value"]) && (cardcombos[hands][2].cardvalue == dict["kicker"]) && (cardcombos[hands][1].cardvalue 
					> dict["fourth_card"]):
					besthand = cardcombos[hands]
					main_value = cardcombos[hands][4].cardvalue
					dict["second_value"] = cardcombos[hands][3].cardvalue
					dict["kicker"] = cardcombos[hands][2].cardvalue
					dict["fourth_card"] = cardcombos[hands][1].cardvalue
					dict["fifth_card"] = cardcombos[hands][0].cardvalue
					dict["handrank"] = 6
				elif cardcombos[hands][4].cardvalue == main_value && (cardcombos[hands][3].cardvalue 
					== dict["second_value"]) && (cardcombos[hands][2].cardvalue == dict["kicker"]) && (cardcombos[hands][1].cardvalue 
					== dict["fourth_card"]) && (cardcombos[hands][0].cardvalue > dict["fifth_card"]):
					besthand = cardcombos[hands]
					main_value = cardcombos[hands][4].cardvalue
					dict["second_value"] = cardcombos[hands][3].cardvalue
					dict["kicker"] = cardcombos[hands][2].cardvalue
					dict["fourth_card"] = cardcombos[hands][1].cardvalue
					dict["fifth_card"] = cardcombos[hands][0].cardvalue
					dict["handrank"] = 6

func str8_check(dict, cardcombos):
	var str8found = false
	
	var besthand = dict["besthand"]

	
#	print("Str8 check started")
	for hands in cardcombos.size():
#		print_card_values(cardcombos[hands])
		ace_check_straight(cardcombos[hands])
		if straight_evaluate(cardcombos[hands]) && !str8found:
			besthand = cardcombos[hands]
			dict["main_value"] = cardcombos[hands][4].cardvalue
			print("str8 found")
#			print_card_values(cardcombos[hands])
			dict["handrank"] = 5
			str8found = true
		elif straight_evaluate(cardcombos[hands]) && cardcombos[hands][4].cardvalue > dict["main_value"]:
			besthand = cardcombos[hands]
			dict["main_value"] = cardcombos[hands][4].cardvalue
#			print("higher str8 found")
#			print_card_values(cardcombos[hands])
			dict["handrank"] = 5

func trips_check(dict, cardcombos):

	var tripsfound = false
	
	var besthand = dict["besthand"]

	
#	print("trips check started")
	for hands in cardcombos.size():
		cardcombos[hands].sort_custom(self, "sort_by_value")
		make_ace_high(cardcombos[hands])
		if (cardcombos[hands][2].cardvalue == cardcombos[hands][3].cardvalue && cardcombos[hands][3].cardvalue 
			== cardcombos[hands][4].cardvalue):
			if !tripsfound:
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][2].cardvalue
				dict["kicker"] = cardcombos[hands][1].cardvalue
				print("end trips found")
				print_card_values(cardcombos[hands])
#				print("kicker " + str(kicker))
				dict["handrank"] = 4
				tripsfound = true
			else: 
				if cardcombos[hands][1].cardvalue > dict["kicker"]:
					besthand = cardcombos[hands]
					dict["main_value"] = cardcombos[hands][2].cardvalue
					dict["kicker"] = cardcombos[hands][1].cardvalue
#					print("end trips found")
					print_card_values(cardcombos[hands])
#					print("kicker " + str(kicker))
					dict["handrank"] = 4		
		elif (cardcombos[hands][1].cardvalue == cardcombos[hands][2].cardvalue && cardcombos[hands][2].cardvalue 
			== cardcombos[hands][3].cardvalue):
			if !tripsfound:
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][1].cardvalue
				dict["kicker"] = cardcombos[hands][4].cardvalue
				print("middle trips found")
				print_card_values(cardcombos[hands])
#				print("kicker " + str(kicker))
				dict["handrank"] = 4
				tripsfound = true
			else: 
				if cardcombos[hands][4].cardvalue > dict["kicker"]:
					besthand = cardcombos[hands]
					dict["main_value"] = cardcombos[hands][2].cardvalue
					dict["kicker"] = cardcombos[hands][0].cardvalue
#					print("middle trips found")
#					print_card_values(cardcombos[hands])
#					print("kicker " + str(kicker))
					dict["handrank"] = 4
		elif (cardcombos[hands][0].cardvalue == cardcombos[hands][1].cardvalue && cardcombos[hands][1].cardvalue 
				== cardcombos[hands][2].cardvalue):
			if !tripsfound:
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][0].cardvalue
				dict["kicker"] = cardcombos[hands][4].cardvalue
				print("start trips found")
#				print_card_values(cardcombos[hands])
#				print("kicker " + str(kicker))
				dict["handrank"] = 4
				tripsfound = true
			else:
				if cardcombos[hands][4].cardvalue > dict["kicker"]:
					besthand = cardcombos[hands]
					dict["main_value"] = cardcombos[hands][0].cardvalue
					dict["kicker"] = cardcombos[hands][4].cardvalue
					print("start trips found")
#					print_card_values(cardcombos[hands])
#					print("kicker " + str(kicker))
					dict["handrank"] = 4
					tripsfound = true

func two_pair_check(dict, cardcombos):
	var twopairfound = false
	
	var besthand = dict["besthand"]

	
#	print("2pair check started")
	for hands in cardcombos.size():
#		print_card_values(cardcombos[hands])
		cardcombos[hands].sort_custom(self, "sort_by_value")
		make_ace_high(cardcombos[hands])
		if (cardcombos[hands][0].cardvalue == cardcombos[hands][1].cardvalue && cardcombos[hands][2].cardvalue 
				== cardcombos[hands][3].cardvalue):
			print("initial twopair found start")
			if !twopairfound:
				besthand = cardcombos[hands]
				dict["kicker"] = cardcombos[hands][4].cardvalue
				dict["main_value"] = cardcombos[hands][2].cardvalue
				dict["second_value"] = cardcombos[hands][0].cardvalue
#				print("2pair start found(1st found)")
#				print_card_values(cardcombos[hands])
#				print("high pair " + str(main_value))
#				print("low pair" + str(second_value))
#				print("kicker" + str(kicker))
				dict["handrank"] = 3
				twopairfound = true
			elif (cardcombos[hands][2].cardvalue > dict["main_value"]) || (cardcombos[hands][0].cardvalue > dict["second_value"]
					&& cardcombos[hands][2].cardvalue == dict["main_value"])|| (cardcombos[hands][2].cardvalue==dict["main_value"] 
					&& cardcombos[hands][4].cardvalue > dict["kicker"]) || (cardcombos[hands][0].cardvalue == dict["second_value"]
					&& cardcombos[hands][4].cardvalue > dict["kicker"]):
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][4].cardvalue
				dict["second_value"] = cardcombos[hands][2].cardvalue
				dict["kicker"] = cardcombos[hands][0].cardvalue
#				print("2nd+ start 2pair found")
#				print_card_values(cardcombos[hands])
#				print("high pair value " + str(main_value))
#				print("low pair value " + str(second_value))
#				print("kicker " + str(kicker))
				dict["handrank"] = 3
				twopairfound = true
		elif (cardcombos[hands][0].cardvalue == cardcombos[hands][1].cardvalue && cardcombos[hands][3].cardvalue 
				== cardcombos[hands][4].cardvalue):
			print("initial twopair found split")
			if !twopairfound:
				besthand = cardcombos[hands]
				dict["kicker"] = cardcombos[hands][2].cardvalue
				dict["main_value"] = cardcombos[hands][3].cardvalue
				dict["second_value"] = cardcombos[hands][0].cardvalue
#				print("2pair split found(1st found)")
#				print_card_values(cardcombos[hands])
#				print("high pair " + str(main_value))
#				print("low pair" + str(second_value))
#				print("kicker" + str(kicker))
				dict["handrank"] = 3
				twopairfound = true
			elif (cardcombos[hands][3].cardvalue > dict["main_value"]) || (cardcombos[hands][0].cardvalue > dict["second_value"]
					&& cardcombos[hands][3].cardvalue == dict["main_value"])|| (cardcombos[hands][3].cardvalue==dict["main_value"] 
					&& cardcombos[hands][2].cardvalue > dict["kicker"]) || (cardcombos[hands][0].cardvalue == dict["second_value"]
					&& cardcombos[hands][2].cardvalue > dict["kicker"]):
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][3].cardvalue
				dict["second_value"] = cardcombos[hands][0].cardvalue
				dict["kicker"] = cardcombos[hands][2].cardvalue
#				print("2nd+ split 2pair found")
#				print_card_values(cardcombos[hands])
#				print("high pair value " + str(main_value))
#				print("low pair value " + str(second_value))
#				print("kicker " + str(kicker))
				dict["handrank"] = 3
				twopairfound = true
		elif (cardcombos[hands][1].cardvalue == cardcombos[hands][2].cardvalue && cardcombos[hands][3].cardvalue 
				== cardcombos[hands][4].cardvalue):
			print("initial twopair found end")
			if !twopairfound:
				besthand = cardcombos[hands]
				dict["kicker"] = cardcombos[hands][0].cardvalue
				dict["main_value"] = cardcombos[hands][3].cardvalue
				dict["second_value"] = cardcombos[hands][1].cardvalue
#				print("2pair end found(1st found)")
#				print_card_values(cardcombos[hands])
#				print("high pair " + str(main_value))
#				print("low pair" + str(second_value))
#				print("kicker" + str(kicker))
				dict["handrank"] = 3
				twopairfound = true
			elif (cardcombos[hands][3].cardvalue > dict["main_value"]) || (cardcombos[hands][1].cardvalue > dict["second_value"]
					&& cardcombos[hands][3].cardvalue == dict["main_value"])|| (cardcombos[hands][3].cardvalue==dict["main_value"] 
					&& cardcombos[hands][0].cardvalue > dict["kicker"]) || (cardcombos[hands][1].cardvalue == dict["second_value"]
					&& cardcombos[hands][0].cardvalue > dict["kicker"]):
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][3].cardvalue
				dict["second_value"] = cardcombos[hands][1].cardvalue
				dict["kicker"] = cardcombos[hands][0].cardvalue
#				print("2nd+ split 2pair found")
#				print_card_values(cardcombos[hands])
#				print("high pair value " + str(main_value))
#				print("low pair value " + str(second_value))
#				print("kicker " + str(kicker))
				dict["handrank"] = 3
				twopairfound = true

func pair_check(dict, cardcombos):
	var pairfound = false
	
	var besthand = dict["besthand"]
	
#	print("pair check started")
	for hands in cardcombos.size():
#		print_card_values(cardcombos[hands])
		cardcombos[hands].sort_custom(self, "sort_by_value")
		make_ace_high(cardcombos[hands])
		if (cardcombos[hands][0].cardvalue == cardcombos[hands][1].cardvalue):
			print("pair found 1st position")
			if !pairfound:
				besthand = cardcombos[hands]
				dict["kicker"] = cardcombos[hands][4].cardvalue
				dict["main_value"] = cardcombos[hands][0].cardvalue
#				print("pair 1st pos found(1st found)")
#				print_card_values(cardcombos[hands])
#				print("pair " + str(main_value))
#				print("kicker " + str(kicker))
				dict["handrank"] = 2
				pairfound = true
			elif (cardcombos[hands][0].cardvalue > dict["main_value"]) ||  (cardcombos[hands][0].cardvalue==dict["main_value"] 
					&& cardcombos[hands][4].cardvalue > dict["kicker"]):
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][0].cardvalue
				dict["kicker"] = cardcombos[hands][4].cardvalue
#				print("2nd+ start pair found")
#				print_card_values(cardcombos[hands])
#				print("pair value " + str(main_value))
#				print("kicker " + str(kicker))
				dict["handrank"] = 2
				pairfound = true
		elif (cardcombos[hands][1].cardvalue == cardcombos[hands][2].cardvalue):
#			print("pair found 2nd position")
			if !pairfound:
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][1].cardvalue
				dict["kicker"] = cardcombos[hands][4].cardvalue
				print("pair 2nd pos found(1st found)")
#				print_card_values(cardcombos[hands])
#				print("pair " + str(main_value))
#				print("kicker " + str(kicker))
				dict["handrank"] = 2
				pairfound = true
			elif (cardcombos[hands][1].cardvalue > dict["main_value"]) || (cardcombos[hands][1].cardvalue==dict["main_value"] 
					&& cardcombos[hands][4].cardvalue > dict["kicker"]):
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][1].cardvalue
				dict["kicker"] = cardcombos[hands][4].cardvalue
#				print("2nd+ 2nd pos pair found")
#				print_card_values(cardcombos[hands])
#				print("pair value " + str(main_value))
#				print("kicker " + str(kicker))
				dict["handrank"] = 2
				pairfound = true
		elif (cardcombos[hands][2].cardvalue == cardcombos[hands][3].cardvalue):
			print("pair found 3rd position")
			if !pairfound:
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][2].cardvalue
				dict["kicker"] = cardcombos[hands][4].cardvalue
#				print("pair 3rd pos found(1st found)")
#				print_card_values(cardcombos[hands])
#				print("pair " + str(main_value))
#				print("kicker " + str(kicker))
				dict["handrank"] = 2
				pairfound = true
			elif (cardcombos[hands][2].cardvalue > dict["main_value"]) || (cardcombos[hands][2].cardvalue==dict["main_value"] 
					&& cardcombos[hands][4].cardvalue > dict["kicker"]):
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][2].cardvalue
				dict["kicker"] = cardcombos[hands][4].cardvalue
#				print("2nd+ 3rd pos pair found")
#				print_card_values(cardcombos[hands])
#				print("pair value " + str(main_value))
#				print("kicker " + str(kicker))
				dict["handrank"] = 2
				pairfound = true
		elif (cardcombos[hands][3].cardvalue == cardcombos[hands][4].cardvalue):
			print("pair found end position")
			if !pairfound:
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][3].cardvalue
				dict["kicker"] = cardcombos[hands][2].cardvalue
#				print("pair end pos found(1st found)")
#				print_card_values(cardcombos[hands])
#				print("pair " + str(main_value))
#				print("kicker " + str(kicker))
				dict["handrank"] = 2
				pairfound = true
			elif (cardcombos[hands][3].cardvalue > dict["main_value"]) || (cardcombos[hands][3].cardvalue==dict["main_value"] 
					&& cardcombos[hands][2].cardvalue > dict["kicker"]):
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][3].cardvalue
				dict["kicker"] = cardcombos[hands][2].cardvalue
#				print("2nd+ end pos pair found")
#				print_card_values(cardcombos[hands])
#				print("pair value " + str(main_value))
#				print("kicker " + str(kicker))
				dict["handrank"] = 2
				pairfound = true

func high_card_check(dict, cardcombos):
	var highcardstarted = false
	
	var besthand = dict["besthand"]
	
	print("highcard started")
	for hands in cardcombos.size():
		make_ace_high(cardcombos[hands])
		if !highcardstarted:
			besthand = cardcombos[hands]
			dict["main_value"] = cardcombos[hands][4].cardvalue
			dict["second_value"] = cardcombos[hands][3].cardvalue
			dict["kicker"] = cardcombos[hands][2].cardvalue
			dict["fourth_card"] = cardcombos[hands][1].cardvalue
			dict["fifth_card"] = cardcombos[hands][0].cardvalue
			print(str(dict["handrank"]))
			dict["handrank"] = 1
			print(str(dict["handrank"]))

			highcardstarted = true
		else:
			if cardcombos[hands][4].cardvalue > dict["main_value"]:
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][4].cardvalue
				dict["second_value"] = cardcombos[hands][3].cardvalue
				dict["kicker"] = cardcombos[hands][2].cardvalue
				dict["fourth_card"] = cardcombos[hands][1].cardvalue
				dict["fifth_card"] = cardcombos[hands][0].cardvalue
				dict["handrank"] = 1
			elif cardcombos[hands][4].cardvalue == dict["main_value"] && (cardcombos[hands][3].cardvalue 
				> dict["second_value"]):
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][4].cardvalue
				dict["second_value"] = cardcombos[hands][3].cardvalue
				dict["kicker"] = cardcombos[hands][2].cardvalue
				dict["fourth_card"] = cardcombos[hands][1].cardvalue
				dict["fifth_card"] = cardcombos[hands][0].cardvalue
				dict["handrank"] = 1
			elif cardcombos[hands][4].cardvalue == dict["main_value"] && (cardcombos[hands][3].cardvalue 
				== dict["second_value"]) && (cardcombos[hands][2].cardvalue > dict["kicker"]):
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][4].cardvalue
				dict["second_value"] = cardcombos[hands][3].cardvalue
				dict["kicker"] = cardcombos[hands][2].cardvalue
				dict["fourth_card"] = cardcombos[hands][1].cardvalue
				dict["fifth_card"] = cardcombos[hands][0].cardvalue
				dict["handrank"] = 1
			elif cardcombos[hands][4].cardvalue == dict["main_value"] && (cardcombos[hands][3].cardvalue 
				== dict["second_value"]) && (cardcombos[hands][2].cardvalue == dict["kicker"]) && (cardcombos[hands][1].cardvalue 
				> dict["fourth_card"]):
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][4].cardvalue
				dict["second_value"] = cardcombos[hands][3].cardvalue
				dict["kicker"] = cardcombos[hands][2].cardvalue
				dict["fourth_card"] = cardcombos[hands][1].cardvalue
				dict["fifth_card"] = cardcombos[hands][0].cardvalue
				dict["handrank"] = 1
			elif cardcombos[hands][4].cardvalue == dict["main_value"] && (cardcombos[hands][3].cardvalue 
				== dict["second_value"]) && (cardcombos[hands][2].cardvalue == dict["kicker"]) && (cardcombos[hands][1].cardvalue 
				== dict["fourth_card"]) && (cardcombos[hands][0].cardvalue > dict["fifth_card"]):
				besthand = cardcombos[hands]
				dict["main_value"] = cardcombos[hands][4].cardvalue
				dict["second_value"] = cardcombos[hands][3].cardvalue
				dict["kicker"] = cardcombos[hands][2].cardvalue
				dict["fourth_card"] = cardcombos[hands][1].cardvalue
				dict["fifth_card"] = cardcombos[hands][0].cardvalue
				dict["handrank"] = 1

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
#	return output
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
		


func calc_poker_winner():
	var player = playerPokerData
	var enemy = enemyPokerData
#	var player_rank = determine_hand_rank(player["handrank"], 
#		player["kicker"], player["main_value"])
#	print("player_rank:" + player_rank)
#	"name": "Enemy",
#	"high_card": false,
#	"hole_cards": [],
#	"table_cards": [],
#	"all_cards": [],
#	"besthand": [],
#	"handrank": 0,
#	"main_value": 0,
#	"second_value": 0,
#	"fourth_card": 0,
#	"fifth_card": 0,
#	"kicker": 0	
#print(str(player["handrank"]))
	UI.send_alert((player["name"] + " has " + determine_hand_rank(player["handrank"], 
		player["kicker"], player["main_value"])))
	UI.send_alert((enemy["name"] + " has " + determine_hand_rank(enemy["handrank"], 
		enemy["kicker"], enemy["main_value"])))
	if player["handrank"] > enemy["handrank"]:
		UI.send_alert((player["name"] + " wins"))
	elif player["handrank"] < enemy["handrank"]:
		UI.send_alert((enemy["name"] + " wins"))
	else:
		if player["main_value"] > enemy["main_value"]:
			UI.send_alert((player["name"] + " wins"))
		elif player["main_value"] < enemy["main_value"]:
			UI.send_alert((enemy["name"] + " wins"))
		else:
			if player["second_value"] > enemy["second_value"]:
				UI.send_alert((player["name"] + " wins"))
			elif player["second_value"] < enemy["second_value"]:
				UI.send_alert((enemy["name"] + " wins"))
			else:
				if player["kicker"] > enemy["kicker"]:
					UI.send_alert((player["name"] + " wins"))
				elif player["kicker"] < enemy["kicker"]:
					UI.send_alert((enemy["name"] + " wins"))
				else:
					if player["fourth_card"] > enemy["fourth_card"]:
						UI.send_alert((player["name"] + " wins"))
					elif player["fourth_card"] < enemy["fourth_card"]:
						UI.send_alert((enemy["name"] + " wins"))
					else:
						if player["fifth_card"] > enemy["fifth_card"]:
							UI.send_alert((player["name"] + " wins"))
						elif player["fifth_card"] < enemy["fifth_card"]:
							UI.send_alert((enemy["name"] + " wins"))
						else:
							UI.send_alert("draw")

func determine_hand_rank(rank, kicker, main_value):
	
	var ret_string = ""
	var val = ""
	if main_value <=10:
		val = str(main_value)
	elif main_value == 11:
		val = "jack"
	elif main_value == 12:
		val = "queen"
	elif main_value == 13:
		val = "king"
	elif main_value == 14:
		val = "ace"
	
	if rank == 9 && kicker == 14:
		ret_string = "a royal flush"
	elif rank == 9:
		ret_string = "a straight flush"
	elif rank == 8:
		ret_string = ("four of a kind " + val + "s")
	elif rank == 7:
		ret_string = "a full house"
	elif rank == 6: 
		ret_string =  "a flush"
	elif rank == 5:
		ret_string =  "a straight"
	elif rank == 4:
		ret_string =  ("three of a kind" + val + "s")
	elif rank == 3:
		ret_string =  "two pair"
	elif rank == 2:
		ret_string =  ("a pair of " + val + "s")
	elif rank == 1:
		ret_string =  ("high card " + val)
	print("this is the return string")
	print(ret_string)
	return ret_string

#### SIGNAL FUNCTIONS


func _card_selected(card):
	player_card = card
	Player.allow_selection(false)
	Player.search_remove_card(card)
	Enemy.search_remove_card(enemy_card)
	Player.place_cards()
	Warcards.player_card = player_card
	get_tree().call_group("players", "make_active", card)
	card_selected = true

func _on_WarCards_war_played(winning_card) -> void:
	Player.search_remove_card(player_card)
	Enemy.search_remove_card(enemy_card)
	if winning_card == null:
		UI.send_alert("draw")
	else: 
		var announcement = winning_card.cardowner + " wins"
		UI.send_alert(announcement)
		deal_damage(winning_card.cardowner)
	EndWarTimer.start()

func _on_EndWarTimer_timeout() -> void:
	print("endwartimer timeout")
	Warcards.kill_cards()
	if currentround != RIVER:
		currentround += 1
	else:
		gamestate = POKER_EVALUATE
	if gamestate == SELECT_CARD:
		gamestate = DRAW_STREET
