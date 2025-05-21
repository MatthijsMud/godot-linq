extends GutTest

class TestAll extends GutTest:
	
	const cases := [
		[[], true, { "next": 0, "get": 0 }],
		[[false], false, { "next": 0, "get": 1 }],
		[[true], true, { "next": 1, "get": 1 }],
		[[false, false], false, { "next": 0, "get": 1 }],
		[[false, true], false, { "next": 0, "get": 1 }],
		[[true, false], false, { "next": 1, "get": 2 }],
		[[true, true], true, { "next": 2, "get": 2 }],
	]
	
	func test_all(params = use_parameters(cases)):
		var sequence := params[0] as Array;
		var expected_return_value := params[1] as bool;
		var expected_number_of_evaluations := params[2] as Dictionary;
		
		var MockedIterator = double(Iterator);
		var mock = MockedIterator.new();
		stub(mock, &"_iter_init").to_call(func(iter): iter[0] = 0; return iter[0] < len(sequence));
		stub(mock, &"_iter_next").to_call(func(iter): iter[0] += 1; return iter[0] < len(sequence));
		stub(mock, &"_iter_get").to_call(func(iter): return sequence[iter]);
		var subject := ChainedIterator.new(mock);
		
		var result := subject.all(func(e): return e);
		
		assert_eq(result, expected_return_value);
		assert_call_count(mock, &"_iter_init", 1);
		assert_call_count(mock, &"_iter_next", expected_number_of_evaluations.get("next"));
		assert_call_count(mock, &"_iter_get", expected_number_of_evaluations.get("get"));

class TestAny extends GutTest:
	
	const without_callback_cases := [
		[[], false, { "next": 0, "get": 0}],
		[[false], true, { "next": 0, "get": 1 }],
		[[true], true, { "next": 0, "get": 1 }],
		[[false, false], true, { "next": 0, "get": 1 }],
		[[false, true], true, { "next": 0, "get": 1 }],
		[[true, false], true, { "next": 0, "get": 1 }],
		[[true, true], true, { "next": 0, "get": 1 }],
	]
	
	func test_any_without_predicate(params = use_parameters(without_callback_cases)):
		var sequence := params[0] as Array;
		var expected_return_value := params[1] as bool;
		var expected_number_of_evaluations := params[2] as Dictionary;
		
		var MockedIterator = double(Iterator);
		var mock = MockedIterator.new();
		stub(mock, &"_iter_init").to_call(func(iter): iter[0] = 0; return iter[0] < len(sequence));
		stub(mock, &"_iter_next").to_call(func(iter): iter[0] += 1; return iter[0] < len(sequence));
		stub(mock, &"_iter_get").to_call(func(iter): return sequence[iter]);
		var subject := ChainedIterator.new(mock);
		
		var result := subject.any();
		
		assert_eq(result, expected_return_value);
		assert_call_count(mock, &"_iter_init", 1);
		assert_call_count(mock, &"_iter_next", expected_number_of_evaluations.get("next"));
		assert_call_count(mock, &"_iter_get", expected_number_of_evaluations.get("get"));
	
	const with_callback_cases := [
		[[], false, { "next": 0, "get": 0 }],
		[[false], false, { "next": 1, "get": 1 }],
		[[true], true, { "next": 0, "get": 1 }],
		[[false, false], false, { "next": 2, "get": 2 }],
		[[false, true], true, { "next": 1, "get": 2 }],
		[[true, false], true, { "next": 0, "get": 1 }],
		[[true, true], true, { "next": 0, "get": 1 }],
	]
	
	func test_any_with_predicate(params = use_parameters(with_callback_cases)):
		var sequence := params[0] as Array;
		var expected_return_value := params[1] as bool;
		var expected_number_of_evaluations := params[2] as Dictionary;
		
		var MockedIterator = double(Iterator);
		var mock = MockedIterator.new();
		stub(mock, &"_iter_init").to_call(func(iter): iter[0] = 0; return iter[0] < len(sequence));
		stub(mock, &"_iter_next").to_call(func(iter): iter[0] += 1; return iter[0] < len(sequence));
		stub(mock, &"_iter_get").to_call(func(iter): return sequence[iter]);
		var subject := ChainedIterator.new(mock);
		
		var result := subject.any(func(e): return e);
		
		assert_eq(result, expected_return_value);
		assert_call_count(mock, &"_iter_init", 1);
		assert_call_count(mock, &"_iter_next", expected_number_of_evaluations.get("next"));
		assert_call_count(mock, &"_iter_get", expected_number_of_evaluations.get("get"));

class TestCount extends GutTest:
	
	const without_callback_cases := [
		[[], 0], 
		[[null], 1],
		[[null, null], 2]
	];
	
	func test_count_without_callback_returns_number_of_elements_in_sequence(params = use_parameters(without_callback_cases)):
		var sequence := params[0] as Array;
		var expected_return_value := params[1] as int;
		
		var MockedIterator = double(Iterator);
		var mock = MockedIterator.new();
		stub(mock, &"_iter_init").to_call(func(iter): iter[0] = 0; return iter[0] < len(sequence));
		stub(mock, &"_iter_next").to_call(func(iter): iter[0] += 1; return iter[0] < len(sequence));
		var subject := ChainedIterator.new(mock);
		
		var result := subject.count();
		
		assert_eq(result, expected_return_value);
	
	const with_callback_cases := [
		[[], 0],
		[[false], 0],
		[[false, true], 1],
		[[true, false, false], 1],
		[[true, false, true], 2]
	];
	
	func test_count_with_callback_returns_number_of_elements_in_sequence(params = use_parameters(with_callback_cases)):
		var sequence := params[0] as Array;
		var expected_return_value := params[1] as int;
		
		var MockedIterator = double(Iterator);
		var mock = MockedIterator.new();
		stub(mock, &"_iter_init").to_call(func(iter): iter[0] = 0; return iter[0] < len(sequence));
		stub(mock, &"_iter_next").to_call(func(iter):print(iter); iter[0] += 1; return iter[0] < len(sequence));
		stub(mock, &"_iter_get").to_call(func(iter): return sequence[iter]);
		var subject := ChainedIterator.new(mock);
		
		var result := subject.count(func(e): return e);
		
		assert_eq(result, expected_return_value);
