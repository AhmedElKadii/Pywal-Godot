@tool
extends EditorPlugin

var dock

func _enter_tree():
	dock = Control.new()
	dock.set_custom_minimum_size(Vector2(200, 120))

	dock.name = "Pywal Godot"
	
	var vbox = VBoxContainer.new()
	dock.add_child(vbox)
	
	var label = Label.new()
	label.text = "Pywal Theme"
	vbox.add_child(label)
	
	var apply_button = Button.new()
	apply_button.text = "Apply Pywal Colors"
	apply_button.pressed.connect(_on_apply_pressed)
	vbox.add_child(apply_button)
	
	var info_label = Label.new()
	info_label.text = "Updates editor theme\nwith pywal colors"
	info_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(info_label)
	
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)

func _exit_tree():
	remove_control_from_docks(dock)

func _on_apply_pressed():
	if update_theme_from_pywal():
		print("Pywal theme applied successfully!")
	else:
		print("Failed to apply pywal theme")

func hex_to_color(hex_string: String) -> Color:
	hex_string = hex_string.strip_edges()
	if hex_string.begins_with("#"):
		hex_string = hex_string.substr(1)
	
	var color = Color.html(hex_string)
	return color

func update_theme_from_pywal() -> bool:
	var colors_path = OS.get_environment("HOME") + "/.cache/wal/colors.json"
	
	if not FileAccess.file_exists(colors_path):
		push_error("Pywal colors file not found at: " + colors_path)
		return false
	
	var file = FileAccess.open(colors_path, FileAccess.READ)
	if file == null:
		push_error("Could not open pywal colors file")
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Could not parse pywal colors JSON")
		return false
	
	var colors_data = json.data
	
	if not colors_data.has("special") or not colors_data.has("colors"):
		push_error("Invalid pywal colors format")
		return false
	
	var background_hex = colors_data.special.background
	var accent_hex = colors_data.colors.color1
	
	var background_color = hex_to_color(background_hex)
	var accent_color = hex_to_color(accent_hex)
	
	var editor_settings = EditorInterface.get_editor_settings()
	editor_settings.set_setting("interface/theme/preset", "Custom")
	editor_settings.set_setting("interface/theme/base_color", background_color)
	editor_settings.set_setting("interface/theme/accent_color", accent_color)
	
	print("Pywal theme applied!")
	print("Background: ", background_hex, " -> ", background_color)
	print("Accent: ", accent_hex, " -> ", accent_color)
	
	return true
