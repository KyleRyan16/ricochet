extends Control

@export var main_menu_scene : PackedScene = null

var _open : bool = false

func _ready() -> void:
	hide()

func _on_resume_pressed() -> void:
	close()

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)
	
func is_open() -> bool:
	return _open

func toggle():
	if !_open:
		open()
	else:
		close()
	
func open():
	show()
	World.set_paused(true)
	_open = true

func close():
	World.set_paused(false)
	hide()
	_open = false
