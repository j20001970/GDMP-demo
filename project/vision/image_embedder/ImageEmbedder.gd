extends VisionTask

var task: MediaPipeImageEmbedder
var task_file := "image_embedder/mobilenet_v3_small/float32/latest/mobilenet_v3_small.tflite"

func _result_callback(result: MediaPipeEmbeddingResult, image: MediaPipeImage, _timestamp_ms: int) -> void:
	var img := image.get_image()
	show_result(img, result)

func _init_task() -> void:
	var file := get_external_model(task_file)
	if file == null:
		return
	var base_options := MediaPipeTaskBaseOptions.new()
	base_options.delegate = delegate
	base_options.model_asset_buffer = file.get_buffer(file.get_length())
	var embedder_options := MediaPipeEmbedderOptions.new()
	task = MediaPipeImageEmbedder.new()
	task.initialize(base_options, running_mode, embedder_options)
	task.result_callback.connect(self._result_callback)
	super()

func _process_image(image: Image) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.embed(input_image)
	show_result(image, result)

func _process_video(image: Image, timestamp_ms: int) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.embed_video(input_image, timestamp_ms)
	show_result(image, result)

func _process_camera(image: MediaPipeImage, timestamp_ms: int) -> void:
	task.embed_async(image, timestamp_ms)

func show_result(image: Image, result: MediaPipeEmbeddingResult) -> void:
	var embeddings := result.embeddings
	for embedding in embeddings:
		print("index: %d" % embedding.head_index)
		print("embedding size: %d\n" % embedding.float_embedding.size())
	update_image(image)
