extends VisionTask

var task: MediaPipe.ObjectDetector
var task_file := "res://vision/object_detector/efficientdet_lite0_fp16_no_nms.tflite"

func _result_callback(result, image, timestamp_ms: int) -> void:
	var img: Image = image.get_image()
	show_result(img, result)

func init_task():
	var base_options := MediaPipe.TaskBaseOptions.new()
	base_options.set_model_asset_path(task_file)
	task = MediaPipe.ObjectDetector.new()
	task.initialize(base_options, running_mode, "en", -1, 0.5, [], [])
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
	for detection in result.get_detections():
		draw_detection(image, detection)
	update_image(image)

func draw_detection(image: Image, detection) -> void:
	var line_width := 8
	var color := Color.green
	var box: Rect2 = detection.get_bounding_box()
	var rect := box.grow(line_width)
	var rect_img := Image.new()
	rect_img.create(rect.size.x, rect.size.y, false, image.get_format())
	rect_img.fill(color)
	var rect_mask := Image.new()
	rect_mask.create(rect.size.x, rect.size.y, false, Image.FORMAT_LA8)
	rect_mask.fill(Color.white)
	rect_mask.fill_rect(Rect2(Vector2(line_width, line_width), box.size), Color.transparent)
	image.blit_rect_mask(rect_img, rect_mask, rect_img.get_used_rect(), rect.position)
