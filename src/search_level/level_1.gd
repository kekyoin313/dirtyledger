extends Node2D

var bukti_ditemukan = []
var total_bukti = 3

# Daftar barang yang dicari di level ini
var daftar_misi = ["Kwitansi", "Kunci", "Flashdisk"]

@onready var mission_ui = $CanvasLayer/MissionSuccessPanel # Buat panel success dulu di editor
@onready var label_container = $UI/InventoryBar/LabelContainer # Node HBoxContainer

# Hubungkan node objek visual kamu agar nanti bisa diganti teksturnya di masa produksi
@onready var obj1_node = $obj1
@onready var obj2_node = $obj2
@onready var obj3_node = $obj3

func _ready():
	# === LOGIKA ADAPTIF CHAPTER (UNTUK DEMO MAUPUN PRODUKSI) ===
	match Global.current_chapter:
		"chapter_1":
			print("Memuat Level Pencarian Bukti untuk Chapter 1")
			# Menggunakan aset default bawaan meja kasir kuartal 1
			
		"chapter_2":
			print("Memuat Level Pencarian Bukti untuk Chapter 2")
			# SEMENTARA DEMO: Barang disamakan. 
			# NANTI KALAU PRODUKSI, kamu tinggal unkomen & sesuaikan path gambar barunya di sini:
			# obj1_node.texture_normal = load("res://assets/character/admin/dokumen_palsu.png")
			# obj2_node.texture_normal = load("res://assets/character/admin/obeng.png")
			
		"chapter_3":
			print("Memuat Level Pencarian Bukti untuk Chapter 3")
			# SEMENTARA DEMO: Barang disamakan.
			
		_:
			print("Chapter tidak dikenal, menggunakan aset default.")
	# =========================================================

	buat_daftar_teks_misi() # Panggil fungsi buat bikin tulisan di bawah
	
	# Pastikan NamaNode-nya sesuai dengan yang ada di panel Scene (Hierarchy)
	$CanvasLayer/MissionSuccessPanel.lanjut_ke_analisis.connect(_on_ke_tahap_berikutnya)

func _on_ke_tahap_berikutnya():
	# PERBAIKAN: Tambahkan () setelah get_tree
	get_tree().call_deferred("change_scene_to_file", "res://src/analisis_level/analisis.tscn")

func buat_daftar_teks_misi():
	# Bersihkan container kalau ada sisa
	for child in label_container.get_children():
		child.queue_free()
	
	# Bikin Label otomatis buat tiap barang di daftar_misi
	for nama in daftar_misi:
		var label_baru = Label.new()
		label_baru.text = nama
		label_baru.name = "Label_" + nama # Kita kasih nama unik buat dicari nanti
		
		# Kasih sedikit jarak antar tulisan (margin)
		label_baru.add_theme_constant_override("margin_right", 30)
		
		# Masukkan ke dalam HBoxContainer
		label_container.add_child(label_baru)

func tambah_bukti(nama_bukti):
	if not bukti_ditemukan.has(nama_bukti):
		bukti_ditemukan.append(nama_bukti)
		print("Bukti didapat: ", nama_bukti)
		
		# EFEK VISUAL: Cari label tulisannya, lalu buat pudar (transparan)
		var label_teks = label_container.get_node_or_null("Label_" + nama_bukti)
		if label_teks:
			label_teks.modulate.a = 0.3 # Mengubah opacity jadi 30% (tanda sudah ketemu)

		# Cek apakah misi selesai
		if bukti_ditemukan.size() == total_bukti:
			tampilkan_mission_success()

func tampilkan_mission_success():
	$CanvasLayer/MissionSuccessPanel.muncul()

# --- Signal Tombol Barang ---

func _on_obj_1_pressed() -> void:
	obj1_node.hide()
	tambah_bukti("Kwitansi")

func _on_obj_2_pressed() -> void:
	obj2_node.hide()
	tambah_bukti("Kunci")

func _on_obj_3_pressed() -> void:
	obj3_node.hide()
	tambah_bukti("Flashdisk")
