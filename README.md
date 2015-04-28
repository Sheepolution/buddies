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


## Example
Now we can add objects to our group. You can only add metatables.

```lua
dog = {}
dog.__index = dog
function dog:makeSound()
	print("Bark!")
end

cat = {}
cat.__index = {}
function cat:makeSound()
	print("Meow!")
end

dog = setmetatable({},dog)
cat = setmetatable({},cat)

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

## Usage

### add(...)
Adds objects to the group, and adds the function of those objects.
```lua
objects:add(dog,cat)
```

### prepare(...)
Prepares the group for object to come, allowing for calling the functions, even though it doesn't have any objects yet.
```lua
objects:prepare(dog)

objects:makeSound()
--No output as there are no objects
```

### remove(object)
Removes `object` from the group. If a number is passed, it will remove the object on that position in the group.

```lua
objects:add(dog,cat,bird)
objects:makeSound()
--output: "Kruauuaa!!", "Meow!", "Bark!"

objects:remove(cat)
objects:makeSound()
--output: "Kruauuaa!!", "Bark!"

objects:remove(2)
objects:makeSound()
--ouput: "Kruauuaa!!"
```

### flush()
Removes all the objects, but keeps the functions.
```lua
objects:add(dog,cat,bird)
objects:makeSound()
--output: "Kruauuaa!!", "Meow!", "Bark!"

objects:flush()
objects:makeSound()
--No output as there are no objects
```


### others(func)
### others_(func)
Makes all the objects iterate through the other objects, and calls `func` with the objects as arguments.

If func returns true, it will break the second loop.

Normally iterates reversed, use `others_`, to iterate forwards.

```lua
objects:add(dog,cat,bird)
objects:others(function (a,b)
	a:becomeFriends(b)
	b:becomeFriends(a)
end)
```

### call(func)
### call_(func)
Calls the passed function for each object, passing the object as first argument.

Normally iterates reversed, use `call_`, to iterate forwards.

```lua
objects:add(bird,dog,cat)
objects:call(function (self)
	print(self.canFly)
end)
--ouput: false, false, true
```


### set(k, v, force)
Sets the value of a property of all objects.

It will only set the value of the object already has this property, or if `force` is `true`.

```lua
objects:add(bird,cat,tree)
objects:set("sound","hello!")
objects:makeSound()
--ouputs: "hello!", "hello!", ""
--Tree has no property sound

objects:set("sound","bye!",true)
objects:makeSound()
--ouputs: "bye!", "bye!", "bye!"
```

### sort(k, htl)
Sorts all the objects on a property.

If an object does not have the passed property, it will be treated as `0`.

Will automatically sort from low to high, unlesss `htl` (high to low) is `true`.

```lua
objects:add(elephant,mouse,cat)
objects:name()
--ouputs: "cat", "mouse", "elephant"

objects:sort("size")
objects:name()
--outputs; "elephant", "cat", "mouse"
```

## License

This library is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.
