extends TextTask

var task: MediaPipeTextClassifier
var task_file := "text_classifier/bert_classifier/float32/latest/bert_classifier.tflite"

func _init_task() -> void:
	var file := get_external_model(task_file)
	if file == null:
		return
	var base_options := MediaPipeTaskBaseOptions.new()
	base_options.delegate = delegate
	base_options.model_asset_buffer = file.get_buffer(file.get_length())
	var classifier_options := MediaPipeClassifierOptions.new()
	classifier_options.score_threshold = 0.5
	task = MediaPipeTextClassifier.new()
	task.initialize(base_options, classifier_options)
	super()

func _process_text(text: String) -> void:
	var result = task.classify(text)
	output_label.clear()
	output_label.add_text("input text: %s\n" % [text])
	for e in result.classifications:
		output_label.add_text("%s:\n" % [e.head_name])
		for c in e.categories:
			output_label.add_text("\t%s: %f%%\n" % [c.category_name, c.score * 100])
