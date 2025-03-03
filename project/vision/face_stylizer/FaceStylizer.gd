extends VisionTask

var task: MediaPipeFaceStylizer
var task_file := "face_stylizer/blaze_face_stylizer/float32/latest/face_stylizer_color_ink.task"

func _init_task() -> void:
	var file := get_external_model(task_file)
	if file == null:
		return
	var base_options := MediaPipeTaskBaseOptions.new()
	base_options.delegate = delegate
	base_options.model_asset_buffer = file.get_buffer(file.get_length())
	task = MediaPipeFaceStylizer.new()
	task.initialize(base_options)
	btn_load_image.disabled = false

func _process_image(image: Image) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.stylize(input_image)
	show_result(result)

func show_result(image: MediaPipeImage) -> void:
	if image == null:
		return
	update_image(image.get_image())
