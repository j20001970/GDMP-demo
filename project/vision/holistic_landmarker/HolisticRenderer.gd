class_name MediaPipeHolisticRenderer
extends MediaPipeTaskRunner

func _init() -> void:
	var builder := MediaPipeGraphBuilder.new()
	var render_face := MediaPipeFaceRenderer.face_landmarks_to_render_data(builder)
	var render_pose := MediaPipePoseRenderer.pose_landmarks_to_render_data(builder)
	var render_hand_left := MediaPipeHandRenderer.hand_landmarks_to_render_data(builder)
	var render_hand_right := MediaPipeHandRenderer.hand_landmarks_to_render_data(builder)
	var annotation := builder.add_node("AnnotationOverlayCalculator")
	builder.get_input_tag("IMAGE").connect_to(annotation.get_input_tag("IMAGE"), "input_image")
	builder.get_input_tag("FACE_LANDMARKS").connect_to(render_face.get_input_tag("NORM_LANDMARKS"), "face_landmarks")
	builder.get_input_tag("POSE_LANDMARKS").connect_to(render_pose.get_input_tag("NORM_LANDMARKS"), "pose_landmarks")
	builder.get_input_tag("LEFT_HAND_LANDMARKS").connect_to(render_hand_left.get_input_tag("NORM_LANDMARKS"), "left_hand_landmarks")
	builder.get_input_tag("RIGHT_HAND_LANDMARKS").connect_to(render_hand_right.get_input_tag("NORM_LANDMARKS"), "right_hand_landmarks")
	render_face.get_output_tag("RENDER_DATA").connect_to(annotation.get_input_index(0), "face_landmarks_render_data")
	render_pose.get_output_tag("RENDER_DATA").connect_to(annotation.get_input_index(1), "pose_landmarks_render_data")
	render_hand_left.get_output_tag("RENDER_DATA").connect_to(annotation.get_input_index(2), "left_hand_landmarks_render_data")
	render_hand_right.get_output_tag("RENDER_DATA").connect_to(annotation.get_input_index(3), "right_hand_landmarks_render_data")
	annotation.get_output_tag("IMAGE").connect_to(builder.get_output_index(0), "output_image")
	var config := builder.get_config()
	initialize(config)

func render(packets: Dictionary) -> MediaPipeImage:
	var outputs := process(packets)
	if outputs.has("output_image"):
		var packet := outputs.get("output_image") as MediaPipePacket
		var output_image := packet.get() as MediaPipeImage
		return output_image
	return null
