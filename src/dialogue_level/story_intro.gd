extends Control

# Memastikan tipe data node sesuai dengan tipe di susunan Scene
@onready var portrait_node: TextureRect = $CharPortrait
@onready var name_label: Label = $DialoguePanel/CharName
@onready var text_label: RichTextLabel = $DialoguePanel/DialogueText # Sudah RichTextLabel

# Array dinamis untuk menampung data dari JSON induk
var all_chapters_data: Dictionary = {}
var story_data: Array = []
var current_dialogue_index: int = 0
var is_paused: bool = false

func _ready() -> void:
	portrait_node.hide()
	
	# 1. Load seluruh data dari satu file JSON induk
	load_all_chapters_from_json("res://src/data/all_chapters.json")
	
	# 2. Ambil chapter aktif sesuai dengan tombol yang diklik di Menu Awal (Global Autoload)
	set_active_chapter(Global.current_chapter)
	
	# 3. Jalankan update dialog pertama kali untuk memunculkan teks indeks 0
	update_dialogue()


func load_all_chapters_from_json(file_path: String) -> void:
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var parsed_data = JSON.parse_string(json_string)
		if parsed_data is Dictionary:
			all_chapters_data = parsed_data
		else:
			push_error("Format data tingkat atas JSON harus objek {}")
	else:
		push_error("File JSON cerita tidak ditemukan di path: " + file_path)


func set_active_chapter(chapter_key: String) -> void:
	if all_chapters_data.has(chapter_key):
		story_data = all_chapters_data[chapter_key]
		current_dialogue_index = 0 # Reset ke awal baris dialog teks
		print("Memuat cerita: ", chapter_key, " | Total baris: ", story_data.size())
	else:
		push_error("ID Chapter tidak ditemukan di JSON: " + chapter_key)


func update_dialogue():
	# Memastikan indeks masih berada di dalam batas jumlah baris cerita di JSON
	if current_dialogue_index < story_data.size():
		var data = story_data[current_dialogue_index]
		
		# Set text langsung ke properti text milik Label dan RichTextLabel
		name_label.text = str(data.get("name", ""))
		text_label.text = str(data.get("text", ""))
		
		var portrait_path = data.get("portrait", "")
		
		# Ganti portrait karakter jika diatur di JSON dan filenya ada
		if not portrait_path.is_empty() and ResourceLoader.exists(portrait_path):
			portrait_node.texture = load(portrait_path)
			portrait_node.show()
		else:
			portrait_node.hide()
	else:
		# Pindah scene HANYA KETIKA seluruh data baris di chapter tersebut sudah habis dibaca
		handle_chapter_routing()


func _on_next_button_pressed():
	# Naikkan indeks setiap kali tombol Next ditekan pemain
	current_dialogue_index += 1
	update_dialogue()


func handle_chapter_routing():
	print("DEBUG: Selesai membaca seluruh cerita di ", Global.current_chapter)
	
	# Semua chapter diarahkan ke scene level pencarian yang sama (level1.tscn)
	# Nanti di dalam level1.tscn baru kita filter aset/barangnya berdasarkan chapter aktif
	get_tree().change_scene_to_file("res://src/search_level/level1.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
