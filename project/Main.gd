extends Control

var tasks_audio := {
	"Audio Classifier": "res://audio/audio_classifier/AudioClassifier.tscn",
}
var tasks_text := {
	"Text Classifier": "res://text/text_classifier/TextClassifier.tscn",
	"Language Detector": "res://text/language_detector/LanguageDetector.tscn",
}
var tasks_vision := {
	"Face Detector": "res://vision/face_detector/FaceDetector.tscn",
	"Face Landmarker": "res://vision/face_landmarker/FaceLandmarker.tscn",
	"Face Stylizer": "res://vision/face_stylizer/FaceStylizer.tscn",
	"Gesture Recognizer": "res://vision/gesture_recognizer/GestureRecognizer.tscn",
	"Hand Landmarker": "res://vision/hand_landmarker/HandLandmarker.tscn",
	"Holistic Landmarker": "res://vision/holistic_landmarker/HolisticLandmarker.tscn",
	"Image Classifier": "res://vision/image_classifier/ImageClassifier.tscn",
	"Image Embedder": "res://vision/image_embedder/ImageEmbedder.tscn",
	"Image Segmenter": "res://vision/image_segmenter/ImageSegmenter.tscn",
	"Object Detector": "res://vision/object_detector/ObjectDetector.tscn",
	"Pose Landmarker": "res://vision/pose_landmarker/PoseLandmarker.tscn",
}

@onready var btn_back: Button = $VBoxContainer/Title/Back
@onready var main: Control = $VBoxContainer/Main
@onready var btn_task_audio: Button = main.get_node("Tasks/Audio")
@onready var btn_task_text: Button = main.get_node("Tasks/Text")
@onready var btn_task_vision: Button = main.get_node("Tasks/Vision")
@onready var tgl_external_files: CheckButton = main.get_node("EnableExternalFiles")
@onready var select_task: Control = $VBoxContainer/SelectTask
@onready var lbl_task_type: Label = select_task.get_node("TaskType")
@onready var lst_tasks: BoxContainer = select_task.get_node("ScrollContainer/Tasks")
@onready var popup_external_files: ConfirmationDialog = $ExternalFilesPopup

func _ready() -> void:
	btn_back.pressed.connect(self._back)
	btn_task_audio.pressed.connect(self._select_task.bind("Audio Tasks", tasks_audio))
	btn_task_text.pressed.connect(self._select_task.bind("Text Tasks", tasks_text))
	btn_task_vision.pressed.connect(self._select_task.bind("Vision Tasks", tasks_vision))
	tgl_external_files.toggled.connect(_external_file_toggled)
	popup_external_files.confirmed.connect(_enable_external_file)
	if Global.enable_download_files:
		tgl_external_files.button_pressed = true

func _back() -> void:
	btn_back.hide()
	select_task.hide()
	main.show()

func _select_task(task_type: String, tasks: Dictionary) -> void:
	lbl_task_type.text = task_type
	for task in lst_tasks.get_children():
		task.queue_free()
	if tasks.is_empty():
		var label := Label.new()
		label.text = "Coming Soon™"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lst_tasks.add_child(label)
	else:
		for task in tasks:
			var button := Button.new()
			button.text = task
			button.mouse_filter = Control.MOUSE_FILTER_PASS
			button.pressed.connect(get_tree().change_scene_to_file.bind(tasks[task]))
			lst_tasks.add_child(button)
	main.hide()
	select_task.show()
	btn_back.show()

func _external_file_toggled(toggled: bool) -> void:
	if toggled:
		if not Global.enable_download_files:
			popup_external_files.popup_centered_ratio()
			popup_external_files.content_scale_factor = 2.5
			tgl_external_files.button_pressed = false
	else:
		Global.enable_download_files = false

func _enable_external_file() -> void:
	Global.enable_download_files = true
	tgl_external_files.button_pressed = true
