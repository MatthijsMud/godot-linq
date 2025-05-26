extends GutTest

func test_unrelated_script_type_not_in_result():
	var unexpected := UnrelatedClassForTestingOfType.new();
	var MockedIterator = double(Iterator);
	var mock = MockedIterator.new();
	stub(mock, &"_iter_init").to_return(true);
	stub(mock, &"_iter_next").to_return(false);
	stub(mock, &"_iter_get").to_return(unexpected);
	var subject := OfTypeIterator.new(mock, BaseClassForTestingOfType);
	
	var result := [];
	for element in subject:
		result.push_back(element);
		
	assert_eq(result, []);

func test_exact_script_type_in_result():
	
	var expected := DerivedClassForTestingOfType.new();
	var MockedIterator = double(Iterator);
	var mock = MockedIterator.new();
	stub(mock, &"_iter_init").to_return(true);
	stub(mock, &"_iter_next").to_return(false);
	stub(mock, &"_iter_get").to_return(expected);
	var subject := OfTypeIterator.new(mock, DerivedClassForTestingOfType);
	
	var result := [];
	for element in subject:
		result.push_back(element);
	
	assert_eq(result, [expected]);

func test_ancestor_script_Type_not_in_result():
	var unexpected := BaseClassForTestingOfType.new();
	var MockedIterator = double(Iterator);
	var mock = MockedIterator.new();
	stub(mock, &"_iter_init").to_return(true);
	stub(mock, &"_iter_next").to_return(false);
	stub(mock, &"_iter_get").to_return(unexpected);
	var subject := OfTypeIterator.new(mock, DerivedClassForTestingOfType);
	
	var result := [];
	for element in subject:
		result.push_back(element);
	
	assert_eq(result, []);

func test_derived_script_type_in_result():
	var expected := DerivedClassForTestingOfType.new();
	var MockedIterator = double(Iterator);
	var mock = MockedIterator.new();
	stub(mock, &"_iter_init").to_return(true);
	stub(mock, &"_iter_next").to_return(false);
	stub(mock, &"_iter_get").to_return(expected);
	var subject := OfTypeIterator.new(mock, BaseClassForTestingOfType);
	
	var result := [];
	for element in subject:
		result.push_back(element);
	
	assert_eq(result, [expected]);

const of_type_defaults := [
	[TYPE_ARRAY, []],
	[TYPE_INT, 0],
	[TYPE_FLOAT, 0.0],
	[TYPE_STRING, "<null>"], # Not sure whether this is actually desirable
	[TYPE_STRING_NAME, &""],
	[TYPE_COLOR, Color()],
	[&"Node2D", null],
	[&"Control", null],
	[BaseClassForTestingOfType, null],
	[DerivedClassForTestingOfType, null],
]

func test_default(params = use_parameters(of_type_defaults)):
	var type = params[0];
	var expected = params[1];
	var MockedIterator = double(Iterator);
	var mock = MockedIterator.new();
	var subject := OfTypeIterator.new(mock, type);
	
	var result = subject._default();
	
	assert_eq(result, expected);
	# Type of the source is no longer relevant.
	assert_not_called(mock, &"_default");

class BaseClassForTestingOfType:
	pass

class DerivedClassForTestingOfType extends BaseClassForTestingOfType:
	pass
	
class UnrelatedClassForTestingOfType:
	pass
