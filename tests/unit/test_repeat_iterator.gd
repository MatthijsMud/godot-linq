extends GutTest

func test_negative_repeat_is_empty():
	var subject := RepeatIterator.new(&"Irrelevant", -1);
	
	var result := subject._iter_init([null]);
	
	assert_false(result);
	
func test_yields_same_element_n_times():
	var element_to_repeat := {};
	var number_of_times_to_repeat := 10;
	var expected = [];
	expected.resize(10);
	expected.fill(element_to_repeat);
	var subject := RepeatIterator.new(element_to_repeat, number_of_times_to_repeat);
	
	var result := [];
	var iter := [null];
	var has_next := subject._iter_init(iter);
	while len(result) < number_of_times_to_repeat and has_next:
		result.push_back(subject._iter_get(iter[0]));
		has_next = subject._iter_next(iter);
	
	assert_false(has_next);
	assert_eq(result, expected);
	
