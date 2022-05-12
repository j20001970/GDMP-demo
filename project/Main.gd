extends Control

export(NodePath) var pose_tracking : NodePath

func _ready() -> void:
	get_node(pose_tracking).connect("pressed", get_tree(), "change_scene", ["res://pose_tracking/PoseTracking.tscn"])
