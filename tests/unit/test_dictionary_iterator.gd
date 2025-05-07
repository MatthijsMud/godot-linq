extends GutTest

func test_empty_does_not_yield_values():
	var empty: Dictionary = {};
	var subject := DictionaryIterator.new(empty);
	
	var result := subject._iter_init([null]);
	
	assert_false(result);
	
func test_iter_init_returns_true_if_source_contains_one_element():
	var data: Dictionary = { "name": "Godot" };
	var subject := DictionaryIterator.new(data);
	
	var result := subject._iter_init([null]);
	
	assert_true(result);

func test_iter_next_returns_false_if_source_contains_one_element():
	var data: Dictionary = { "name": "Godot" };
	var subject := DictionaryIterator.new(data);
	var state_reference := [null];
	subject._iter_init(state_reference);
	
	var result := subject._iter_next(state_reference);
	
	assert_false(result);

func test_iter_get_returns_key_value_pair():
	var data: Dictionary = { "name": "Godot" };
	var subject := DictionaryIterator.new(data);
	var state_reference := [null];
	subject._iter_init(state_reference);
	
	var result = subject._iter_get(state_reference[0]);
	
	assert_typeof(result, TYPE_ARRAY);
	assert_eq(len(result), 2);
	assert_eq(result[0], "name");
	assert_eq(result[1], "Godot");

func test_dictionary_iterator_returns_all_elements():
	var data := {
		"name": "Godot",
		"type": "Game engine",
		"version": [4,4],
	}
	var subject := DictionaryIterator.new(data);
	var result := [];
	var state_reference := [null];
	
	var has_next = subject._iter_init(state_reference);
	
	# Use a known number of iterations to prevent potentially iterating forever
	# if the iterator has been implemented incorrectly.
	for _i in len(data): # [method _iter_init] takes care of the first element.
		assert_true(has_next, "subject should contain elements");
		var value = subject._iter_get(state_reference[0]);
		result.push_back(value);
		
		has_next = subject._iter_next(state_reference);
	
	assert_false(has_next, "subject has been exhausted");
	
	# A dictionary does not have a defined order in which it is iterated.
	assert_has(result, ["version", [4,4]])
	assert_has(result, ["type", "Game engine"]);
	assert_has(result, ["name", "Godot"]);
	
