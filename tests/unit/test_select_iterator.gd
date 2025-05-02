extends GutTest

func test_transformed_result_is_returned_from_iterator():
	var MockedIterator = double(Iterator);
	var mock = MockedIterator.new();
	stub(mock, &"_iter_init").to_call(func(iter): iter[0] = 0; return true);
	stub(mock, &"_iter_next").to_call(func(iter): iter[0] += 1; return iter[0] < 5);
	stub(mock, &"_iter_get").to_call(func(iter): return iter);
	var result := [];
	var subject = SelectIterator.new(mock, func squared(e): return e * e);
	
	for e in subject:
		result.push_back(e);
	
	assert_eq(result, [0,1,4,9,16])

var _supported_selector_overloads := [
	func(): pass, 
	func(_0): pass,
	func(_0, _1): pass,
]

func test_select_supports_parameter_overload(overload = use_parameters(_supported_selector_overloads)):
	var MockedIterator = double(Iterator);
	var mock = MockedIterator.new();
	var subject = SelectIterator.new(mock, overload);
	
	for _e in subject: pass
	
	assert_call_count(mock, &"_iter_init", 1);
	assert_call_count(mock, &"_iter_next", 0);
	assert_call_count(mock, &"_iter_get", 0);
	
func test_iterating_twice_calls_init_twice():
	var MockedIterator = double(Iterator);
	var mock = MockedIterator.new();
	var subject = SelectIterator.new(mock, func(_e): return);
	
	for _e in subject: pass;
	for _e in subject: pass;
	
	assert_call_count(mock, &"_iter_init", 2);
	assert_call_count(mock, &"_iter_next", 0);
	assert_call_count(mock, &"_iter_get", 0);

const _iter_init_return_values := [[true], [false]];

func test_iter_init_returns_same_as_source(params = use_parameters(_iter_init_return_values)):
	var MockedIterator = double(Iterator);
	var mock = MockedIterator.new();
	stub(mock, &"_iter_init").to_return(params[0]);
	var subject = SelectIterator.new(mock, func(e, _i): return e);
	
	var result = subject._iter_init([null]);
	
	assert_eq(result, params[0]);
	assert_call_count(mock, &"_iter_init", 1);

func test_iter_next_is_called_if_iter_init_returns_true():
	var MockedIterator = double(Iterator);
	var mock = MockedIterator.new();
	stub(mock, &"_iter_init").to_return(true);
	stub(mock, &"_iter_next").to_return(false);
	var subject = SelectIterator.new(mock, func(e, _i): return e);
	
	for _e in subject: pass;
	
	assert_call_count(mock, &"_iter_init", 1);
	assert_call_count(mock, &"_iter_next", 1);
	assert_call_count(mock, &"_iter_get", 1);


func test_index_is_incremented():
	var MockedIterator = double(Iterator);
	var mock = MockedIterator.new();
	var next_calls = [0]; # Value wrapped in array to allow changing captured value.
	stub(mock, &"_iter_init").to_return(true);
	stub(mock, &"_iter_next").to_call(func(_iter): next_calls[0] += 1; return next_calls[0] < 3);
	var result := [];
	var subject = SelectIterator.new(mock, func(_e,i): result.push_back(i));
	
	for _e in subject: pass;
	
	assert_eq(result, [0, 1, 2])

const _iter_values := [
	[&"Hello", "World", 1],
	[0,1,2,3,4],
	[null, null, null]
]

func test_iter_value_is_passed_to_get(params = use_parameters(_iter_values)):
	var MockedIterator = double(Iterator);
	var mock = MockedIterator.new();
	var iteration = [0]; # Value wrapped in array to allow changing captured value.
	var result := [];
	stub(mock, &"_iter_init").to_call(func(iter): iter[0] = params[iteration[0]]; return true);
	stub(mock, &"_iter_next").to_call(func(iter):
		iteration[0] += 1;
		if iteration[0] < len(params):
			iter[0] = params[iteration[0]]
			return true;
		return false;
	)
	stub(mock, &"_iter_get").to_call(func(iter): result.push_back(iter));
	var subject = SelectIterator.new(mock, func(_e,_i):);
	
	for _e in subject: pass;
	
	assert_eq(result, params);
