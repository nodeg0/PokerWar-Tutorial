extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
var player_card
var enemy_card
onready var PlayerCardPosition = $PlayerCardPosition
onready var EnemyCardPosition = $EnemyCardPosition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func play_war():
	player_card.move_card(PlayerCardPosition.position, 0.0, Vector2(1.0,1.0))
	enemy_card.move_card(EnemyCardPosition.position, 0.0)
	enemy_card.change_sprite(enemy_card.front_sprite_path)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
