extends Control

@onready var dialog_manager = $DialogManager
# Data dialog diisi di sini (bisa berbeda-beda tiap scene)
var list_dialog = [
	{"nama": "SATRIA (AUDITOR)", "teks": "Saya Bambang, Auditor Forensik yang ditugaskan.", "bg": "res://assets/bg_level/bg_analisis.png",
		"karakter": "res://assets/character/angela/Angela2.webp"},
	{"nama": "SATRIA (AUDITOR)", "teks": "Laporan kas kecil terlihat tidak sinkron dengan fisik kas.", "bg": "res://assets/bg_level/bg_analisis.png",
		"karakter": "res://assets/character/angela/Angela2.webp"}
]

func _ready():
	# Hubungkan signal ketika dialog selesai untuk pindah scene / lanjut gameplay
	dialog_manager.dialog_finished.connect(_on_dialog_selesai)
	
	# Mulai dialog
	dialog_manager.start_dialog(list_dialog)

func _on_dialog_selesai():
	get_tree().change_scene_to_file("res://src/analisis_level/analisis.tscn")
