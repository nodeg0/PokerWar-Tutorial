extends CanvasLayer


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func send_alert(msg):
	$Alert.text = msg
	$AnimationPlayer.play("DisplayAlert")
