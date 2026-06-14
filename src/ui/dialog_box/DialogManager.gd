extends CanvasLayer

signal dialog_finished

@onready var nama_label = $TextureRect/NamaLabel
@onready var dialog_label = $TextureRect/DialogueLabel
@onready var background_rect = $Background
@onready var karakter_rect = $KarakterSprite

var dialog_data: Array = []
var current_index: int = 0

func start_dialog(data: Array):
	dialog_data = data
	current_index = 0
	show() # Menampilkan UI dialog
	show_current_dialog()

func show_current_dialog():
	if current_index < dialog_data.size():
		var current_data = dialog_data[current_index]
		nama_label.text = current_data["nama"]
		dialog_label.text = current_data["teks"]
		# Jika ada logika ganti ekspresi karakter atau background, bisa dimasukkan di sini
	
		if current_data.has("bg") and current_data["bg"] != "":
				background_rect.texture = load(current_data["bg"])
				background_rect.show()
		if current_data.has("karakter") and current_data["karakter"] != "":
			karakter_rect.texture = load(current_data["karakter"])
			karakter_rect.show()
	else:
		hide() # Sembunyikan UI jika dialog habis
		dialog_finished.emit() # Beri tahu scene utama bahwa dialog selesai

func _on_next_button_pressed():
	current_index += 1
	show_current_dialog()
