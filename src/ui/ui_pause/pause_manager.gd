extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Sembunyikan menu saat game mulai
	# Pastikan di script Options.gd kamu sudah ada: signal menu_ditutup
	options_menu.menu_ditutup.connect(_on_options_balik_ke_pause)
	hide()

func _input(event):
	# "ui_cancel" biasanya tombol Esc
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	# Balikkan status pause (jika true jadi false, dst)
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused
	
func _on_resume_button_pressed():
	toggle_pause()

func _on_quit_button_pressed():
	get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@onready var options_menu = $Options # Pastikan path-nya benar
@onready var main_buttons = $MainButtons

func _on_option_button_pressed() -> void:
	# Sembunyikan tombol-tombol utama Pause (Resume, Quit, dll)
	main_buttons.hide() 
	# Munculkan menu Options
	options_menu.show()


func _on_return_button_pressed() -> void:
	# PENTING: Kembalikan status pause ke false sebelum pindah scene
	# Jika tidak, Main Menu kamu akan ikut membeku/pause
	get_tree().paused = false
	
	# Ganti "res://MainMenu.tscn" dengan path scene menu utama kamu yang asli
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
	# Fungsi ini akan terpanggil otomatis pas kamu klik BACK di menu Options
func _on_options_balik_ke_pause():
	main_buttons.show()
	print("Tombol Pause balik lagi, investigasi lanjut!")
