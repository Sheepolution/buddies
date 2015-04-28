--
-- buddies 
--
-- Copyright (c) 2015 Sheepolution
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.

local buddies = {}

buddies.__index = buddies

local makeFunc = function (self,f)
	newFunc = function (self,...)
		for i=#self,1,-1 do
			self[i][f](self[i],...)
		end
	end
	return newFunc
end

local makeFuncForward = function (self,f)
	newFunc = function (self,...)
		for i=1,#self do
			self[i][f](self[i],...)
		end
	end
	return newFunc
end


function buddies.new()
	return setmetatable({}, buddies)
end

--Adds objects to the group, and copies their functions.
function buddies:add(...)
	local args = {...}
	for i = 1, select("#", ...) do
		local obj = args[i]
		if type(obj) == "table" then
			self[#self+1] = obj
			for k,v in pairs(getmetatable(obj)) do
				if type(obj[k]) == "function" and not self[k] then
					self[k] = makeFunc(self,k)
					self[k .. "_"] = makeFuncForward(self,k)
				end
			end
		end
	end
end

--Copies the functions of the object, without adding the objects.
function buddies:prepare(...)
	local args = {...}
	for i = 1, select("#", ...) do
		local obj = args[i]
		if type(obj) == "table" then
			for k,v in pairs(getmetatable(obj)) do
				if type(obj[k]) == "function" then
					self[k] = makeFunc(self,k)
					self[k .. "_"] = makeFuncForward(self,k)
				end
			end
		end
	end
end

--Removes the object. If a number is passed, the object on that position will be removed instead.
function buddies:remove(obj)
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
function buddies:call(func)
	for i=#self,1,-1 do
		func(self[i])
	end
end

function buddies:call_(func)
	for i=1,#self do
		func(self[i])
	end
end

--Has all the objects iterate through the other objects, allowing for interactivity.
--Calls the passed function, giving both objects as arguments.
function buddies:others(func)
	for i=#self,2,-1 do
		for j=i-1,1,-1 do
			if func(self[i],self[j]) then break end
		end
	end
end

function buddies:others_(func)
	for i=1,#self-1 do
		for j=i+1,#self do
			if func(self[i],self[j]) then break end
		end
	end
end

--Sets a value to all the objects.
--Will only set the value if the object already has the property, unless force is true.
function buddies:set(k,v,force)
	for i=1,#self do
		if self[i][k]~=nil or force then
			self[i][k] = v
		end
	end
end

--Removes all the objects, but keeps the functions.
function buddies:flush()
	for i=1,#self do
		self[i] = nil
	end
end

--Sorts all the objects on a property.
--If an object does not have the passed property, it will be treated as 0.
--Will automatically sort from low to high, unlesss htl (high to low) is true.
function buddies:sort(k,htl)
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

return buddies