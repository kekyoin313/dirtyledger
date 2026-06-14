extends Control

# Hubungkan script GoogleAuth tadi. 
# Kamu bisa memasukkan GoogleAuth.gd ke dalam "Autoload (Singleton)" di Project Settings agar bisa diakses dari mana saja.
# Di sini diasumsikan GoogleAuth ditempel sebagai anak node (Child) atau dipanggil manual.

func _ready() -> void:
	# Tunggu sinyal sukses dari sistem GoogleAuth
	GoogleAuth.token_received.connect(_on_google_login_success)

func _on_guest_button_pressed() -> void:
	# Masuk sebagai guest langsung pindah scene
	TransitionManager.transition()
	await TransitionManager.on_transition_finished
	get_tree().change_scene_to_file("res://src/ui/main_menu/main_menu.tscn")

func _on_google_button_pressed() -> void:
	# Saat tombol Google ditekan, jangan langsung pindah scene, jalankan otorisasi dulu!
	GoogleAuth.authorize()

# Fungsi baru yang otomatis jalan kalau login Google berhasil
func _on_google_login_success() -> void:
	print("Login Google Sukses! Memindahkan scene...")
	TransitionManager.transition()
	await TransitionManager.on_transition_finished
	get_tree().change_scene_to_file("res://src/ui/main_menu/main_menu.tscn")
