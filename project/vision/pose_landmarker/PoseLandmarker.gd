extends VisionTask

var task: MediaPipePoseLandmarker
var task_file := "pose_landmarker.task"
var task_file_generation := 1681244249587900

func _result_callback(result: MediaPipePoseLandmarkerResult, image: MediaPipeImage, timestamp_ms: int) -> void:
	var img := image.get_image()
	show_result(img, result)

func _init_task():
	var file := get_model_asset(task_file, task_file_generation)
	if file == null:
		return
	var base_options := MediaPipeTaskBaseOptions.new()
	base_options.delegate = delegate
	base_options.model_asset_buffer = file.get_buffer(file.get_length())
	task = MediaPipePoseLandmarker.new()
	task.initialize(base_options, running_mode)
	task.result_callback.connect(self._result_callback)
	super()

func _process_image(image: Image) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.detect(input_image)
	show_result(image, result)

func _process_video(image: Image, timestamp_ms: int) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.detect_video(input_image, timestamp_ms)
	show_result(image, result)

func _process_camera(image: MediaPipeImage, timestamp_ms: int) -> void:
	task.detect_async(image, timestamp_ms)

func show_result(image: Image, result: MediaPipePoseLandmarkerResult) -> void:
	for landmarks in result.pose_landmarks:
		draw_landmarks(image, landmarks)
	update_image(image)

func draw_landmarks(image: Image, landmarks: MediaPipeNormalizedLandmarks) -> void:
	var color := Color.GREEN
	var rect := Image.create(4, 4, false, image.get_format())
	rect.fill(color)
	var image_size := Vector2(image.get_size())
	for landmark in landmarks.landmarks:
		var pos := Vector2(landmark.x, landmark.y)
		image.blit_rect(rect, rect.get_used_rect(), Vector2i(image_size * pos) - rect.get_size() / 2)
