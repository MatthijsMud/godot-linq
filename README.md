# Iterator

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

### `select(…)`

```gdscript
func select(selector: Callable) -> Iterator
```
Creates a new [`Iterator`] where each value is the result of calling `selector` with the corresponding element in the source (and optionally its index). 

Lazy counterpart to [`Array.map`].

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
[`Array.reduce`]: https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-reduce
[`Array.map`]: https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-map
[`Array.filter`]: https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-filter

[custom_iterator]: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_advanced.html#custom-iterators

[System.Linq]: https://learn.microsoft.com/en-us/dotnet/api/system.linq