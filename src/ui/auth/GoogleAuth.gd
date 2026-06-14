extends Node
# Simpan dengan nama GoogleAuth.gd dan daftarkan di Project Settings -> Autoload

const PORT := 31419
const BINDING := "127.0.0.1"

# Menggunakan Client ID dan Secret tipe Desktop App untuk pengujian di PC/Editor
const client_ID := "1097272051558-unsvn0t30mvenkg9r1dajs1hgpgg4up5.apps.googleusercontent.com"
const client_secret := "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"

const auth_server := "https://accounts.google.com/o/oauth2/v2/auth"
const token_req := "https://oauth2.googleapis.com/token"

var redirect_server := TCPServer.new()
var redirect_uri := "http://%s:%s" % [BINDING, PORT]
var token: String = ""
var refresh_token: String = ""

signal token_received

func _ready():
	set_process(false)

func authorize():
	load_tokens() 
	if await is_token_valid():
		print("Token lama masih valid.")
		emit_signal("token_received")
		return
	if await refresh_tokens():
		print("Token berhasil diperbarui menggunakan Refresh Token.")
		return
	# =========================================================================
	
	# Selama demo, game akan selalu langsung lari ke sini setiap kali di-run:
	print("Mode Demo: Memaksa membuka browser untuk login ulang...")
	get_auth_code()
func _process(_delta):
	if redirect_server.is_connection_available():
		var connection = redirect_server.take_connection()
		
		# Tunggu hingga data dari browser benar-benar masuk
		while connection.get_status() == StreamPeerTCP.STATUS_CONNECTED and connection.get_available_bytes() == 0:
			OS.delay_msec(10)
			
		var request = connection.get_string(connection.get_available_bytes())
		if request:
			# 1. Cari letak karakter 'code=' di dalam request HTTP
			var code_marker = "code="
			var code_pos = request.find(code_marker)
			
			if code_pos != -1:
				# Mengambil teks setelah 'code='
				var start_pos = code_pos + code_marker.length()
				var full_rest_of_string = request.substr(start_pos)
				
				# Pisahkan jika ada parameter lain seperti &scope atau spasi HTTP/1.1
				var auth_code = ""
				if full_rest_of_string.contains("&"):
					auth_code = full_rest_of_string.split("&")[0]
				else:
					auth_code = full_rest_of_string.split(" ")[0]
				
				# Bersihkan spasi atau karakter newline yang tidak sengaja terbawa
				auth_code = auth_code.strip_edges()
				
				print("Berhasil mendapatkan Auth Code: ", auth_code)
				
				# 2. Kirim respon HTML sukses ke browser
				connection.put_data("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n".to_utf8_buffer())
				connection.put_data("<h1 style='font-family:sans-serif; text-align:center; margin-top:50px;'>Login Sukses! Silakan kembali ke Game.</h1>".to_utf8_buffer())
				connection.disconnect_from_host()
				
				# 3. Hentikan server lokal dan jalankan penukaran token
				redirect_server.stop()
				set_process(false)
				
				get_token_from_auth(auth_code)
			else:
				print("Browser mengirimkan request, tetapi tidak ada parameter 'code' di dalamnya.")
				connection.put_data("HTTP/1.1 400 Bad Request\r\n\r\n".to_utf8_buffer())
				connection.disconnect_from_host()
func get_auth_code():
	set_process(true)
	var _err = redirect_server.listen(PORT, BINDING)
	
	var body_parts = PackedStringArray([
		"client_id=%s" % client_ID,
		"redirect_uri=%s" % redirect_uri,
		"response_type=code",
		"scope=openid email profile", # Menggunakan scope standar profil & email akun Google
	])
	var url = auth_server + "?" + "&".join(body_parts)
	OS.shell_open(url)
func get_token_from_auth(auth_code):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body_parts = PackedStringArray([
		"code=%s" % auth_code, 
		"client_id=%s" % client_ID,
		"client_secret=%s" % client_secret,
		"redirect_uri=%s" % redirect_uri,
		"grant_type=authorization_code"
	])
	var body = "&".join(body_parts)
	
	# Menggunakan HTTPRequest global milik tree (lebih aman di Godot 4)
	var http_request = HTTPRequest.new()
	get_tree().root.add_child(http_request) # Pasang langsung ke root agar tidak ikut terhapus saat ganti scene
	
	var error = http_request.request(token_req, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("HTTP Request Error saat menukar code dengan token")
		http_request.queue_free()
		return

	var response = await http_request.request_completed
	var response_body = JSON.parse_string(response[3].get_string_from_utf8())
	http_request.queue_free()

	if response_body and response_body.has("access_token"):
		token = response_body["access_token"]
		if response_body.has("refresh_token"):
			refresh_token = response_body["refresh_token"]
		
		save_tokens()
		print("Token berhasil didapatkan dan disimpan!")
		emit_signal("token_received") # Sinyal ini yang akan memicu perpindahan scene di script UI kamu
	else:
		print("Gagal menukarkan token. Respon server: ", response_body)
func refresh_tokens() -> bool:
	if refresh_token.is_empty(): return false
	
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body_parts = PackedStringArray([
		"client_id=%s" % client_ID,
		"client_secret=%s" % client_secret, # Sudah ditambahkan
		"refresh_token=%s" % refresh_token,
		"grant_type=refresh_token"
	])
	var body = "&".join(body_parts)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var error = http_request.request(token_req, headers, HTTPClient.METHOD_POST, body)
	if error != OK: return false
	
	var response = await http_request.request_completed
	var response_body = JSON.parse_string(response[3].get_string_from_utf8())
	http_request.queue_free()
	
	if response_body and response_body.get("access_token"):
		token = response_body["access_token"]
		save_tokens()
		emit_signal("token_received")
		return true
	return false

func is_token_valid() -> bool:
	if token.is_empty(): return false
	
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "access_token=%s" % token
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var error = http_request.request(token_req + "info", headers, HTTPClient.METHOD_POST, body)
	if error != OK: return false
	
	var response = await http_request.request_completed
	var response_body = JSON.parse_string(response[3].get_string_from_utf8())
	http_request.queue_free()
	
	if response_body and response_body.get("expires_in") and int(response_body["expires_in"]) > 0:
		return true
	return false

# ==================== SAVE / LOAD TOKENS ====================
const SAVE_PATH = "user://token.dat"

func save_tokens():
	var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, "dirtyledger_pass")
	if file:
		var tokens = {"token": token, "refresh_token": refresh_token}
		file.store_var(tokens)
		file.close()

func load_tokens():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, "dirtyledger_pass")
		if file:
			var tokens = file.get_var()
			token = tokens.get("token", "")
			refresh_token = tokens.get("refresh_token", "")
			file.close()
