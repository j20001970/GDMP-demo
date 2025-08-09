class_name TextTask
extends Control

var request: HTTPRequest
var delegate := MediaPipeTaskBaseOptions.DELEGATE_CPU

@onready var external_files_disabled: Label = $VBoxContainer/ExternalFileDisabled
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var btn_back: Button = $VBoxContainer/Title/Back
@onready var input_text: LineEdit = $VBoxContainer/Input
@onready var output_label: RichTextLabel = $VBoxContainer/Output

func _exit_tree() -> void:
	if request:
		request.cancel_request()
		request = null

func _ready() -> void:
	btn_back.pressed.connect(self._back)
	input_text.text_submitted.connect(self._on_text_input)
	_init_task()

func _process(_delta: float) -> void:
	if request:
		var max_size := request.get_body_size()
		var cur_size := request.get_downloaded_bytes()
		progress_bar.value = round(float(cur_size) / float(max_size) * 100)

func _back() -> void:
	Global.go_to_main_scene()

func _get_external_file() -> void:
	progress_bar.hide()
	output_label.show()
	request = null
	_init_task()

func _init_task() -> void:
	input_text.editable = true

func _on_text_input(text: String) -> void:
	input_text.clear()
	_process_text(text)

func _process_text(_text: String) -> void:
	pass

func get_external_model(path: String) -> FileAccess:
	var file := Global.get_model(path)
	if file != null:
		return file
	output_label.hide()
	request = Global.get_external_model(path, _get_external_file)
	if request != null:
		progress_bar.show()
	else:
		external_files_disabled.show()
	return null
