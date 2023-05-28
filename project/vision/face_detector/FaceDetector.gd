extends VisionTask

var task: MediaPipeFaceDetector
var task_file := "res://vision/face_detector/face_detection_short_range.tflite"

func _result_callback(result: MediaPipeDetectionResult, image: MediaPipeImage, timestamp_ms: int) -> void:
	var img := image.get_image()
	show_result(img, result)

func init_task() -> void:
	var base_options := MediaPipeTaskBaseOptions.new()
	base_options.delegate = delegate
	base_options.model_asset_path = task_file
	task = MediaPipeFaceDetector.new()
	task.initialize(base_options, running_mode)
	task.result_callback.connect(self._result_callback)

func process_image_frame(image: Image) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.detect(input_image)
	show_result(image, result)

func process_video_frame(image: Image, timestamp_ms: int) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.detect_video(input_image, timestamp_ms)
	show_result(image, result)

func process_camera_frame(image: MediaPipeImage, timestamp_ms: int) -> void:
	task.detect_async(image, timestamp_ms)

func show_result(image: Image, result: MediaPipeDetectionResult) -> void:
	for detection in result.detections:
		draw_detection(image, detection)
	update_image(image)

func draw_detection(image: Image, detection: MediaPipeDetection) -> void:
	var line_width := 8
	var color := Color.GREEN
	var box := detection.bounding_box
	var rect := box.grow(line_width)
	var rect_img := Image.create(rect.size.x, rect.size.y, false, image.get_format())
	rect_img.fill(color)
	var rect_mask := Image.create(rect.size.x, rect.size.y, false, Image.FORMAT_LA8)
	rect_mask.fill(Color.WHITE)
	rect_mask.fill_rect(Rect2i(Vector2i(line_width, line_width), box.size), Color.TRANSPARENT)
	image.blit_rect_mask(rect_img, rect_mask, rect_img.get_used_rect(), rect.position)
