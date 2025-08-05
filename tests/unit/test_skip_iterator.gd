extends GutTest

const cases := [
	# [0]: Source.
	# [1]: Array describing which elements to pick from the source.
	[[null], 1],
	[["Hello"], 0],
	[["Hello"], 1],
	[["Hello", "World"], 1],
	[["alpha", "bravo", "charlie", "delta"], 1],
	[["alpha", "bravo", "charlie", "delta"], 100],
];

func test_skip(params = use_parameters(cases)):
	var source := params[0] as Array;
	var number_of_elements_to_skip = params[1];
	var expected = source.slice(number_of_elements_to_skip);
	
	var MockedIterator = double(Iterator);
	var mock = MockedIterator.new();
	stub(mock, &"_iter_init").to_call(func(iter): iter[0] = 0; return iter[0] < len(source));
	stub(mock, &"_iter_next").to_call(func(iter): iter[0] += 1; return iter[0] < len(source));
	stub(mock, &"_iter_get").to_call(func(iter): return source[iter]);
	var subject := ChainedIterator.new(mock);
	
	var result := [];
	for element in subject.skip(number_of_elements_to_skip):
		result.push_back(element);
	
	assert_eq(result, expected);
