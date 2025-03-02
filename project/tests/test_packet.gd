extends GutTest

func test_empty():
	var packet := MediaPipePacket.new()
	assert_true(packet.is_empty())
	assert_eq(packet.get_type_name(), "")
	assert_null(packet.get())

func test_setget():
	var packet := MediaPipePacket.new()
	var rand_int32 := randi() - 2 ** 31
	var rand_int64 := randi() + randi() - 2 ** 63
	var rand_bool := [false, true].pick_random() as bool
	var rand_float := randf()
	var rand_bytes := range(33, 127)
	rand_bytes.shuffle()
	var rand_str = PackedByteArray(rand_bytes).get_string_from_ascii()
	var image := MediaPipeImage.new()
	packet.set_bool(rand_bool)
	assert_eq(packet.get(), rand_bool)
	packet.set_int32(rand_int32)
	assert_eq(packet.get(), rand_int32)
	packet.set_int64(rand_int64)
	assert_eq(packet.get(), rand_int64)
	packet.set_float(rand_float)
	assert_eq(packet.get(), rand_float)
	packet.set_string(rand_str)
	assert_eq(packet.get(), rand_str)
	packet = image.get_packet()
	assert_true(packet.get() is MediaPipeImage)
