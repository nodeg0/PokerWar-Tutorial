extends CanvasLayer


onready var PlayerHealth = $HealthContainer/PlayerHFull
onready var EnemyHealth = $HealthContainer/EnemyHFull

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func send_alert(msg):
	$AnimationPlayer.stop()
	$Alert.text = msg
	$AnimationPlayer.play("DisplayAlert")


func _on_PlayerHand_health_change(value) -> void:
	var hidehealth = false
	PlayerHealth.rect_size.x = 16 * value + 1
	if value <= 18:
		hidehealth = true
	else:
		hidehealth = false
	PlayerHealth.visible = hidehealth

func _on_EnemyHand_health_change(value) -> void:
	var hidehealth = false
	EnemyHealth.rect_size.x = 16 * value + 1
	if value <= 18:
		hidehealth = true
	else:
		hidehealth = false
	PlayerHealth.visible = hidehealth
