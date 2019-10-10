# buddies

A group module for Lua.

## Installation

```lua
buddies = require "buddies"
```

After requiring it, you can make a new group like this:

```lua
objects = buddies.new()
```


Now you can add objects to your group.

## Usage 

### Example

```lua
dog = {}
function dog:makeSound()
	print("Bark!")
end

cat = {}
function cat:makeSound()
	print("Meow!")
end

objects:add(dog,cat)
```

And now we can make our group call `makeSound()`

```lua
objects:makeSound()
--output: "Meow!", "Bark!"
```

It normally iterates reversed, by adding an underscore at the end of the function name you iterate forwards.

```lua
objects:makeSound_()
--output: "Bark!", "Meow!"
```

### add([n], ...)
Adds objects to the group.
If you pass a number as first argument, the passed objects will be added to that position in the group.

```lua
objects:add(dog, cat)
objects:add(2, bird, monkey)
-- dog, bird, money, cat
```

### remove(object)
### remove(n)
### remove(func)
Removes `object` from the group.
If number `n` is passed instead, it will remove the object on that position in the group.
If function `func` is passed instead, it removes all objects where `func` returns `true` when the object is passed as argument.

```lua
objects:add(dog, cat, bird)
objects:makeSound()
--output: "Kruauuaa!!", "Meow!", "Bark!"

objects:remove(cat)
objects:makeSound()
--output: "Kruauuaa!!", "Bark!"

objects:remove(2)
objects:makeSound()
--ouput: "Kruauuaa!!"
```

```lua
objects:add(dog, bird cat)
objects:remove(function (e) return e.canFly end)
-- objects: dog, cat 
```

### flush()
Removes all objects from the group.

### table([func])
Returns a copy of the group as table. If a function is passed, it filters to all objects where `func` returns `true` when the object is passed as argument.
```lua
objects:add(dog, bird cat)
t = objects:table(
	function (self)
		return self.canFly
	end)
-- objects: dog, bird, cat 
-- t: bird
```

### clone([func])
Returns a clone of the group as buddies group. If a function is passed, it will only clone the objects in the group where `func` returns `true` when the object is passed as argument.

### count([func])
Returns the number of objects in the group, same as `#objects`. If a function is passed, it returns the number of objects in the group where `func` returns true when the object is passed as argument.

```lua
objects:add(dog, bird, cat)
print(objects:count(function (self)
	return self.canFly
end))
-- Output: 1
```

### others(func)
### others_(func)
Makes all the objects iterate through the other objects, and calls `func` with the objects as arguments.

If the passed function returns `true`, it continues the outer loop, meaning `a` will change to the next object in line.

Normally iterates reversed, use `others_` to iterate forwards.

```lua
objects:add(dog, cat, bird)
objects:others(function (a, b)
	a:becomeFriends(b)
	b:becomeFriends(a)
end)
```

### call(func)
### call_(func)
Calls the passed function for each object, passing the object itself as first argument.
Normally iterates reversed, use `call_` to iterate forwards.
You can also call the buddies object as function (`objects(func)`).

```lua
objects:add(bird, dog, cat)
objects:call(function (self)
	print(self.canFly)
end)
--ouput: false, false, true
```


### set(k, v, force)
Sets the value of a property for all objects.

It will only set the value if the object already has this property, unless `force` is `true`.

```lua
objects:add(bird, cat, tree)
objects:set("sound", "hello!")
objects:makeSound()
--ouput: "hello!", "hello!", ""
--Tree has no property sound

objects:set("sound", "bye!", true)
objects:makeSound()
--ouput: "bye!", "bye!", "bye!"
```

### sort(k, htl)
Sorts all the objects on a property.

If an object does not have the passed property, it will be treated as `0`.

Will automatically sort from low to high, unlesss `htl` (high to low) is `true`.

```lua
objects:add(elephant, mouse, cat)
objects:printName()
--ouput: "cat", "mouse", "elephant"

objects:sort("size")
objects:printName()
--output: "elephant", "cat", "mouse"
```

## superbuddy
A superbuddy is a buddy that can store other buddies. You create a superbuddy by passing `true` as first argument in `.new`.

```lua
animals = buddies.new(sheep, cat, dog)
insects = buddies.new(wasp, bee, fly)

creatures = buddies.new(true, animals, insects)
print(creatures:count())
--output: 6
```

In theory a superbuddy can store other superbuddies, and thus create an endless chain of superbuddies. All normal buddies functions work for a superbuddy as well. With those functions the objects are treated as one big group, e.g. `superbuddy:table()` returns all objects and `superbuddy:count()` counts all objects. Note that `superbuddy:sort()` sorts each buddy individually from each other. `clone(func)` clones all groups into one big normal buddy (and thus no superbuddy).

### add([n, [n2]], ...)

Add buddies to your superbuddy. If `n` is a number, the objects are passed to the buddy on that position in the superbuddy group instead.
If `n2` is also number, the objects are passed to that position to the buddy on position `n`.

```lua
creatures:add(1, cow)
creatures:add(2, cockroach)
```

## License

This library is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.
