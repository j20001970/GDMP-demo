extends VisionTask

var task: MediaPipeImageSegmenter
var task_file := "res://vision/image_segmenter/selfie_segmentation.tflite"
var mask: ImageTexture

func _ready():
	super._ready()
	mask = image_view.material.get_shader_parameter("mask")

func _result_callback(result: MediaPipeImageSegmenterResult, image: MediaPipeImage, timestamp_ms: int) -> void:
	var img := image.get_image()
	show_result(img, result)

func init_task() -> void:
	var base_options := MediaPipeTaskBaseOptions.new()
	base_options.delegate = delegate
	base_options.model_asset_path = task_file
	task = MediaPipeImageSegmenter.new()
	task.initialize(base_options, running_mode)
	task.result_callback.connect(self._result_callback)

func process_image_frame(image: Image) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.segment(input_image)
	show_result(image, result)

func process_video_frame(image: Image, timestamp_ms: int) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.segment_video(input_image, timestamp_ms)
	show_result(image, result)

func process_camera_frame(image: MediaPipeImage, timestamp_ms: int) -> void:
	task.segment_async(image, timestamp_ms)

func show_result(image: Image, result: MediaPipeImageSegmenterResult) -> void:
	if result.has_confidence_masks():
		# TODO: apply multiple confidence mask
		if result.confidence_masks.size():
			var mask_image := result.confidence_masks[0].get_image()
			mask.set_image(mask_image)
	update_image(image)
