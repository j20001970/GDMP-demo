extends VisionTask

var task: MediaPipeGestureRecognizer
var task_file := "gesture_recognizer/gesture_recognizer/float16/latest/gesture_recognizer.task"
var renderer: MediaPipeHandRenderer

@onready var lbl_gesture: Label = $VBoxContainer/Image/Gesture

func _result_callback(result: MediaPipeGestureRecognizerResult, image: MediaPipeImage, _timestamp_ms: int) -> void:
	show_result(image, result)

func _init_task() -> void:
	var file := get_external_model(task_file)
	if file == null:
		return
	var base_options := MediaPipeTaskBaseOptions.new()
	base_options.delegate = delegate
	base_options.model_asset_buffer = file.get_buffer(file.get_length())
	task = MediaPipeGestureRecognizer.new()
	task.initialize(base_options, running_mode)
	task.result_callback.connect(self._result_callback)
	renderer = MediaPipeHandRenderer.new()
	super()

func _process_image(image: Image) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.recognize(input_image)
	show_result(input_image, result)

func _process_video(image: Image, timestamp_ms: int) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.recognize_video(input_image, timestamp_ms)
	show_result(input_image, result)

func _process_camera(image: MediaPipeImage, timestamp_ms: int) -> void:
	task.recognize_async(image, timestamp_ms)

func show_result(image: MediaPipeImage, result: MediaPipeGestureRecognizerResult) -> void:
	var gesture_text := ""
	assert(result.gestures.size() == result.handedness.size())
	for i in range(result.gestures.size()):
		var gesture := result.gestures[i]
		var hand := result.handedness[i]
		var classification_gesture := gesture.categories[0]
		var classification_hand := hand.categories[0]
		var gesture_label: String = classification_gesture.category_name
		var gesture_score: float = classification_gesture.score
		var hand_label: String = classification_hand.category_name
		var hand_score: float = classification_hand.score
		gesture_text += "%s: %.2f\n%s: %.2f\n\n" % [hand_label, hand_score, gesture_label, gesture_score]
	lbl_gesture.call_deferred("set_text", gesture_text)
	var output_image := renderer.render(image, result.hand_landmarks)
	update_image(output_image.image)
