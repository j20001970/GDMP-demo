extends VisionTask

var package_name := "mediapipe.tasks.vision.holistic_landmarker"
var task_file := "holistic_landmarker/holistic_landmarker/float16/latest/holistic_landmarker.task"
var task_runner := MediaPipeTaskRunner.new()
var renderer: MediaPipeHolisticRenderer

@onready var lbl_blendshapes: Label = $VBoxContainer/Image/Blendshapes

func _packets_callback(outputs: Dictionary) -> void:
	show_result(outputs)

func _init_task() -> void:
	var file := get_external_model(task_file)
	if file == null:
		return
	var options := MediaPipeProto.new()
	options.initialize(package_name+".proto.HolisticLandmarkerGraphOptions")
	options.set_field("base_options/model_asset/file_content", file.get_buffer(file.get_length()))
	var builder := MediaPipeGraphBuilder.new()
	var node := builder.add_node(package_name+".HolisticLandmarkerGraph")
	node.set_options(options)
	builder.get_input_tag("IMAGE").connect_to(node.get_input_tag("IMAGE"), "image_in")
	node.get_output_tag("POSE_LANDMARKS").connect_to(builder.get_output_tag("POSE_LANDMARKS"), "pose_landmarks")
	node.get_output_tag("LEFT_HAND_LANDMARKS").connect_to(builder.get_output_tag("LEFT_HAND_LANDMARKS"), "left_hand_landmarks")
	node.get_output_tag("RIGHT_HAND_LANDMARKS").connect_to(builder.get_output_tag("RIGHT_HAND_LANDMARKS"), "right_hand_landmarks")
	node.get_output_tag("FACE_LANDMARKS").connect_to(builder.get_output_tag("FACE_LANDMARKS"), "face_landmarks")
	node.get_output_tag("FACE_BLENDSHAPES").connect_to(builder.get_output_tag("FACE_BLENDSHAPES"), "face_blendshapes")
	node.get_output_tag("IMAGE").connect_to(builder.get_output_tag("IMAGE"), "image_out")
	var config := builder.get_config()
	var callback: Callable
	if running_mode == MediaPipeVisionTask.RUNNING_MODE_LIVE_STREAM:
		callback = self._packets_callback
	task_runner.initialize(config, callback)
	renderer = MediaPipeHolisticRenderer.new()
	super()

func _process_image(image: Image) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var packet := input_image.get_packet()
	var outputs := task_runner.process({"image_in": packet})
	show_result(outputs)

func _process_video(image: Image, timestamp_ms: int) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var packet := input_image.get_packet()
	packet.timestamp = timestamp_ms * 1000
	var outputs := task_runner.process({"image_in": packet})
	show_result(outputs)

func _process_camera(image: MediaPipeImage, timestamp_ms: int) -> void:
	var packet := image.get_packet()
	packet.timestamp = timestamp_ms * 1000
	task_runner.send({"image_in": packet})

func show_result(outputs: Dictionary) -> void:
	var packets := {}
	if outputs.has("image_out"):
		var packet: MediaPipePacket = outputs["image_out"]
		var image = packet.get() as MediaPipeImage
		packets["input_image"] = image.get_image_frame_packet()
		packets["input_image"].timestamp = packet.timestamp
	if outputs.has("face_landmarks"):
		packets["face_landmarks"] = outputs["face_landmarks"]
	if outputs.has("pose_landmarks"):
		packets["pose_landmarks"] = outputs["pose_landmarks"]
	if outputs.has("left_hand_landmarks"):
		packets["left_hand_landmarks"] = outputs["left_hand_landmarks"]
	if outputs.has("right_hand_landmarks"):
		packets["right_hand_landmarks"] = outputs["right_hand_landmarks"]
	var output_image := renderer.render(packets)
	if output_image == null:
		return
	update_image(output_image.image)

func show_blendshapes(classifications: Array) -> void:
	lbl_blendshapes.text = ""
	for classification in classifications:
		var score = classification.get_field("score")
		var label = classification.get_field("label")
		if score >= 0.5:
			lbl_blendshapes.text += "%s: %.2f\n" % [label, score]
