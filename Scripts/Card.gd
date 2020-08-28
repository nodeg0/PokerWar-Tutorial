extends Area2D

var cardname
var cardvalue
var cardsuit

export (Texture) var cardsprite
var cardscale setget change_cardscale

func change_sprite(res):
	$Sprite.texture = load(res)

func change_cardscale(_scale):
	scale = _scale

func card_width():
	var cardwidth = $Sprite.texture.get_width() * $Sprite.scale.x
	return cardwidth

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
