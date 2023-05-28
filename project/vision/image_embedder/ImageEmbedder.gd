extends VisionTask

var task: MediaPipeImageEmbedder
var task_file := "res://vision/image_embedder/mobilenet_v3_small_100_224_embedder.tflite"

func _result_callback(result: MediaPipeEmbeddingResult, image: MediaPipeImage, timestamp_ms: int) -> void:
	var img := image.get_image()
	show_result(img, result)

func init_task() -> void:
	var base_options := MediaPipeTaskBaseOptions.new()
	base_options.delegate = delegate
	base_options.model_asset_path = task_file
	task = MediaPipeImageEmbedder.new()
	task.initialize(base_options, running_mode)
	task.result_callback.connect(self._result_callback)

func process_image_frame(image: Image) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.embed(input_image)
	show_result(image, result)

func process_video_frame(image: Image, timestamp_ms: int) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.embed_video(input_image, timestamp_ms)
	show_result(image, result)

func process_camera_frame(image: MediaPipeImage, timestamp_ms: int) -> void:
	task.embed_async(image, timestamp_ms)

func show_result(image: Image, result: MediaPipeEmbeddingResult) -> void:
	var embeddings := result.embeddings
	for embedding in embeddings:
		print("index: %d" % embedding.head_index)
		print("embedding size: %d\n" % embedding.float_embedding.size())
	update_image(image)
