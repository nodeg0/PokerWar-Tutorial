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

		ENDROUND:
			UI.send_alert("game over")

func deal_damage(cardowner):
	if Player.playername == cardowner:
		Enemy.health -= 1
	elif Enemy.playername == cardowner:
		Player.health -= 1	

func allow_selection():
	Player.allow_selection(true)

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
		gamestate = ENDROUND
	if gamestate == SELECT_CARD:
		gamestate = DRAW_STREET
