extends Node2D

onready var Deck = $CardController/Deck
onready var Player = $CardController/PlayerHand
onready var Enemy = $CardController/EnemyHand
onready var Table = $CardController/Table
onready var Warcards = $CardController/WarCards
onready var UI = $UI

enum {
	SETUP
	SELECT_FLOPCARD
	DRAW_TURN
	SELECT_TURNCARD
	DRAW_RIVER
	SELECT_RIVERCARD
	ENDROUND
}

var gamestate = SETUP
var currentround
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
	gamestate = SELECT_FLOPCARD

func _process(delta: float) -> void:
	match gamestate:
		SELECT_FLOPCARD:
			if currentround != "flop":
				Player.allow_selection(true)
				currentround = "flop"
			if card_selected:
				Player.allow_selection(false)
				Warcards.play_war()
				
		SELECT_TURNCARD:
			pass
		SELECT_RIVERCARD:
			pass

func _card_selected(card):
	player_card = card
	Player.allow_selection(false)
	Player.search_remove_card(card)
	Enemy.search_remove_card(enemy_card)
	Player.place_cards()
	Warcards.player_card = player_card
	card_selected = true
	get_tree().call_group("players", "make_active", card)
