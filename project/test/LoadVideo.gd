extends Control

export(NodePath) var video
export(NodePath) var texture
export(NodePath) var btn_load_video
export(NodePath) var file

var graph : GDMP.Graph
var gpu_helper : GDMP.GPUHelper

func _ready():
	get_node(texture).texture = ImageTexture.new()
	get_node(btn_load_video).connect("pressed", get_node(file), "popup_centered")
	get_node(file).connect("file_selected", self, "_load_video")
	graph = GDMP.Graph.new()
	graph.initialize("res://mediapipe/graphs/pose_tracking/pose_tracking_gpu.pbtxt", true)
	graph.add_packet_callback("output_video", self, "_new_frame")
	gpu_helper = GDMP.GPUHelper.new()
	gpu_helper.initialize(graph)
	graph.start()

func _process(delta):
	if get_node(video).is_playing():
		var texture : ImageTexture = get_node(video).get_video_texture()
		if texture:
			var image : Image = texture.get_data()
			if image:
				var packet = gpu_helper.make_packet_from_image(image)
				packet.set_timestamp(OS.get_ticks_usec())
				graph.add_packet("input_video", packet)

func _load_video(path : String) -> void:
	var video_file : VideoStream = load(path)
	get_node(video).stream = video_file
	get_node(video).play()

func _new_frame(stream_name, packet) -> void:
	var image = gpu_helper.get_gpu_frame(packet)
	$TextureRect.texture.create_from_image(image)
