extends Control

signal analisis_selesai(nama_barang)

@onready var texture_rect = $TextureRect
@onready var label_nama = $Label
@onready var btn_analisis = $ButtonAnalisis
@onready var progress_bar = $TextureProgressBar # Sesuaikan nama node ProgressBar di scenemu
@onready var timer = $Timer

var nama_item: String = ""
var sedang_analisis: bool = false

func set_bukti(nama: String, tex: Texture2D) -> void:
	nama_item = nama
	label_nama.text = nama
	texture_rect.texture = tex
	progress_bar.value = 0
	progress_bar.hide()

func mulai_proses_analisis() -> void:
	sedang_analisis = true
	btn_analisis.disabled = true
	progress_bar.show()
	timer.start(10.0) # Hitung mundur berjalan selama 10 detik fiktif

func _process(_delta: float) -> void:
	if sedang_analisis and not timer.is_stopped():
		# Mengisi progress bar dari 0% ke 100% berdasarkan sisa waktu timer
		progress_bar.value = ((10.0 - timer.time_left) / 10.0) * 100

func _on_timer_timeout() -> void:
	sedang_analisis = false
	progress_bar.hide()
	btn_analisis.disabled = false
	btn_analisis.text = "Lihat Hasil"
	analisis_selesai.emit(nama_item)
