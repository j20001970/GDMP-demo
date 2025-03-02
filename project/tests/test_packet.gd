extends GutTest

func test_empty():
	var packet := MediaPipePacket.new()
	assert_true(packet.is_empty())
	assert_null(packet.get())
