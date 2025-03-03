extends Node

var main_scene := preload("res://Main.tscn")
var enable_download_files: bool = false
var model_dir := "user://GDMP"

func _get_external_file(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray,
	path: String,
	callback: Callable) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		return
	if response_code != HTTPClient.RESPONSE_OK:
		return
	if body.is_empty():
		return
	if DirAccess.make_dir_recursive_absolute(path.get_base_dir()) != OK:
		return
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_buffer(body)
	file.close()
	callback.call()

func go_to_main_scene() -> void:
	get_tree().change_scene_to_packed(main_scene)

func get_external_model(path: String, callback: Callable) -> HTTPRequest:
	if enable_download_files:
		var request = MediaPipeExternalFiles.get_model(path)
		if request != null:
			var save_path := model_dir.path_join(path)
			var request_callback = _get_external_file.bind(save_path, callback)
			request.request_completed.connect(request_callback)
			return request
	return null

func get_model(path: String) -> FileAccess:
	var model_path := model_dir.path_join(path)
	if FileAccess.file_exists(model_path):
		return FileAccess.open(model_path, FileAccess.READ)
	return null
