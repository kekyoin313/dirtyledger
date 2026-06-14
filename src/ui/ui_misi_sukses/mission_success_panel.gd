extends Panel

signal lanjut_ke_analisis
var bisa_diklik: bool = false

func _ready() -> void:
	hide()
	modulate.a = 0
	scale = Vector2(0.9, 0.9) # Efek pop-up mulai dari agak kecil

func muncul() -> void:
	show()
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	bisa_diklik = true
	
	# PERBAIKAN: Membuat Label3 di dalam VBoxContainer berkedip loop (terang-redup)
	var t_blink = create_tween().set_loops()
	t_blink.tween_property($VBoxContainer/Label3, "modulate:a", 0.3, 0.8)
	t_blink.tween_property($VBoxContainer/Label3, "modulate:a", 1.0, 0.8)

func _input(event: InputEvent) -> void:
	if bisa_diklik and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			lanjutkan()

func lanjutkan() -> void:
	bisa_diklik = false
	print("DEBUG: Sinyal berpindah ke Tahap Analisis Bukti dipicu.")
	
	# Pemicu perpindahan scene langsung dari panel sukses
	get_tree().change_scene_to_file("res://src/analisis_level/analisis.tscn")
	emit_signal("lanjut_ke_analisis")
