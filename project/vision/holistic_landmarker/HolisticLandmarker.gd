extends VisionTask

var package_name := "mediapipe.tasks.vision.holistic_landmarker"
var task_file := "holistic_landmarker.task"
var task_file_generation := 1699635090585884
var task_runner := MediaPipeTaskRunner.new()
var image: Image

@onready var lbl_blendshapes: Label = $VBoxContainer/Image/Blendshapes

func _packets_callback(outputs: Dictionary) -> void:
	show_result(outputs)

func _init_task() -> void:
	var file := get_model_asset(task_file, task_file_generation)
	if file == null:
		return
	var options := MediaPipeProto.new()
	options.initialize(package_name+".proto.HolisticLandmarkerGraphOptions")
	options.set("base_options/model_asset/file_content", file.get_buffer(file.get_length()))
	var builder := MediaPipeGraphBuilder.new()
	var node := builder.add_node(package_name+".HolisticLandmarkerGraph")
	node.set_options(options)
	builder.connect_input_to("image_in", node, "IMAGE")
	builder.connect_to_output(node, "POSE_LANDMARKS", "pose_landmarks")
	builder.connect_to_output(node, "LEFT_HAND_LANDMARKS", "left_hand_landmarks")
	builder.connect_to_output(node, "RIGHT_HAND_LANDMARKS", "right_hand_landmarks")
	builder.connect_to_output(node, "FACE_LANDMARKS", "face_landmarks")
	builder.connect_to_output(node, "FACE_BLENDSHAPES", "face_blendshapes")
	var config := builder.get_config()
	var callback: Callable
	if running_mode == MediaPipeTask.RUNNING_MODE_LIVE_STREAM:
		callback = self._packets_callback
	task_runner.initialize(config, callback)
	super()

func _process_image(image: Image) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var packet := input_image.get_packet()
	var outputs := task_runner.process({"image_in": packet})
	self.image = image
	show_result(outputs)

func _process_video(image: Image, timestamp_ms: int) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var packet := input_image.get_packet()
	packet.timestamp = timestamp_ms
	var outputs := task_runner.process({"image_in": packet})
	self.image = image
	show_result(outputs)

func _process_camera(image: MediaPipeImage, timestamp_ms: int) -> void:
	var packet := image.get_packet()
	packet.timestamp = timestamp_ms
	task_runner.send({"image_in": packet})
	self.image = image.get_image()

func show_result(outputs: Dictionary) -> void:
	if outputs.has("pose_landmarks"):
		var packet: MediaPipePacket = outputs["pose_landmarks"]
		if not packet.is_empty():
			var pose_landmarks: MediaPipeProto = packet.get()
			var landmarks: Array = pose_landmarks.get("landmark")
			draw_landmarks(landmarks, Color.GREEN)
	if outputs.has("face_landmarks"):
		var packet: MediaPipePacket = outputs["face_landmarks"]
		if not packet.is_empty():
			var face_landmarks: MediaPipeProto = packet.get()
			var landmarks: Array = face_landmarks.get("landmark")
			draw_landmarks(landmarks, Color.BLUE)
	if outputs.has("left_hand_landmarks"):
		var packet: MediaPipePacket = outputs["left_hand_landmarks"]
		if not packet.is_empty():
			var left_hand_landmarks: MediaPipeProto = packet.get()
			var landmarks: Array = left_hand_landmarks.get("landmark")
			draw_landmarks(landmarks, Color.RED)
	if outputs.has("right_hand_landmarks"):
		var packet: MediaPipePacket = outputs["right_hand_landmarks"]
		if not packet.is_empty():
			var right_hand_landmarks: MediaPipeProto = packet.get()
			var landmarks: Array = right_hand_landmarks.get("landmark")
			draw_landmarks(landmarks, Color.YELLOW)
	if outputs.has("face_blendshapes"):
		var packet: MediaPipePacket = outputs["face_blendshapes"]
		if not packet.is_empty():
			var face_blendshapes: MediaPipeProto = packet.get()
			var classification: Array = face_blendshapes.get("classification")
			show_blendshapes(classification)
	update_image(image)

func draw_landmarks(landmarks: Array, color: Color) -> void:
	if image == null:
		return
	var rect := Image.create(4, 4, false, image.get_format())
	rect.fill(color)
	var image_size := Vector2(image.get_size())
	for landmark in landmarks:
		var pos := Vector2(landmark.get("x"), landmark.get("y"))
		image.blit_rect(rect, rect.get_used_rect(), Vector2i(image_size * pos) - rect.get_size() / 2)

func show_blendshapes(classifications: Array) -> void:
	lbl_blendshapes.text = ""
	for classification in classifications:
		var score = classification.get("score")
		var label = classification.get("label")
		if score >= 0.5:
			lbl_blendshapes.text += "%s: %.2f\n" % [label, score]
