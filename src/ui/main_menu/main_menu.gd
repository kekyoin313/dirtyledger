extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_buttons.visible = true
	options.visible = false
	$Options.menu_ditutup.connect(_on_options_balik_ke_menu)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	TransitionManager.transition()
	await TransitionManager.on_transition_finished
	get_tree().change_scene_to_file("res://src/ui/main_lobby/main_lobby.tscn")

func _on_settings_pressed() -> void:
	main_buttons.visible = false
	options.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()
	

func _on_back_options_pressed() -> void:
	_ready()

func _on_options_balik_ke_menu():
	main_buttons.visible = true  # Nah, di sini baru deh munculin lagi
	print("Sip, tombol menu utama balik lagi!")
	
