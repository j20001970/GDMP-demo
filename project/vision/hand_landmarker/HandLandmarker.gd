extends VisionTask

var task: MediaPipeHandLandmarker
var task_file := "hand_landmarker/hand_landmarker/float16/latest/hand_landmarker.task"
var renderer: MediaPipeHandRenderer

@onready var lbl_handedness: Label = $VBoxContainer/Image/Handedness

func _result_callback(result: MediaPipeHandLandmarkerResult, image: MediaPipeImage, _timestamp_ms: int) -> void:
	show_result(image, result)

func _init_task() -> void:
	var file := get_external_model(task_file)
	if file == null:
		return
	var base_options := MediaPipeTaskBaseOptions.new()
	base_options.delegate = delegate
	base_options.model_asset_buffer = file.get_buffer(file.get_length())
	task = MediaPipeHandLandmarker.new()
	task.initialize(base_options, running_mode)
	task.result_callback.connect(self._result_callback)
	renderer = MediaPipeHandRenderer.new()
	super()

func _process_image(image: Image) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.detect(input_image)
	show_result(input_image, result)

func _process_video(image: Image, timestamp_ms: int) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.detect_video(input_image, timestamp_ms)
	show_result(input_image, result)

func _process_camera(image: MediaPipeImage, timestamp_ms: int) -> void:
	task.detect_async(image, timestamp_ms)

func show_result(image: MediaPipeImage, result: MediaPipeHandLandmarkerResult) -> void:
	var output_image := renderer.render(image, result.hand_landmarks)
	update_image(output_image.image)
	var handedness_text := ""
	for categories in result.handedness:
		for category in categories.categories:
			handedness_text += "%s\n" % [category.display_name]
	lbl_handedness.call_deferred("set_text", handedness_text)
