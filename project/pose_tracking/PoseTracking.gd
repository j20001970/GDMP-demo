extends Node

var graph : GDMP.Graph
var camera_helper : GDMP.CameraHelper
var gpu_helper : GDMP.GPUHelper

func _ready() -> void:
	$TextureRect.texture = ImageTexture.new()
	graph = GDMP.Graph.new()
	graph.initialize("res://mediapipe/graphs/pose_tracking/pose_tracking_gpu.pbtxt", true)
	graph.add_packet_callback("output_video", self, "_on_new_frame")
	graph.add_packet_callback("pose_landmarks", self, "_on_new_pose")
	gpu_helper = GDMP.GPUHelper.new()
	gpu_helper.initialize(graph)
	camera_helper = GDMP.CameraHelper.new()
	camera_helper.connect("permission_granted", self, "_on_permission_granted")
	camera_helper.connect("permission_denied", self, "_on_permission_denied")
	camera_helper.set_graph(graph, "input_video")
	graph.start()
	if camera_helper.permission_granted():
		camera_helper.start(GDMP.CAMERA_FACING_FRONT, Vector2(640, 480))
	else:
		camera_helper.request_permission()

func _on_permission_granted() -> void:
	print("permission granted")
	camera_helper.start(GDMP.CAMERA_FACING_FRONT, Vector2(640, 480))

func _on_permission_denied() -> void:
	print("permission denied")

func _on_new_frame(stream_name : String, packet) -> void:
	var image : Image = gpu_helper.get_gpu_frame(packet)
	$TextureRect.texture.create_from_image(image)

func _on_new_pose(stream_name : String, packet) -> void:
	var bytes : PoolByteArray = packet.get_proto()
	var landmarks : GDMP.NormalizedLandmarkList = GDMP.NormalizedLandmarkList.new()
	landmarks.from_bytes(bytes)
	for i in range(landmarks.landmark_size()):
		var landmark = landmarks.get_landmark(i)
		var vector : Vector3 = Vector3(landmark.get_x(), landmark.get_y(), landmark.get_z())
