class_name MediaPipeLandmarksRenderer
extends MediaPipeTaskRunner

static func landmarks_to_render_data(
	builder: MediaPipeGraphBuilder,
	landmark_connections: PackedInt32Array = [],
	landmark_color: Color = Color.BLACK,
	connection_color: Color = Color.BLACK,
	thickness: float = 1.0,
	visualize_landmark_depth: bool = true,
	utilize_visibility: bool = false,
	visibility_threshold: float = 0.0) -> MediaPipeGraphNode:
	var node := builder.add_node("LandmarksToRenderDataCalculator")
	var options := MediaPipeProto.new()
	options.initialize("mediapipe.LandmarksToRenderDataCalculatorOptions")
	options.set_field("landmark_connections", landmark_connections)
	options.set_field("landmark_color/r", landmark_color.r8)
	options.set_field("landmark_color/g", landmark_color.g8)
	options.set_field("landmark_color/b", landmark_color.b8)
	options.set_field("connection_color/r", connection_color.r8)
	options.set_field("connection_color/g", connection_color.g8)
	options.set_field("connection_color/b", connection_color.b8)
	options.set_field("thickness", thickness)
	options.set_field("visualize_landmark_depth", visualize_landmark_depth)
	options.set_field("utilize_visibility", utilize_visibility)
	options.set_field("visibility_threshold", visibility_threshold)
	node.set_options(options)
	return node
