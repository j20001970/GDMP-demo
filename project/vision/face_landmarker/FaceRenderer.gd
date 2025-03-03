class_name MediaPipeFaceRenderer
extends MediaPipeLandmarksRenderer

static var FACE_CONNECTIONS: PackedInt32Array = [
	# Lips.
	61, 146, 146, 91, 91, 181, 181, 84, 84, 17, 17, 314, 314, 405, 405, 321,
	321, 375, 375, 291, 61, 185, 185, 40, 40, 39, 39, 37, 37, 0, 0, 267, 267,
	269, 269, 270, 270, 409, 409, 291, 78, 95, 95, 88, 88, 178, 178, 87, 87, 14,
	14, 317, 317, 402, 402, 318, 318, 324, 324, 308, 78, 191, 191, 80, 80, 81,
	81, 82, 82, 13, 13, 312, 312, 311, 311, 310, 310, 415, 415, 308,
	# Left eye.
	33, 7, 7, 163, 163, 144, 144, 145, 145, 153, 153, 154, 154, 155, 155, 133,
	33, 246, 246, 161, 161, 160, 160, 159, 159, 158, 158, 157, 157, 173, 173,
	133,
	# Left eyebrow.
	46, 53, 53, 52, 52, 65, 65, 55, 70, 63, 63, 105, 105, 66, 66, 107,
	# Left iris.
	474, 475, 475, 476, 476, 477, 477, 474,
	# Right eye.
	263, 249, 249, 390, 390, 373, 373, 374, 374, 380, 380, 381, 381, 382, 382,
	362, 263, 466, 466, 388, 388, 387, 387, 386, 386, 385, 385, 384, 384, 398,
	398, 362,
	# Right eyebrow.
	276, 283, 283, 282, 282, 295, 295, 285, 300, 293, 293, 334, 334, 296, 296,
	336,
	# Right iris.
	469, 470, 470, 471, 471, 472, 472, 469,
	# Face oval.
	10, 338, 338, 297, 297, 332, 332, 284, 284, 251, 251, 389, 389, 356, 356,
	454, 454, 323, 323, 361, 361, 288, 288, 397, 397, 365, 365, 379, 379, 378,
	378, 400, 400, 377, 377, 152, 152, 148, 148, 176, 176, 149, 149, 150, 150,
	136, 136, 172, 172, 58, 58, 132, 132, 93, 93, 234, 234, 127, 127, 162, 162,
	21, 21, 54, 54, 103, 103, 67, 67, 109, 109, 10,
]

static func face_landmarks_to_render_data(builder: MediaPipeGraphBuilder) -> MediaPipeGraphNode:
	return landmarks_to_render_data(
		builder, FACE_CONNECTIONS,
		Color.from_rgba8(255, 0, 0), Color.from_rgba8(0, 255, 0),
		2.0, false,
	)

func _init() -> void:
	var builder := MediaPipeGraphBuilder.new()
	var loop_begin := builder.add_node("BeginLoopNormalizedLandmarkListVectorCalculator")
	var render_data := face_landmarks_to_render_data(builder)
	var loop_end := builder.add_node("EndLoopRenderDataCalculator")
	var annotation := builder.add_node("AnnotationOverlayCalculator")
	builder.get_input_tag("IMAGE").connect_to(annotation.get_input_tag("IMAGE"), "input_image")
	builder.get_input_tag("LANDMARKS").connect_to(loop_begin.get_input_tag("ITERABLE"), "multi_face_landmarks")
	loop_begin.get_output_tag("ITEM").connect_to(render_data.get_input_tag("NORM_LANDMARKS"), "face_landmarks")
	render_data.get_output_tag("RENDER_DATA").connect_to(loop_end.get_input_tag("ITEM"), "landmarks_render_data")
	loop_begin.get_output_tag("BATCH_END").connect_to(loop_end.get_input_tag("BATCH_END"), "landmark_timestamp")
	loop_end.get_output_tag("ITERABLE").connect_to(annotation.get_input_tag("VECTOR"), "multi_face_landmarks_render_data")
	annotation.get_output_tag("IMAGE").connect_to(builder.get_output_index(0), "output_image")
	var config := builder.get_config()
	initialize(config)

func render(image: MediaPipeImage, multi_face_landmarks: Array[MediaPipeNormalizedLandmarks]) -> MediaPipeImage:
	var packets := {
		"input_image": image.get_image_frame_packet(),
		"multi_face_landmarks": MediaPipeNormalizedLandmarks.make_vector_proto_packet(multi_face_landmarks),
	}
	var outputs := process(packets)
	if outputs.has("output_image"):
		var packet := outputs.get("output_image") as MediaPipePacket
		var output_image := packet.get() as MediaPipeImage
		return output_image
	return image
