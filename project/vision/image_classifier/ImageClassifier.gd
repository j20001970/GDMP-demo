extends VisionTask

var task: MediaPipeImageClassifier
var task_file := "image_classifier/efficientnet_lite0/float32/latest/efficientnet_lite0.tflite"

@onready var lbl_classifications: Label = $VBoxContainer/Image/Classifications

func _result_callback(result: MediaPipeClassificationResult, image: MediaPipeImage, _timestamp_ms: int) -> void:
	var img := image.get_image()
	show_result(img, result)

func _init_task() -> void:
	var file := get_external_model(task_file)
	if file == null:
		return
	var base_options := MediaPipeTaskBaseOptions.new()
	base_options.delegate = delegate
	base_options.model_asset_buffer = file.get_buffer(file.get_length())
	var classifier_options := MediaPipeClassifierOptions.new()
	task = MediaPipeImageClassifier.new()
	task.initialize(base_options, running_mode, classifier_options)
	task.result_callback.connect(self._result_callback)
	super()

func _process_image(image: Image) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.classify(input_image)
	show_result(image, result)

func _process_video(image: Image, timestamp_ms: int) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.classify_video(input_image, timestamp_ms)
	show_result(image, result)

func _process_camera(image: MediaPipeImage, timestamp_ms: int) -> void:
	task.classify_async(image, timestamp_ms)

func show_result(image: Image, result: MediaPipeClassificationResult) -> void:
	var classifications_text := ""
	var classifications := result.classifications
	for classification in classifications:
		var categories = classification.categories
		for category in categories:
			if category.score >= 0.5:
				classifications_text += "%s: %.2f\n" % [category.category_name, category.score]
	lbl_classifications.call_deferred("set_text", classifications_text)
	update_image(image)
