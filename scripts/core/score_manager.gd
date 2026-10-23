extends Node

signal score_changed(new_score: int)
signal collectibles_changed(found: int, total: int)

var _score: int = 0
var _collectibles_found: int = 0
var _collectibles_total: int = 0
var _collectible_values: Dictionary = {}

func add(points: int) -> void:
	_score += points
	score_changed.emit(_score)

func get_score() -> int:
	return _score

func reset() -> void:
	_score = 0
	_collectibles_found = 0
	score_changed.emit(_score)
	collectibles_changed.emit(_collectibles_found, _collectibles_total)

func register_collectible(collectible_id: String, value: int) -> void:
	if not _collectible_values.has(collectible_id):
		_collectible_values[collectible_id] = value
		_collectibles_total += 1
		collectibles_changed.emit(_collectibles_found, _collectibles_total)

func collect(collectible_id: String) -> void:
	if _collectible_values.has(collectible_id):
		var value = _collectible_values[collectible_id]
		_collectible_values.erase(collectible_id)
		_collectibles_found += 1
		add(value)
		collectibles_changed.emit(_collectibles_found, _collectibles_total)

func get_collectibles_found() -> int:
	return _collectibles_found

func get_collectibles_total() -> int:
	return _collectibles_total