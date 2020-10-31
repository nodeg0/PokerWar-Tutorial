extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
var player_card
var enemy_card
var winner

onready var PlayerCardPosition = $PlayerCardPosition
onready var EnemyCardPosition = $EnemyCardPosition

signal war_played(winning_card)


func play_war():
	player_card.move_card(PlayerCardPosition.position, 0.0, Vector2(1.0,1.0))
	enemy_card.move_card(EnemyCardPosition.position, 0.0)
	enemy_card.change_sprite(enemy_card.front_sprite_path)
	winner = determine_winner(player_card, enemy_card)
	emit_signal("war_played", winner)

func kill_cards():
	if player_card != null:
		player_card.kill_card()
		enemy_card.kill_card()
	
func determine_winner(_player_card, _enemy_card):
	if _player_card.cardvalue + _enemy_card.cardvalue == 3:
		if _player_card.cardvalue == 1:
			return _enemy_card
		else:
			return _player_card
	else:
		if _player_card.cardvalue == _enemy_card.cardvalue:
			return null
		elif _player_card.cardvalue == 1:
			return _player_card
		elif _enemy_card.cardvalue == 1:
			return _enemy_card
		elif _player_card.cardvalue == max(_player_card.cardvalue, _enemy_card.cardvalue):
			return _player_card
		else:
			return _enemy_card
