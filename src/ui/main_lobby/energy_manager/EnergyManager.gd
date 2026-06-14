extends Node

# Pengaturan Energi
const MAX_ENERGY: int = 100
const REGEN_TIME_SECONDS: int = 300 # Diubah kembali ke 5 menit (300 detik) untuk produksi nanti
const SAVE_PATH = "user://energy_data.save"

var current_energy: int = MAX_ENERGY
var next_regen_time: float = 0.0 # Timestamp kapan energi berikutnya bertambah

func _ready() -> void:
	load_energy_data()
	recalculate_offline_energy()

func _process(_delta: float) -> void:
	if current_energy < MAX_ENERGY:
		var current_time = Time.get_unix_time_from_system()
		if current_time >= next_regen_time:
			current_energy += 1
			next_regen_time = current_time + REGEN_TIME_SECONDS
			save_energy_data()

# Fungsi untuk mengurangi energi saat masuk level
func use_energy(amount: int) -> bool:
	# === MODE DEMO: Selalu kembalikan nilai true tanpa mengurangi energi ===
	print("Mode Demo: Energi gratis diaktifkan! Mengabaikan pengurangan sebesar ", amount)
	return true
	
	# === BAGIAN INI DIKOMENTARI UNTUK DEMO (UNTUK PRODUKSI: TINGGAL UNKOMEN DAN HAPUS RETURN TRUE DI ATAS) ===
	# if current_energy >= amount:
	# 	current_energy -= amount
	# 	# Jika baru berkurang dari kapasitas penuh, set waktu regen pertama
	# 	if current_energy == MAX_ENERGY - amount:
	# 		next_regen_time = Time.get_unix_time_from_system() + REGEN_TIME_SECONDS
	# 	save_energy_data()
	# 	return true # Sukses masuk level
	# return false # Energi tidak cukup
	# =========================================================================

# Menghitung energi yang terisi selama game ditutup (Offline)
func recalculate_offline_energy() -> void:
	if current_energy >= MAX_ENERGY or next_regen_time == 0.0:
		return
		
	var current_time = Time.get_unix_time_from_system()
	
	if current_time >= next_regen_time:
		var time_passed = current_time - next_regen_time
		var energy_gained = 1 + int(time_passed / REGEN_TIME_SECONDS)
		
		current_energy = min(current_energy + energy_gained, MAX_ENERGY)
		
		if current_energy < MAX_ENERGY:
			# Sisa waktu menuju ke energi berikutnya
			var remainder = int(time_passed) % REGEN_TIME_SECONDS
			next_regen_time = current_time + (REGEN_TIME_SECONDS - remainder)
		else:
			next_regen_time = 0.0
			
		save_energy_data()

# Sistem Save/Load sederhana
func save_energy_data() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(current_energy)
		file.store_var(next_regen_time)

func load_energy_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			current_energy = file.get_var()
			next_regen_time = file.get_var()
