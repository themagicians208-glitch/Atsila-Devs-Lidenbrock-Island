extends Area3D
class_name BouncePad

## A trampoline / bounce pad that launches the player upward.

@export var strength := 16.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		var character := body as CharacterBody3D
		if character.velocity.y <= 0.5 and character.has_method("bounce"):
			character.bounce(strength)