extends Control

export(NodePath) var btn_start : NodePath
export(NodePath) var btn_stop : NodePath

var graph : GDMP.Graph
var camera_helper : GDMP.CameraHelper
var gpu_helper : GDMP.GPUHelper

func _ready():
	$TextureRect.texture = ImageTexture.new()
	get_node(btn_start).connect("pressed", self, "start_camera")
	get_node(btn_stop).connect("pressed", self, "stop_camera")
	graph = GDMP.Graph.new()
	graph.initialize("res://mediapipe/graphs/pose_tracking/pose_tracking_gpu.pbtxt", true)
	graph.add_packet_callback("output_video", self, "_on_new_frame")
	gpu_helper = GDMP.GPUHelper.new()
	gpu_helper.initialize(graph)
	camera_helper = GDMP.CameraHelper.new()
	camera_helper.set_graph(graph, "input_video")
	graph.start()

func _on_new_frame(stream_name : String, packet) -> void:
	var image : Image = gpu_helper.get_gpu_frame(packet)
	$TextureRect.texture.create_from_image(image)

func start_camera() -> void:
	if camera_helper.permission_granted():
		var target_size : Vector2 = Vector2(640, 480)
		camera_helper.start(GDMP.CAMERA_FACING_FRONT, target_size)
	else:
		if not camera_helper.is_connected("permission_granted", self, "start_camera"):
			camera_helper.connect("permission_granted", self, "start_camera", [], CONNECT_ONESHOT)
		camera_helper.request_permission()

func stop_camera() -> void:
	camera_helper.close()
