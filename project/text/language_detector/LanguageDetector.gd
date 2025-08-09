extends TextTask

var task: MediaPipeLanguageDetector
var task_file := "language_detector/language_detector/float32/1/language_detector.tflite"

func _init_task() -> void:
	var file := get_external_model(task_file)
	if file == null:
		return
	var base_options := MediaPipeTaskBaseOptions.new()
	base_options.delegate = delegate
	base_options.model_asset_buffer = file.get_buffer(file.get_length())
	var classifier_options := MediaPipeClassifierOptions.new()
	classifier_options.score_threshold = 0.5
	task = MediaPipeLanguageDetector.new()
	task.initialize(base_options, classifier_options)
	super()

func _process_text(text: String) -> void:
	var result = task.detect(text)
	output_label.clear()
	output_label.add_text("input text: %s\n" % [text])
	for e in result:
		output_label.add_text("\t%s: %f%%\n" % [e.language_code, e.probability * 100])
