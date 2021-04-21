extends CanvasLayer


onready var PlayerHealth = $HealthContainer/PlayerHFull
onready var EnemyHealth = $HealthContainer/EnemyHFull

var msgqueue = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if msgqueue.size() > 0:
		if !$AnimationPlayer.is_playing():
			$Alert.text = msgqueue[0]
			msgqueue.remove(0)
			$AnimationPlayer.play("DisplayAlert")
			yield(get_node("AnimationPlayer"), "animation_finished")

func send_alert(msg):
	msgqueue.append(msg)

func still_running():
	if msgqueue.size() != 0 or $AnimationPlayer.is_playing() == true:
		return true
	else: 
		return false

func _on_PlayerHand_health_change(value) -> void:
	var hidehealth = false
	PlayerHealth.rect_size.x = 16 * value + 1
	if value <= 0:
		hidehealth = false
	else:
		hidehealth = true
	PlayerHealth.visible = hidehealth

func _on_EnemyHand_health_change(value) -> void:
	var hidehealth = false
	EnemyHealth.rect_size.x = 16 * value + 1
	if value <= 0:
		hidehealth = false
	else:
		hidehealth = true
	PlayerHealth.visible = hidehealth
