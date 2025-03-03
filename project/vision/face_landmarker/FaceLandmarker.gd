extends VisionTask

var task: MediaPipeFaceLandmarker
var task_file := "face_landmarker/face_landmarker/float16/latest/face_landmarker.task"
var renderer: MediaPipeFaceRenderer

@onready var lbl_blendshapes: Label = $VBoxContainer/Image/Blendshapes

func _result_callback(result: MediaPipeFaceLandmarkerResult, image: MediaPipeImage, _timestamp_ms: int) -> void:
	show_result(image, result)

func _init_task() -> void:
	var file := get_external_model(task_file)
	if file == null:
		return
	var base_options := MediaPipeTaskBaseOptions.new()
	base_options.delegate = delegate
	base_options.model_asset_buffer = file.get_buffer(file.get_length())
	task = MediaPipeFaceLandmarker.new()
	task.initialize(base_options, running_mode, 1, 0.5, 0.5, 0.5, true)
	task.result_callback.connect(self._result_callback)
	renderer = MediaPipeFaceRenderer.new()
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

func show_result(image: MediaPipeImage, result: MediaPipeFaceLandmarkerResult) -> void:
	var output_image := renderer.render(image, result.face_landmarks)
	update_image(output_image.image)
	if result.has_face_blendshapes():
		for blendshape in result.face_blendshapes:
			call_deferred("show_blendshapes", blendshape)

func show_blendshapes(blendshapes: MediaPipeClassifications) -> void:
	lbl_blendshapes.text = ""
	for category in blendshapes.categories:
		if category.score >= 0.5:
			if category.has_category_name():
				lbl_blendshapes.text += "%s: %.2f\n" % [category.category_name, category.score]
