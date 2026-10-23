extends Object
class_name Interactable

func can_interact(interactor: Node3D) -> bool:
	return true

func interact(interactor: Node3D) -> void:
	pass

func get_prompt() -> String:
	return "Press E to interact"