class_name AudioTask
extends Control

var request: HTTPRequest
var running_mode := MediaPipeAudioTask.RUNNING_MODE_AUDIO_CLIPS
var delegate := MediaPipeTaskBaseOptions.DELEGATE_CPU
var audio_capture: AudioEffectCapture
var record_start: int = 0

@onready var external_files_disabled: Label = $VBoxContainer/ExternalFileDisabled
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var btn_back: Button = $VBoxContainer/Title/Back
@onready var btn_load_audio: Button = $VBoxContainer/Buttons/LoadAudio
@onready var btn_record: Button = $VBoxContainer/Buttons/Record
@onready var audio_file_dialog: FileDialog = $AudioFileDialog
@onready var output_label: RichTextLabel = $VBoxContainer/RichTextLabel
@onready var audio_record: AudioStreamPlayer = $AudioStreamPlayer

func _exit_tree() -> void:
	if request:
		request.cancel_request()
		request = null

func _ready() -> void:
	btn_back.pressed.connect(self._back)
	btn_load_audio.pressed.connect(self._open_audio)
	btn_record.pressed.connect(self._toggle_record)
	audio_file_dialog.file_selected.connect(self._load_audio)
	var record_bus_idx := AudioServer.get_bus_index("Record")
	audio_capture = AudioServer.get_bus_effect(record_bus_idx, 0)
	_init_task()

func _process(_delta: float) -> void:
	if request:
		var max_size := request.get_body_size()
		var cur_size := request.get_downloaded_bytes()
		progress_bar.value = round(float(cur_size) / float(max_size) * 100)
	if audio_record.playing:
		if audio_capture == null:
			return
		var buffer := audio_capture.get_buffer(audio_capture.get_frames_available())
		if buffer.is_empty():
			return
		if not running_mode == MediaPipeAudioTask.RUNNING_MODE_AUDIO_STREAM:
			running_mode = MediaPipeAudioTask.RUNNING_MODE_AUDIO_STREAM
			_init_task()
		_process_audio_stream(buffer, true, AudioServer.get_input_mix_rate(), Time.get_ticks_msec() - record_start)

func _reset() -> void:
	audio_record.playing = false
	btn_record.text = "Start Recording"

func _back() -> void:
	_reset()
	Global.go_to_main_scene()

func _get_external_file() -> void:
	progress_bar.hide()
	output_label.show()
	request = null
	_init_task()

func _init_task() -> void:
	btn_load_audio.disabled = false
	btn_record.disabled = false

func _open_audio() -> void:
	_reset()
	audio_file_dialog.popup_centered_ratio()

func _load_audio(path: String) -> void:
	if not running_mode == MediaPipeAudioTask.RUNNING_MODE_AUDIO_CLIPS:
		running_mode = MediaPipeAudioTask.RUNNING_MODE_AUDIO_CLIPS
		_init_task()
	var stereo := true
	var audio: AudioStream
	var ext := path.get_extension()
	if ext == "wav":
		var wav := AudioStreamWAV.load_from_file(path)
		stereo = wav.stereo
		audio = wav
	elif ext == "mp3":
		audio = AudioStreamMP3.load_from_file(path)
	if audio == null:
		return
	var playback := audio.instantiate_playback()
	playback.start()
	var data := playback.mix_audio(1.0, int(AudioServer.get_mix_rate() * audio.get_length()))
	playback.stop()
	_process_audio_clip(data, stereo, AudioServer.get_mix_rate())

func _process_audio_clip(_data: PackedVector2Array, _is_stereo: bool, _sample_rate: float) -> void:
	pass

func _toggle_record() -> void:
	if not audio_record.playing:
		output_label.clear()
		record_start = Time.get_ticks_msec()
		running_mode = MediaPipeAudioTask.RUNNING_MODE_AUDIO_STREAM
		_init_task()
		audio_record.playing = true
		btn_record.text = "Stop Recording"
	else:
		_reset()

func _process_audio_stream(_data: PackedVector2Array, _is_stereo: bool, _sample_rate: float, _timestamp_ms: int) -> void:
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
