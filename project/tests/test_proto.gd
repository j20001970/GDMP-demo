extends GutTest

func test_uninitialized():
	var proto := MediaPipeProto.new()
	assert_false(proto.is_initialized())
	assert_eq(proto.get_type_name(), "")
	assert_true(proto.get_fields().is_empty())
	assert_false(proto.is_repeated_field(""))
	assert_eq(proto.get_repeated_field_size(""), 0)
	assert_null(proto.get_field(""))
	assert_null(proto.get_repeated_field("", 0))
	assert_false(proto.set_field("", 0))
	assert_null(proto.duplicate())
