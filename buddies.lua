--
-- buddies 
--
-- Copyright (c) 2015 Sheepolution
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.

buddies = {}

buddies.__index = buddies

buddies._forward = {}

local makeFunc = function (self,f)
	newFunc = function (forward,...)
		--Standard iterates reversed for save removal.
		--By passing buddies._forward it will iterate forwards.
		if forward == buddies._forward then
			for i=1,#self do
				self[i][f](...)
			end
		else
			for i=#self,1,-1 do
				self[i][f](forward,...)
			end
		end
	end
	return newFunc
end

function buddies.new()
	return setmetatable({}, buddies)
end

--Adds objects to the group, and copies their functions.
function buddies:_add(...)
	local args = {...}
	for i = 1, select("#", ...) do
		local obj = args[i]
		if type(obj) == "table" then
			self[#self+1] = obj
			for k,v in pairs(obj) do
				if type(obj[k]) == "function" and not self[k] then
					self[k] = makeFunc(self,k)
				end
			end
		end
	end
end

--Copies the functions of the object, without adding the objects.
function buddies:_prepare(...)
	local args = {...}
	for i = 1, select("#", ...) do
		local obj = args[i]
		if type(obj) == "table" then
			for k,v in pairs(obj) do
				if type(obj[k]) == "function" then
					self[k] = makeFunc(self,k)
				end
			end
		end
	end
end

--Removes the object. If a number is passed, the object on that position will be removed instead.
function buddies:_remove(obj)
	t = type(obj)
	
	local kill = 0
	
	if t == "table" then
		for i=1,#self do
			if self[i] == obj then
				kill = i
				break
			end
		end
	elseif t == "number" then
		kill = obj
	end

	if kill > 0 then
		self[kill] = nil
	end

	for i=kill + 1,#self do
		self[i-1] = self[i]
	end

	self[#self] = nil
end

--Calls the passed function for each object, passing the object as first argument.
function buddies:_call(func)
	for i=1,#self do
		func(self[i])
	end
end

--Has all the objects iterate through the other objects, allowing for interactivity.
--Calls the passed function, giving both objects as arguments.
--buddies._forward can be passed to make the function iterate forwards.
function buddies:_others(func,forward)
	local kill
	if forward == buddies._forward then
		for i=1,#self-1 do
			for j=i+1,#self do
				if func(self[i],self[j]) then break end
			end
		end
	else
		for i=#self,2,-1 do
			for j=i-1,1,-1 do
				if func(self[i],self[j]) then break end
			end
		end
	end
end

--Sets a value to all the objects.
--Will only set the value if the object already has the property, unless force is true.
function buddies:_set(k,v,force)
	for i=1,#self do
		if self[i][k]~=nil or force then
			self[i][k] = v
		end
	end
end

--Removes all the objects, but keeps the functions.
function buddies:_flush()
	for i=1,#self do
		self[i] = nil
	end
end

--Sorts all the objects on a property.
--If an object does not have the passed property, it will be treated as 0.
--Will automatically sort from low to high, unlesss htl (high to low) is true.
function buddies:_sort(k,htl)
	local sorted = false
	if htl then
		while not sorted do
			sorted = true
			for i=1,#self-1 do
				for j=i+1,#self do
					local propA, propB
					propA = self[i][k] or 0
					propB = self[j][k] or 0
					if propA < propB then
						local old = self[j]
						self[j] = self[i]
						self[i] = old
						sorted = false
					end
				end
			end
		end
	else
		while not sorted do
			sorted = true
			for i=1,#self-1 do
				for j=i+1,#self do
					local propA, propB
					propA = self[i][k] or 0
					propB = self[j][k] or 0
					if propA > propB then
						local old = self[j]
						self[j] = self[i]
						self[i] = old
						sorted = false
					end
				end
			end
		end
	end
end