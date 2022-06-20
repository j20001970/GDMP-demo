extends Control

export(NodePath) var btn_initialize
export(NodePath) var btn_is_initialized
export(NodePath) var btn_is_running
export(NodePath) var btn_has_input_stream
export(NodePath) var btn_has_output_stream
export(NodePath) var btn_add_callback
export(NodePath) var btn_start
export(NodePath) var btn_stop
export(NodePath) var chk_as_text
export(NodePath) var input_graph_path
export(NodePath) var input_stream_name
export(NodePath) var input_callback_stream
export(NodePath) var label

var graph : GDMP.Graph

func _ready():
	graph = GDMP.Graph.new()
	get_node(btn_initialize).connect("pressed", self, "initialize")
	get_node(btn_is_initialized).connect("pressed", self, "is_initialized")
	get_node(btn_is_running).connect("pressed", self, "is_running")
	get_node(btn_has_input_stream).connect("pressed", self, "has_input_stream")
	get_node(btn_has_output_stream).connect("pressed", self, "has_output_stream")
	get_node(btn_add_callback).connect("pressed", self, "add_callback")
	get_node(btn_start).connect("pressed", self, "start")
	get_node(btn_stop).connect("pressed", self, "stop")

func initialize() -> void:
	graph.initialize(get_node(input_graph_path).text, get_node(chk_as_text).pressed)

func is_initialized() -> void:
	get_node(label).text = "is_initialized: " + str(graph.is_initialized())

func is_running() -> void:
	get_node(label).text = "is_running: " + str(graph.is_running())

func has_input_stream() -> void:
	get_node(label).text = "has_input_stream: " + str(graph.has_input_stream(get_node(input_stream_name).text))

func has_output_stream() -> void:
	get_node(label).text = "has_output_stream: " + str(graph.has_output_stream(get_node(input_stream_name).text))

func add_callback() -> void:
	var stream_name : String = get_node(input_callback_stream).text
	graph.add_packet_callback(stream_name, self, "packet_callback")

func start() -> void:
	graph.start({})

func stop() -> void:
	graph.stop()

func packet_callback(stream_name : String, packet) -> void:
	print("packet callback from", stream_name)
