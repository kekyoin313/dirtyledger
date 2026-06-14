extends CanvasLayer

signal on_transition_finished 

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer
# Memanggil node pemutar musik yang baru ditambahkan di editor
@onready var audio_player = $AudioStreamPlayer 

func _ready() -> void:
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished(anim_name):
	if anim_name == "fade_in":
		on_transition_finished.emit()
		animation_player.play("fade_out")
	elif anim_name == "fade_out":
		color_rect.visible = false
		# Opsional: Jika ingin musiknya langsung mati total saat layar kembali terang
		# audio_player.stop() 

func transition():
	color_rect.visible = true
	
	# MEMULAI MUSIK: Musik berbunyi seiring animasi fade_in dimulai
	if audio_player and audio_player.stream:
		audio_player.play()
		
	animation_player.play("fade_in")
