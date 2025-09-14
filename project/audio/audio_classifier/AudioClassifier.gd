extends AudioTask

var task: MediaPipeAudioClassifier
var task_file := "audio_classifier/yamnet/float32/latest/yamnet.tflite"

func _result_callback(result: MediaPipeClassificationResult) -> void:
	show_result(result)

func _init_task() -> void:
	var file := get_external_model(task_file)
	if file == null:
		return
	var base_options := MediaPipeTaskBaseOptions.new()
	base_options.delegate = delegate
	base_options.model_asset_buffer = file.get_buffer(file.get_length())
	var classifier_options := MediaPipeClassifierOptions.new()
	classifier_options.score_threshold = 0.5
	task = MediaPipeAudioClassifier.new()
	task.initialize(base_options, running_mode, classifier_options)
	task.result_callback.connect(self._result_callback, ConnectFlags.CONNECT_DEFERRED)
	super()

func _process_audio_clip(data: PackedVector2Array, is_stereo: bool, sample_rate: float) -> void:
	var results := task.classify(data, is_stereo, sample_rate)
	output_label.clear()
	for result in results:
		show_result(result)

func _process_audio_stream(data: PackedVector2Array, is_stereo: bool, sample_rate: float, timestamp_ms: int) -> void:
	task.classify_async(data, is_stereo, sample_rate, timestamp_ms)

func show_result(result: MediaPipeClassificationResult) -> void:
	var text := "Audio position: %f\n" % [result.timestamp_ms / 1000.0]
	for classification in result.classifications:
		for category in classification.categories:
			text += "\t%s: %f\n" % [category.category_name, category.score]
	output_label.add_text(text)
