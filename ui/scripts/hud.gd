extends CanvasLayer

@onready var score_label: Label = %ScoreLabel
@onready var collectibles_label: Label = %CollectiblesLabel
@onready var gravity_shift_status: Label = %GravityShiftStatus
@onready var gravity_shift_cooldown_bar: ProgressBar = %GravityShiftCooldownBar
@onready var objective_label: Label = %ObjectiveLabel
@onready var interaction_prompt: PanelContainer = %InteractionPrompt
@onready var interaction_label: Label = %InteractionLabel
@onready var control_hints_panel: PanelContainer = %ControlHintsPanel
@onready var control_hints_label: RichTextLabel = %ControlHintsLabel

var objective_visible: bool = false

func _ready() -> void:
	setup_control_hints()
	interaction_prompt.visible = false
	objective_label.visible = false

func setup_control_hints() -> void:
	var hints = [
		"[color=#ccaaee]WASD[/color] / [color=#ccaaee]Arrows[/color]  Move",
		"[color=#ccaaee]Space[/color]  Jump",
		"[color=#ccaaee]Shift[/color]  Sprint",
		"[color=#ccaaee]G[/color]  Gravity Shift",
		"[color=#ccaaee]E[/color]  Interact",
		"[color=#ccaaee]Esc[/color]  Pause"
	]
	control_hints_label.text = "\n".join(hints)

func update_score(score: int) -> void:
	score_label.text = "SCORE: %d" % score

func update_collectibles(found: int, total: int) -> void:
	collectibles_label.text = "COLLECTIBLES: %d / %d" % [found, total]

func update_objective(text: String) -> void:
	objective_label.text = text
	objective_label.visible = text != ""
	objective_visible = text != ""

func update_gravity_shift(status: String, cooldown: float = 0.0, max_cooldown: float = 1.0) -> void:
	gravity_shift_status.text = status
	gravity_shift_cooldown_bar.max_value = max_cooldown
	gravity_shift_cooldown_bar.value = cooldown
	
	match status:
		"READY":
			gravity_shift_status.self_modulate = Color(0.4, 1.0, 0.6, 1.0)
			gravity_shift_cooldown_bar.self_modulate = Color(0.4, 1.0, 0.6, 1.0)
		"ACTIVE":
			gravity_shift_status.self_modulate = Color(1.0, 0.8, 0.3, 1.0)
			gravity_shift_cooldown_bar.self_modulate = Color(1.0, 0.8, 0.3, 1.0)
		"COOLDOWN":
			gravity_shift_status.self_modulate = Color(1.0, 0.5, 0.3, 1.0)
			gravity_shift_cooldown_bar.self_modulate = Color(1.0, 0.5, 0.3, 1.0)
		"DISABLED":
			gravity_shift_status.self_modulate = Color(0.6, 0.6, 0.6, 1.0)
			gravity_shift_cooldown_bar.self_modulate = Color(0.6, 0.6, 0.6, 1.0)

func show_interaction_prompt(text: String) -> void:
	interaction_label.text = text
	interaction_prompt.visible = true
	interaction_prompt.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(interaction_prompt, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func hide_interaction_prompt() -> void:
	if not interaction_prompt.visible:
		return
	var tween = create_tween()
	tween.tween_property(interaction_prompt, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.finished.connect(_on_interaction_fade_finished)

func _on_interaction_fade_finished() -> void:
	interaction_prompt.visible = false
	interaction_prompt.modulate = Color(1, 1, 1, 1)

func set_control_hints_visible(visible: bool) -> void:
	control_hints_panel.visible = visible