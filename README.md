#  Iterator

<p align="center">
<img src="logo.svg" width="100" height="100"/>
</p>

Represents the concept of a sequence which can be transformed and iterated lazily.

Inspired by [System.Linq].

## Static factory methods

### `empty()`
```gdscript
static func empty() -> Iterator
``` 
Creates an [`Iterator`] which doesn't produces any elements by itself.

Useful as an alternative to `null`, as the return value can be chained and iterated indiscriminately.

### `from(…)`
```gdscript
static func from(value: Variant) -> Iterator
```
Wraps the provided iterable object in a suitable [`Iterator`] to allow for easy chaining of various operations on sequences.

If the provided value is already an [`Iterator`], the provided value is returned instead (to avoid excessive wrapping). 

#### Parameters

<dl>
<dt><dfn>value</dfn></dt>
<dd>

Object which supports the concept of itering. 

While Godot does allow [implementing custom iterators][custom_iterator], it does not expose the specified API for builtin types. Any logic for iterating over those types needs to be reimplemented in GdScript; certain types might thus not yield an [`Iterator`].

An implementation has been provided for:

- `Array` or any of the `Packed…Array` types
- `Dictionary` each entry is represented as an array with 2 elements: `[key, value]`
- [`Iterator`]

</dd>
</dl>

### `repeat(…)`
```gdscript
func repeat(element: Variant, count: int) -> Iterator
```

Repeats the provided `element` the specified number of times.

Lazy counterpart to calling [`Array.resize`] followed by [`Array.fill`].

#### Parameters

<dl>
<dt><dfn>element</dfn></dt>
<dd>
The element to repeat.
<dd>
<dt><dfn>count</dfn></dt>
<dd>
Number of times the provided `element` should be repeated. Value should be positive.
</dd>
</dl>

#### Example
```gdscript
var source := Iterator.repeat("Hello", 5);
for element in source: 
  print(element);
```

```
Hello
Hello
Hello
Hello
Hello
```

## Instance methods

### `all(…)`
```gdscript
func all(predicate: Callable) -> bool
```

Returns `true` if `predicate` returns `true` for each element in the sequence, or if the sequence is empty.

Stops as soon as any invocation returns `false`.

Counterpart to [`Array.all`].

#### Parameters

<dl>
<dt><dfn>predicate</dfn></dt>
<dd>

```gdscript
func predicate(element: Variant) -> bool
```
</dd>
</dl>

#### Example

```gdscript
var source := Iterator.from([0,1,2,3,4]);
var result := source.all(func is_even(e): print(e); return e % 2 == 0);
print("Result: ", result);
```

```
0
1
Result: false
```
The second element in the above example does not satisfy the `predicate`. It will therefore not continue to check any further elements.

### `any(…)`
```gdscript
func any() -> bool
func any(predicate: Callable) -> bool
```

Returns `true` if `predicate` returns `true` for 
at least one element in the sequence. It stops as soon as the result can
be determined.

Counterpart to [`Array.any`].

#### Parameters

<dl>
<dt><dfn>predicate</dfn></dt>
<dd>

```gdscript
func predicate(element: Variant) -> bool
```
</dd>
</dl>

#### Example
```gdscript
var source := Iterator.from(range(10));
print(source.any(func is_large(e): return e > 1000))
```

```
false
```


### `contains(…)`
```gdscript
func contains(value: Variant) -> bool
func contains(value: Variant, comparer: Callable) -> bool
```

Returns `true` if the provided `value` is present in this [`Iterator`].

#### Parameters

<dl>
<dt><dfn>value</dfn></dt>
<dd>

Value to look for in the [`Iterator`].
</dd>
<dt><dfn>comparer</dfn></dt>
<dd>

```gdscript
func comparer(left: Variant, right: Variant) -> bool
```
Callback which should return `true` if `left` and `right` are considered equal (`false` otherwise).

If this value is omitted, `is_same` is used to determine whether the provided `value` is in the sequence.
</dd>
</dl>


### `count(…)`
```gdscript
func count() -> int
func count(predicate: Callable) -> int
```
Counts elements for which `predicate` returns `true`. If no `predicate` has been provided, all elements are counted.

> [!NOTE]
> The elements are counted by iterating over the entire sequence, irrespective of whether a `predicate` has been provided. This is ineffecient in cases where the size can be determined directly.

Specialized counterpart to [`Array.reduce`].

#### Parameters

<dl>
<dt><dfn>predicate</dfn></dt>
<dd>

```gdscript
func predicate(element: Variant) -> bool
```
Callback which determines whether the element should be counted (`true`).

It is assumed this method has no side-effects.
</dd>
</dl>

#### Example
```gdscript
var source := Iterator.from([1,1,2,3,5,8,13,21]);
print(source.count(func is_even(e): return e % 2 == 0))
```

```
2
```

### `first(…)`
```gdscript
func first() -> Variant
func first(predicate: Callable) -> Variant
```

Returns the first element for which `predicate` returns `true`. It is an error if no such element exists.

#### Parameters

<dl>
<dt><dfn>predicate</dfn></dt>
<dd>

```gdscript
func predicate(element: Variant) -> bool
```

Callback which indicates whether this is the first element that satisfies the constraints (`true`), or whether it should be ignored (`false`).
</dd>
</dl>

#### Example

```gdscript
var source := Iterator.from(["Alpha", "Bravo", "Charlie", "Delta"]);
print(source.first_or_default(func(e): return e.begins_with("C")));
```

```
Charlie
```

### `first_or_default(…)`
```gdscript
func first_or_default() -> Variant
func first_or_default(default: Variant) -> Variant
func first_or_default(predicate: Callable) -> Variant
func first_or_default(predicate: Callable, default: Variant) -> Variant
```

Returns the first element for which `predicate` returns `true`, or `default` if no element satisfies the constraints.

> [!WARNING]
> This method does not know whether `predicate` or `default` was intended when called with a [`Callable`] as its only parameter. Given all other cases expect it to be `predicate`, it assumes the provided callback to be `predicate`. If it is intended to be the default value, use a work around instead.
>
> - Using thew overload taking both a `predicate` and `default` value.
>   ```gdscript
>   source.first_or_default(Iterator.UNDEFINED, func custom_default(): pass);
>   ```
>
> - Wrapping the [`Callable`] and unwrapping the result.
>   ```gdscript
>   var callback = source\
>     .select(func wrap_in_an_array(element): return [element])\
>     .first_or_default([func custom_default(): pass])[0];
>   ```
> 
> If you do not know in advance whether the default value will be a `Callable` or not, it is recommended to use one of the above work arounds.

#### Parameters

<dl>
<dt><dfn>predicate</dfn></dt>
<dd>

```gdscript
func predicate(element: Variant) -> bool
```

Callback which indicates whether this is the first element that satisfies the constraints (`true`), or whether it should be ignored (`false`).
</dd>
<dt><dfn>default</dfn></dt>
<dd>

Value to return if the source does **not** contain any elements (for which `predicate` returns `true`). If omitted, a default value is generated based on the type associated with the [`Iterator`].

```gdscript
type_convert(null, type)
```

> [!NOTE]
> Godot passes some types by value where C# would pass them by reference. As such some types might have a different default value, for example `Arrays`: `null` in C#, `[]` in Godot.
</dd>
</dl>

#### Example

```gdscript
var source := Iterator.empty();
print(source.first_or_default());
```

```
<null>
```

### `of_type(…)`
```gdscript
func of_type(type: Variant.Type) -> Iterator
func of_type(type: StringName) -> Iterator
func of_type(type: Script) -> Iterator
```

Creates a new [`Iterator`] which only contains the elements of its source that are of the specified `type`.

> [!WARNING]
> This method does not support passing built-in class names as the type parameter. Use a `StringName` instead. 
> ```gdscript
> -  source.of_type(Node2D)
> +  source.of_type(&"Node2D")
> ```
> <details>
> <summary>Reasoning</summary>
> 
> The type descriptor for Godot's builtin type extends a class that is neither exposed to GdScript nor documented; limiting what can reliably be done with it.
> </details>

#### Parameters

<dl>
<dt><dfn>type</dfn><dt>
<dd>

The type all element in the result will have. Any elements that do **not** have the specified type are filtered out. 
- `Variant.Type` for the primitve types.
- `StringName` of a built-in types extending `Object`.
- `Script` for any classes defined in GdScript or C#.
</dd>
</dl>

#### Example

```gdscript
extends Container

func _notification(what: int) -> void:
  if what == NOTIFICATION_SORT_CHILDREN:
    var rect := Rect2(Vector2.ZERO, size);
    for child in Iterator.from(get_children()).of_type(&"Control"):
      fit_child_in_rect(child, rect);

```

### `select(…)`

```gdscript
func select(selector: Callable) -> Iterator
```
Creates a new [`Iterator`] where each value is the result of calling `selector` with the corresponding element in the source (and optionally its index). 

Lazy counterpart to [`Array.map`].

> [!WARNING]
> This method loses type information, unlike [System.Linq]. As a result the various `…_or_default()` methods will return `null` if no custom default value is provided.

#### Parameters

<dl>
<dt><dfn>selector</dfn></dt>
<dd>

```gdscript
func selector(value: Variant) -> Variant
func selector(value: Variant, index: int) -> Variant
```
Callback which is used to create a new representation for the provided value. Called with the _next_ value in the source [`Iterator`] each time a next value is requested.

It is assumed this method has no side-effects.
</dd>
</dl>

#### Example

```gdscript
var source := Iterator.from(range(5))
for e in source.select(func squared(e) return e * e):
  print(e)
```

```
0
1
4
9
16
```

### `select_many(…)`

```gdscript
func select_many(collection_selector: Callable) -> Iterator
func select_many(collection_selector: Callable, result_selector: Callable) -> Iterator
```
Creates a new [`Iterator`] that iterates over the result of calling `collection_selector` with the current element until it exhausted 
Iterate over the [`Iterator`] returned by calling `collection_selector` for elements in the source.

Does not have a Godot counterpart.

> [!WARNING]
> This method loses type information, unlike [System.Linq]. As a result the various `…_or_default()` methods will return `null` if no custom default value is provided.

#### Parameters

<dl>
<dt><dfn>collection_selector</dfn><dt>
<dd>

```gdscript
func collection_selector(element: Variant) -> Iterator
func collection_selector(element: Variant, index: int) -> Iterator
```

Callback which is used to turn each element in the source into an [`Iterator`]-like object. It can optionally accept the index of the element in its source.

It is assumed that this method has no side-effects.

</dd>
<dt><dfn>result_selector</dfn></dt>
<dd>

```gdscript
func result_selector(source: Variant, element: Variant) -> Variant
```
Callback which allows transforming the `element`. This is similar to chaining [`select`], but in this case the `source` is also provided, which allows for setting up references. 

> [!NOTE] 
> The first argument is the same element as provided to `collection_selector`. 

The default implementation (if this callback is omited) returns `element`.

It is assumed that this method has no side-effects.
</dd>
</dl>

#### Example
```gdscript
var source := Iterator.from([[1,2,3], [[4,5], [6]], [], [7, 8]])
for e in source.select_many(func(e): return e):
  print(e)
```

```
1
2
3
[4,5]
[6]
7
8
```

### `sum(…)`
```gdscript
func sum() -> Variant
func sum(selector: Callable) -> Variant
```

Calculates the sum of all elements in the sequence.

#### Parameters

<dl>
<dt><dfn>selector</dfn></dt>
<dd>

```gdscript
func selector(element: Variant) -> Variant
```
Callback which returns either an `int`, `float` or the value `null`. Any other type is considered an error.
</dd>
</dl>

### `where(…)`
```gdscript
func where(predicate: Callable) -> Iterator
```

Creates a new [`Iterator`] that is a subset of its source. It only contains elements for which `predicate` returned `true`.

Lazy counterpart to [`Array.filter`].

#### Parameters

<dl>
<dt><dfn>predicate</dfn></dt>
<dd>

```gdscript
func predicate(value: Variant) -> bool
func predicate(value: Variant, index: int) -> bool
```

Callback which's return value indicates whether each _next_ element in the source should be in the resulting [`Iterator`] (`true`), or if it should be skipped (`false`).

It is assumed this method has no side-effects.
</dd>
</dl>

#### Example

```gdscript
var source := Iterator.from([1, 1, 2, 3, 5, 8, 13])
for e in source.where(func is_even(e): return e % 2 == 0):
  print(e)
```
```
2
8
```

### `zip(…)`

```gdscript
func zip(other: Iterator) -> Iterator
```

Creates a new [`Iterator`] that combines each element from its source with the corresponding element in the provided `other` [`Iterator`] until either is exhausted.

#### Parameters
<dl>
<dt><dfn>other</dfn>
</dt>
<dd>

The other [`Iterator`] -like object to `zip` with. 
</dd>
</dl>

#### Example
```gdscript
var left := Iterator.from([0,1,2,3,4,5])
var right := Iterator.from([6,7,8,9])
for e in left.zip(right):
  print(e)
```

```
[0,6]
[1,7]
[2,8]
[3,9] 
```
Note that `4` and `5` are not iterated, as the `other` source has no more elements to match with. 


[`Iterator`]: #Iterator
[`select`]: #select
[`from`]: #from

[`range`]: https://docs.godotengine.org/en/stable/classes/class_@gdscript.html#class-gdscript-method-range
[`Array.all`]: https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-all
[`Array.any`]: https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-any
[`Array.count`]: https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-count
[`Array.fill`]: https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-fill
[`Array.reduce`]: https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-reduce
[`Array.resize`]: https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-resize
[`Array.map`]: https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-map
[`Array.filter`]: https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-filter

[custom_iterator]: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_advanced.html#custom-iterators

[System.Linq]: https://learn.microsoft.com/en-us/dotnet/api/system.linq