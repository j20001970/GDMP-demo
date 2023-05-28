extends VisionTask

var package_name := "mediapipe.tasks.vision.holistic_landmarker"
var graph := MediaPipeGraph.new()
var task_file := "res://vision/holistic_landmarker/holistic_landmarker.task"
var image: Image

@onready var lbl_blendshapes: Label = $VBoxContainer/Image/Blendshapes

func _result_callback(stream_name: String, packet: MediaPipePacket) -> void:
	print(stream_name)
	if stream_name == "image_in":
		var image_frame = MediaPipeImage.create_from_packet(packet)
		image = image_frame.get_image()
	elif stream_name in ["pose_landmarks", "face_landmarks", "left_hand_landmarks", "right_hand_landmarks"]:
		var proto := packet.get_proto("")
		var landmarks = proto.get("landmark")
		draw_landmarks(landmarks)
	elif stream_name == "face_blendshapes":
		var proto = packet.get_proto("")
		var classifications = proto.get("classification")
		show_blendshapes(classifications)

func init_task() -> void:
	var builder := MediaPipeGraphBuilder.new()
	var node := builder.add_node(package_name+".HolisticLandmarkerGraph")
	var options := MediaPipeProto.new()
	options.initialize(package_name+".proto.HolisticLandmarkerGraphOptions")
	var file := FileAccess.open(task_file, FileAccess.READ)
	var file_content := file.get_buffer(file.get_length())
	options.set("base_options/model_asset/file_content", file_content)
	node.set_options(options)
	builder.connect_input_to("image_in", node, "IMAGE")
	builder.connect_to_output(node, "POSE_LANDMARKS", "pose_landmarks")
	builder.connect_to_output(node, "LEFT_HAND_LANDMARKS", "left_hand_landmarks")
	builder.connect_to_output(node, "RIGHT_HAND_LANDMARKS", "right_hand_landmarks")
	builder.connect_to_output(node, "FACE_LANDMARKS", "face_landmarks")
	builder.connect_to_output(node, "FACE_BLENDSHAPES", "face_blendshapes")
	var config := builder.get_config()
	graph.initialize(config)
	graph.add_packet_callback("image_in", self._result_callback)
	graph.add_packet_callback("pose_landmarks", self._result_callback)
	graph.add_packet_callback("left_hand_landmarks", self._result_callback)
	graph.add_packet_callback("right_hand_landmarks", self._result_callback)
	graph.add_packet_callback("face_landmarks", self._result_callback)
	graph.add_packet_callback("face_blendshapes", self._result_callback)
	graph.start()

func process_image_frame(image: Image) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var packet := input_image.get_packet()
	packet.set_timestamp(Time.get_ticks_msec())
	graph.add_packet("image_in", packet)

func process_video_frame(image: Image, timestamp_ms: int) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var packet := input_image.get_packet()
	packet.set_timestamp(Time.get_ticks_msec())
	graph.add_packet("image_in", packet)

func process_camera_frame(image: MediaPipeImage, timestamp_ms: int) -> void:
	var packet := image.get_packet()
	packet.set_timestamp(Time.get_ticks_msec())
	graph.add_packet("image_in", packet)

func draw_landmarks(landmarks: Array) -> void:
	if image == null:
		return
	var color := Color.GREEN
	var rect := Image.create(4, 4, false, image.get_format())
	rect.fill(color)
	var image_size := Vector2(image.get_size())
	for landmark in landmarks:
		var pos := Vector2(landmark.get("x"), landmark.get("y"))
		image.blit_rect(rect, rect.get_used_rect(), Vector2i(image_size * pos) - rect.get_size() / 2)
	update_image(image)

func show_blendshapes(classifications: Array) -> void:
	lbl_blendshapes.text = ""
	for classification in classifications:
		var score = classification.get("score")
		var label = classification.get("label")
		if score >= 0.5:
			lbl_blendshapes.call_deferred("set_text", lbl_blendshapes.text + "%s: %.2f\n" % [label, score])
