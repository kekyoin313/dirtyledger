extends Control

# Database Cerita Multi-Chapter Akuntansi Forensik (Sinkron dengan all_chapters.json)
var database_cerita = {
	"prologue": {
		"Kunci": "Kunci fisik ini digunakan untuk brankas rahasia di bawah meja kasir. Di dalamnya tersembunyi buku kas harian asli kuartal pertama.",
		"Flashdisk": "Flashdisk milik admin ini berisi file excel terenkripsi. Setelah dibongkar, ditemukan daftar aliran dana 'tak resmi' alias pembukuan ganda Dirty Ledger.",
		"Kwitansi": "Kwitansi biaya renovasi ini palsu. Stempel perusahaannya berbeda dengan stempel resmi, dan nominalnya sengaja digelembungkan hingga 10x lipat!"
	},
	"deposition": {
		"Kunci": "Kunci cadangan ruang arsip lantai dua. Digunakan pelaku untuk menyelinap masuk pada malam hari secara ilegal.",
		"Flashdisk": "Berisi riwayat log enkripsi sistem cloud server lokal yang merekam aktivitas penghapusan paksa data penjualan mingguan.",
		"Kwitansi": "Lembar otorisasi pengeluaran dana fiktif yang ditandatangani terburu-buru oleh Manajer Operasional cabang."
	},
	"subpoena": {
		"Kunci": "Kunci laci meja kerja pribadi sang Manajer. Menyimpan dokumen rekonsiliasi bank rahasia yang tidak pernah dilaporkan ke pusat.",
		"Flashdisk": "Berisi rekaman instruksi digital (memo suara) kepada staf kasir untuk memanipulasi laporan kas kecil harian.",
		"Kwitansi": "Bukti kuitansi transfer rekening pribadi luar negeri yang digunakan sebagai instrumen pencucian uang korupsi kafe."
	}
}

# Preload scene kecil kartu bukti
const SLOT_BUKTI = preload("res://src/analisis_level/SlotBukti.tscn")

# Ambil texture ikon barang bukti
var tex_kunci = preload("res://assets/evidence/kunci.png")
var tex_fd = preload("res://assets/evidence/flashdisk.png")
var tex_kwitansi = preload("res://assets/evidence/kwitansi.jpg")

# PERBAIKAN JALUR: Menuju kontainer meja papan hijau di dalam CanvasLayer kamu
@onready var slot_container = $CanvasLayer/TextureRect/HBoxContainer
@onready var story_panel = $CanvasLayer/StoryPanel
@onready var story_label = $CanvasLayer/StoryPanel/StoryLabel

func _ready() -> void:
	story_panel.hide()
	
	if slot_container == null:
		push_error("CRITICAL ERROR: HBoxContainer belum dibuat di dalam CanvasLayer/TextureRect editor!")
		return
		
	input_bukti_ke_meja()

func input_bukti_ke_meja() -> void:
	var bukti_pemain = ["Kunci", "Flashdisk", "Kwitansi"]
	
	# Bersihkan papan hijau dari sisa slot kartu lama
	for child in slot_container.get_children():
		child.queue_free()
	
	for nama in bukti_pemain:
		var slot_baru = SLOT_BUKTI.instantiate()
		slot_container.add_child(slot_baru) 
		
		var texture_barang = dapatkan_texture(nama)
		slot_baru.set_bukti(nama, texture_barang)
		
		# Hubungkan sinyal interaksi tombol kartu bukti
		slot_baru.analisis_selesai.connect(_on_barang_selesai_dianalisis)
		slot_baru.btn_analisis.pressed.connect(func(): _on_slot_klik(slot_baru))

func dapatkan_texture(nama: String) -> Texture2D:
	match nama:
		"Kunci": return tex_kunci
		"Flashdisk": return tex_fd
		"Kwitansi": return tex_kwitansi
	return null

func _on_slot_klik(slot: Node) -> void:
	if not slot.sedang_analisis and slot.btn_analisis.text != "Lihat Hasil":
		slot.mulai_proses_analisis()
	elif slot.btn_analisis.text == "Lihat Hasil":
		tampilkan_cerita(slot.nama_item)

func _on_barang_selesai_dianalisis(nama_barang: String) -> void:
	print("Notifikasi Forensik: Analisis selesai untuk " + nama_barang)

func tampilkan_cerita(nama_barang: String) -> void:
	var chapter_aktif = Global.current_chapter
	
	if database_cerita.has(chapter_aktif) and database_cerita[chapter_aktif].has(nama_barang):
		var cerita = database_cerita[chapter_aktif][nama_barang]
		story_label.text = "[b]HASIL ANALISIS " + nama_barang.to_upper() + ":[/b]\n\n" + cerita
		story_panel.show()
	else:
		push_error("Data naskah kosong untuk bab: " + str(chapter_aktif) + " - barang: " + nama_barang)

func _on_close_button_pressed() -> void:
	story_panel.hide()

func _on_back_button_pressed() -> void:
	print("Kembali menuju Main Lobby...")
	get_tree().change_scene_to_file("res://src/ui/main_lobby/main_lobby.tscn")
