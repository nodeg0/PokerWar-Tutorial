extends Area2D

#onready var Tween = $Tween

var cardname
var cardvalue = 0
var cardsuit
var dealt = false
var selectable = false setget set_selectable
var selected_card = false
var front_sprite_path
var cardowner

export (int) var focus_move_on_y = 40
export (Texture) var cardsprite
var cardscale setget change_cardscale
var handposition = Vector2.ZERO
var handrotation = Vector2.ZERO

signal active_card(node)
signal card_selected(node)

func set_selectable(val):
	selectable = val

func move_card(dest, rotate = null, _scale = null):

	$Tween.interpolate_property(self, "position" , position, dest, 0.5, Tween.TRANS_BACK, Tween.EASE_OUT)
	if rotate != null:
		$Tween.interpolate_property(self, "rotation", rotation, rotate, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if _scale != null:
		$Tween.interpolate_property(self, "scale", scale, _scale, 0.5, Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.start()

func change_sprite(res):
	$Sprite.texture = load(res)

func change_cardscale(_scale):
	scale = _scale

func card_width():
	var cardwidth = $Sprite.texture.get_width() * scale.x
	return cardwidth

func kill_card():
	if !$Tween.is_active():
		queue_free()
	else:
		yield($Tween, "tween_all_completed")
		queue_free()

func make_focus():
	if selectable:
		var position_shift = position
		position_shift.y -= focus_move_on_y
		if position == handposition:
			move_card(position_shift, 0.0)
		z_index = 2
		selected_card = true
		emit_signal("active_card", self)

func off_focus():
	if selectable:
		move_card(handposition, handrotation)
		z_index = 1
		selected_card = false

func make_active(card):
	if card != self:
		off_focus()

func _on_Card_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("left_click") and selected_card:
			selected_card = false
			emit_signal("card_selected", self)
		if !selected_card:
			make_focus()
