class_name MediaPipeDetectionsRenderer
extends MediaPipeTaskRunner

func _init() -> void:
	var builder := MediaPipeGraphBuilder.new()
	var render_data := builder.add_node("DetectionsToRenderDataCalculator")
	var annotation := builder.add_node("AnnotationOverlayCalculator")
	var options := MediaPipeProto.new()
	options.initialize("mediapipe.DetectionsToRenderDataCalculatorOptions")
	options.set_field("thickness", 4.0)
	options.set_field("color/r", 255)
	render_data.set_options(options)
	builder.get_input_tag("IMAGE").connect_to(annotation.get_input_tag("IMAGE"), "input_image")
	builder.get_input_tag("DETECTIONS").connect_to(render_data.get_input_tag("DETECTIONS"), "detections")
	render_data.get_output_tag("RENDER_DATA").connect_to(annotation.get_input_index(0), "render_data")
	annotation.get_output_tag("IMAGE").connect_to(builder.get_output_index(0), "output_image")
	var config := builder.get_config()
	initialize(config)

func render(image: MediaPipeImage, detections: Array[MediaPipeDetection]) -> MediaPipeImage:
	var packets := {
		"input_image": image.get_image_frame_packet(),
		"detections": MediaPipeDetection.make_vector_proto_packet(detections)
	}
	var outputs := process(packets)
	if outputs.has("output_image"):
		var packet := outputs.get("output_image") as MediaPipePacket
		var output_image = packet.get() as MediaPipeImage
		return output_image
	return image
