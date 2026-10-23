extends CanvasLayer

var score_label: Label
var collectibles_label: Label
var objective_label: Label
var interaction_prompt: Label
var failure_message: PanelContainer
var failure_label: Label

var _score_manager
var _level_manager

var _player: Node = null
var _failure_timer: Timer = null

func _ready() -> void:
	score_label = get_node_or_null("MainContainer/VBoxContainer/TopBar/ScoreLabel")
	collectibles_label = get_node_or_null("MainContainer/VBoxContainer/TopBar/CollectiblesLabel")
	objective_label = get_node_or_null("MainContainer/VBoxContainer/TopBar/ObjectiveLabel")
	interaction_prompt = get_node_or_null("MainContainer/VBoxContainer/InteractionPrompt")
	failure_message = get_node_or_null("MainContainer/VBoxContainer/FailureMessage")
	failure_label = get_node_or_null("MainContainer/VBoxContainer/FailureMessage/FailureLabel")
	
	if not score_label:
		print("WARNING: ScoreLabel not found")
	if not collectibles_label:
		print("WARNING: CollectiblesLabel not found")
	if not objective_label:
		print("WARNING: ObjectiveLabel not found")
	if not interaction_prompt:
		print("WARNING: InteractionPrompt not found")
	if not failure_message:
		print("WARNING: FailureMessage not found")
	if not failure_label:
		print("WARNING: FailureLabel not found")
	
	_score_manager = get_node("/root/ScoreManager")
	_level_manager = get_node("/root/LevelManager")
	
	_score_manager.score_changed.connect(_on_score_changed)
	_score_manager.collectibles_changed.connect(_on_collectibles_changed)
	
	# Find player in scene
	_player = get_tree().get_first_node_in_group("player")
	if _player:
		_player.interact_target_changed.connect(_on_interact_target_changed)
	
	# Initialize
	_on_score_changed(_score_manager.get_score())
	_on_collectibles_changed(_score_manager.get_collectibles_found(), _score_manager.get_collectibles_total())

func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % new_score

func _on_collectibles_changed(found: int, total: int) -> void:
	if collectibles_label:
		collectibles_label.text = "Collectibles: %d / %d" % [found, total]

func _on_interact_target_changed(target) -> void:
	if interaction_prompt:
		if target:
			interaction_prompt.text = target.get_prompt()
			interaction_prompt.visible = true
		else:
			interaction_prompt.visible = false

func set_objective(text: String) -> void:
	if objective_label:
		objective_label.text = text

func show_failure_message(message: String, duration: float = 3.0) -> void:
	if failure_message and failure_label:
		failure_label.text = message
		failure_message.visible = true
		failure_message.modulate = Color(1, 1, 1, 0)
		
		var tween = create_tween()
		tween.tween_property(failure_message, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		
		if _failure_timer:
			_failure_timer.stop()
			_failure_timer.queue_free()
		_failure_timer = Timer.new()
		_failure_timer.one_shot = true
		_failure_timer.wait_time = duration
		_failure_timer.timeout.connect(_hide_failure_message)
		add_child(_failure_timer)
		_failure_timer.start()

func _hide_failure_message() -> void:
	if failure_message:
		var tween = create_tween()
		tween.tween_property(failure_message, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.finished.connect(_on_failure_fade_finished)

func _on_failure_fade_finished() -> void:
	if failure_message:
		failure_message.visible = false
		failure_message.modulate = Color(1, 1, 1, 1)