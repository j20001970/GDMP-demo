extends VisionTask

var task: MediaPipe.PoseLandmarker
var task_file := "res://vision/pose_landmarker/pose_landmarker.task"

func _result_callback(result, image, timestamp_ms: int) -> void:
	var img: Image = image.get_image()
	show_result(img, result)

func init_task():
	var base_options := MediaPipe.TaskBaseOptions.new()
	var file := File.new()
	file.open(task_file, File.READ)
	base_options.set_model_asset_buffer(file.get_buffer(file.get_len()))
	task = MediaPipe.PoseLandmarker.new()
	task.initialize(base_options, running_mode, 1, 0.5, 0.5, 0.5, false)
	task.connect("result_callback", self, "_result_callback")

func process_image_frame(image: Image) -> void:
	var input_image := MediaPipe.Image.new()
	input_image.set_image(image)
	var result = task.detect(input_image, Rect2(), 0)
	show_result(image, result)

func process_video_frame(image: Image, timestamp_ms: int) -> void:
	var input_image := MediaPipe.Image.new()
	input_image.set_image(image)
	var result = task.detect_video(input_image, timestamp_ms, Rect2(), 0)
	show_result(image, result)

func process_camera_frame(image, timestamp_ms: int) -> void:
	task.detect_async(image, timestamp_ms, Rect2(), 0)

func show_result(image: Image, result) -> void:
	for landmarks in result.get_pose_landmarks():
		draw_landmarks(image, landmarks)
	update_image(image)

func draw_landmarks(image: Image, landmarks) -> void:
	var color := Color.green
	var rect := Image.new()
	rect.create(4, 4, false, image.get_format())
	rect.fill(color)
	var image_size := Vector2(image.get_size())
	for landmark in landmarks.get_landmarks():
		var pos := Vector2(landmark.get_x(), landmark.get_y())
		image.blit_rect(rect, rect.get_used_rect(), Vector2(image_size * pos) - rect.get_size() / 2)