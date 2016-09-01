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

## Usage

### add(...)
Adds objects to the group, and adds the function of those objects.
```lua
objects:add(dog, cat)
```


### remove(object)
Removes `object` from the group. If a number is passed, it will remove the object on that position in the group.

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

### flush()
Removes all the objects, but keeps the functions.
```lua
objects:add(dog, cat, bird)
objects:makeSound()
--output: "Kruauuaa!!", "Meow!", "Bark!"

objects:flush()
objects:makeSound()
--No output as there are no objects
```


### interact(func)
### interact_(func)
Makes all the objects iterate through the other objects, and calls `func` with the objects as arguments.

If func returns true, it will break the second loop.

Normally iterates reversed, use `interact_`, to iterate forwards.

```lua
objects:add(dog, cat, bird)
objects:interact(function (a, b)
	a:becomeFriends(b)
	b:becomeFriends(a)
end)
```

### call(func)
### call_(func)
Calls the passed function for each object, passing the object itself as first argument.

Normally iterates reversed, use `call_`, to iterate forwards.

```lua
objects:add(bird, dog, cat)
objects:call(function (self)
	print(self.canFly)
end)
--ouput: false, false, true
```


### set(k, v, force)
Sets the value of a property of all objects.

It will only set the value of the object already has this property, unless `force` is `true`.

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

##superbuddy
A superbuddy is a buddy that can store other buddies. You create a superbuddy by passing ``true`` as first argument in ``.new``.

```lua
animals = buddies.new(sheep, cat, dog)
insects = buddies.new(wasp, bee, fly)

creatures = buddies.new(true, animals, insects)
print(creatures:count())
--output: 6
```

A superbuddy has a bit different functionality.

For ``add`` you have to pass a number as to which buddy you want to add something.

```lua
creatures:add(1, cow)
creatures:add(2, cockroach)
```

If you want to pass more buddies after initializing, you'll have to do it manually

```lua
plants = buddies.new(tree, flower)
creatures[3] = plants
```

In theory a superbuddy can store other superbuddies, and thus create an endless chain of superbuddies. Though this hasn't been tested properly.



## License

This library is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.
