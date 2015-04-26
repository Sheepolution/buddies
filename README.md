# buddies

A group module for Lua.


## Installation

```lua
require "buddies"
```

After requiring it, you can make a new group like this:

```lua
objects = buddies.new()
```


## Example
Now we can add objects to our group.

```lua
dog = {}
function dog:makeSound()
	print("Bark!")
end

cat = {}
function cat:makeSound()
	print("Meow!")
end

objects:_add(dog,cat)
```

And now we can make our group call `makeSound()`

```lua
objects:makeSound()
--output: "Meow!", "Bark!"
```
It normally iterates reversed, buddies._forward can be passed to iterate forwards.
```lua
objects:makeSound(buddies._forward)
--output: "Bark!", "Meow!"
```

## Usage

All functions start with an underscore to prevent overriding with added object's functions.

### _add(...)
Adds objects to the group, and adds the function of those objects.
```lua
objects:_add(dog,cat)
```

### _prepare(...)
Prepares the group for object to come, allowing for calling the functions, even though it doesn't have any objects yet.
```lua
objects:_prepare(dog)

objects:makeSound()
--No output as there are no objects
```

Actually, you should probably skip this function and do the following:
```lua
if #objects > 0 then
	objects:makeSound()
end
```
But if you're too lazy then here you go, use it.

### _remove(object)
Removes `object` from the group. If a number is passed, it will remove the object on that position in the group.

```lua
objects:_add(dog,cat,bird)
objects:makeSound()
--output: "Kruauuaa!!", "Meow!", "Bark!"

objects:_remove(cat)
objects:makeSound()
--output: "Kruauuaa!!", "Bark!"

objects:_remove(2)
objects:makeSound()
--ouput: "Kruauuaa!!"
```

### _flush()
Removes all the objects, but keeps the functions.
```lua
objects:_add(dog,cat,bird)
objects:makeSound()
--output: "Kruauuaa!!", "Meow!", "Bark!"

objects:_flush()
objects:makeSound()
--No output as there are no objects
```


### _others(func, forward)
Makes all the objects iterate through the other objects, and calls `func` with the objects as arguments.

If func returns true, it will break the second loop.

Normally iterates reversed, pass `buddies._forward` to `forward`, to make group iterate forwards.

```lua
objects:_add(dog,cat,bird)
objects:_others(function (a,b)
	a:becomeFriends(b)
	b:becomeFriends(a)
end)
```

### _call(func)
Calls the passed function for each object, passing the object as first argument.

```lua
objects:_add(bird,dog,cat)
objects:_call(function (self)
	print(self.canFly)
end)
--ouput: false, false, true
```


### _set(k, v, force)
Sets the value of a property of all objects.

It will only set the value of the object already has this property, or if `force` is `true`.

```lua
objects:_add(bird,cat,tree)
objects:_set("sound","hello!")
objects:makeSound()
--ouputs: "hello!", "hello!", ""
--Tree has no property sound

objects:_set("sound","bye!",true)
objects:makeSound()
--ouputs: "bye!", "bye!", "bye!"
```

### _sort(k, htl)
Sorts all the objects on a property.

If an object does not have the passed property, it will be treated as `0`.

Will automatically sort from low to high, unlesss `htl` (high to low) is `true`.

```lua
objects:_add(elephant,mouse,cat)
objects:name()
--ouputs: "cat", "mouse", "elephant"

objects:_sort("size")
objects:name()
--outputs; "elephant", "cat", "mouse"
```

## License

This library is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.
