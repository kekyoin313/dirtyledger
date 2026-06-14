extends Panel

signal menu_ditutup


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_back_pressed() -> void:
	self.hide()
	menu_ditutup.emit() # Teriak! (Kalau di Godot 4 pake .emit())

func _on_back_button_pressed() -> void:
	# Sembunyikan menu ini sendiri
	self.hide() 
	emit_signal("menu_ditutup") # Teriak kalau menu lagi ditutup
	
