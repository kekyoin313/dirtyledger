extends Control

# Menghubungkan langsung ke Node di Scene berdasarkan struktur di atas
@onready var energy_bar: ProgressBar = $Panel3/HeaderUI/EnergyBar
@onready var energy_label: Label = $Panel3/HeaderUI/EnergyBar/EnergyLabel
@onready var timer_label: Label = $Panel3/HeaderUI/TimerLabel

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	# 1. Update Nilai Progress Bar (Visual)
	energy_bar.value = EnergyManager.current_energy
	
	# 2. Update Teks Angka di Atas Progress Bar (Presisi)
	energy_label.text = str(EnergyManager.current_energy) + " / " + str(EnergyManager.MAX_ENERGY)
	
	# 3. Update Hitung Mundur Waktu (Refill)
	if EnergyManager.current_energy < EnergyManager.MAX_ENERGY:
		var time_left = int(EnergyManager.next_regen_time - Time.get_unix_time_from_system())
		
		# Validasi jika waktu minus saat proses transisi/sinkronisasi waktu
		if time_left < 0: 
			time_left = 0
			
		var minutes = time_left / 60
		var seconds = time_left % 60
		timer_label.text = "Refill in: %02d:%02d" % [minutes, seconds]
	else:
		timer_label.text = "FULL"


# ==================== KONTROL TOMBOL CHAPTER BERBASIS ENERGI ====================

# 1. Ketika Tombol "Prologue" (Chapter 1) Ditekan
func _on_prologue_button_pressed() -> void:
	# Cek dan kurangi 10 energi
	if EnergyManager.use_energy(10):
		Global.current_chapter = "chapter_1" # Set cerita ke chapter 1
		get_tree().change_scene_to_file("res://src/dialogue_level/StoryIntro.tscn")
	else:
		show_energy_warning()


# 2. Ketika Tombol "Deposition" (Chapter 2) Ditekan
func _on_deposition_button_pressed() -> void:
	if EnergyManager.use_energy(10):
		Global.current_chapter = "chapter_2" # Set cerita ke chapter 2
		get_tree().change_scene_to_file("res://src/dialogue_level/StoryIntro.tscn")
	else:
		show_energy_warning()


# 3. Ketika Tombol "Subpoena" (Chapter 3) Ditekan
func _on_subpoena_button_pressed() -> void:
	if EnergyManager.use_energy(10):
		Global.current_chapter = "chapter_3" # Set cerita ke chapter 3
		get_tree().change_scene_to_file("res://src/dialogue_level/StoryIntro.tscn")
	else:
		show_energy_warning()


# Fungsi bantuan jika energi habis agar kodingan rapi tidak berulang
func show_energy_warning() -> void:
	print("Energi tidak cukup! Silakan tunggu beberapa menit lagi atau beli di toko.")
	# Di sini nanti kamu bisa memunculkan pop-up UI peringatan di game kamu jika ada


func _on_button_exit() -> void:
	get_tree().quit()
