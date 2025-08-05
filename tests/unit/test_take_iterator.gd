extends GutTest

const cases := [
	# [0]: Source.
	# [1]: Array describing which elements to pick from the source.
	[[null], []],
	[["Hello"], [0]],
	[["Hello", "World"], [0]],
	[["alpha", "bravo", "charlie", "delta"], [0,1,2,3]],
	[["alpha", "bravo", "charlie", "delta"], [0,1,2]],
];

func test_take(params = use_parameters(cases)):
	var source := params[0] as Array;
	var sequence := (params[1] as Array).map(func(i): return source[i]);
	var number_of_elements_to_take = len(params[1]);
	
	var MockedIterator = double(Iterator);
	var mock = MockedIterator.new();
	stub(mock, &"_iter_init").to_call(func(iter): iter[0] = 0; return iter[0] < len(source));
	stub(mock, &"_iter_next").to_call(func(iter): iter[0] += 1; return iter[0] < len(source));
	stub(mock, &"_iter_get").to_call(func(iter): return source[iter]);
	var subject := ChainedIterator.new(mock);
	
	var result := [];
	for element in subject.take(number_of_elements_to_take):
		result.push_back(element);
	
	assert_eq(result, sequence);
