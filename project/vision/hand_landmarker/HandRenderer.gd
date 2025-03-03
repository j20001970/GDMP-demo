class_name MediaPipeHandRenderer
extends MediaPipeLandmarksRenderer

static var HAND_CONNECTIONS: PackedInt32Array = [
	0, 1, 1, 2, 2, 3, 3, 4,
	0, 5, 5, 6, 6, 7, 7, 8,
	5, 9, 9, 10, 10, 11, 11, 12,
	9, 13, 13, 14, 14, 15, 15, 16,
	13, 17,
	0, 17, 17, 18, 18, 19, 19, 20,
]

static func hand_landmarks_to_render_data(builder: MediaPipeGraphBuilder) -> MediaPipeGraphNode:
	return landmarks_to_render_data(
		builder, HAND_CONNECTIONS,
		Color.RED, Color.GREEN, 4.0,
	)

func _init() -> void:
	var builder := MediaPipeGraphBuilder.new()
	var loop_begin := builder.add_node("BeginLoopNormalizedLandmarkListVectorCalculator")
	var render_data := hand_landmarks_to_render_data(builder)
	var loop_end := builder.add_node("EndLoopRenderDataCalculator")
	var annotation := builder.add_node("AnnotationOverlayCalculator")
	builder.get_input_tag("IMAGE").connect_to(annotation.get_input_tag("IMAGE"), "input_image")
	builder.get_input_tag("LANDMARKS").connect_to(loop_begin.get_input_tag("ITERABLE"), "multi_hand_landmarks")
	loop_begin.get_output_tag("ITEM").connect_to(render_data.get_input_tag("NORM_LANDMARKS"), "single_hand_landmarks")
	render_data.get_output_tag("RENDER_DATA").connect_to(loop_end.get_input_tag("ITEM"), "single_hand_landmark_render_data")
	loop_begin.get_output_tag("BATCH_END").connect_to(loop_end.get_input_tag("BATCH_END"), "landmark_timestamp")
	loop_end.get_output_tag("ITERABLE").connect_to(annotation.get_input_tag("VECTOR"), "multi_hand_landmarks_render_data")
	annotation.get_output_tag("IMAGE").connect_to(builder.get_output_index(0), "output_image")
	var config := builder.get_config()
	initialize(config)

func render(image: MediaPipeImage, multi_hand_landmarks: Array[MediaPipeNormalizedLandmarks]) -> MediaPipeImage:
	var packets := {
		"input_image": image.get_image_frame_packet(),
		"multi_hand_landmarks": MediaPipeNormalizedLandmarks.make_vector_proto_packet(multi_hand_landmarks),
	}
	var outputs := process(packets)
	if outputs.has("output_image"):
		var packet := outputs.get("output_image") as MediaPipePacket
		var output_image := packet.get() as MediaPipeImage
		return output_image
	return image
