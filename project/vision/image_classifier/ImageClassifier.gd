extends VisionTask

var task: MediaPipe.ImageClassifier
var task_file := "res://vision/image_classifier/mobilenet_v2_1.0_224.tflite"

onready var lbl_classifications: Label = $VBoxContainer/Image/Classifications

func _result_callback(result, image, timestamp_ms) -> void:
	var img: Image = image.get_image()
	show_result(img, result)

func init_task() -> void:
	var base_options := MediaPipe.TaskBaseOptions.new()
	base_options.set_model_asset_path(task_file)
	task = MediaPipe.ImageClassifier.new()
	task.initialize(base_options, running_mode, "en", -1, 0.0, [], [])
	task.connect("result_callback", self, "_result_callback")

func process_image_frame(image: Image) -> void:
	var input_image := MediaPipe.Image.new()
	input_image.set_image(image)
	var result = task.classify(input_image, Rect2(), 0)
	show_result(image, result)

func process_video_frame(image: Image, timestamp_ms: int) -> void:
	var input_image := MediaPipe.Image.new()
	input_image.set_image(image)
	var result = task.classify_video(input_image, timestamp_ms, Rect2(), 0)
	show_result(image, result)

func process_camera_frame(image, timestamp_ms: int) -> void:
	task.classify_async(image, timestamp_ms, Rect2(), 0)

func show_result(image: Image, result) -> void:
	lbl_classifications.text = ""
	var classifications = result.get_classifications()
	for classification in classifications:
		var categories = classification.get_categories()
		for category in categories:
			if category.get_score() >= 0.5:
				lbl_classifications.text += "%s: %.2f\n" % [category.get_category_name(), category.get_score()]
	update_image(image)
