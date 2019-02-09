--
-- buddies
--
-- Copyright (c) 2019 Sheepolution

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

local buddies = {}
local func = {}
local superfunc = {}

function buddies:__index(f)
	if type(f) == "string" then
		if f:sub(f:len(),f:len()) == "_" then
			local k = f:sub(0,f:len()-1)
			self[f] = function (self,...)
				for i=1,#self do
					if self[i][k] then
						self[i][k](self[i],...)
					end
				end
			end
		else
			self[f] = function (self,...)
				for i=#self,1,-1 do
					if self[i][f] then
						self[i][f](self[i],...)
					end
				end
			end
		end
		return self[f]
	end
end

function buddies:__call(f, ...)
	self:call(f, ...)
end

function buddies.new(sb, ...)
	local t
	if sb == true then
		t =  setmetatable({
		add = superfunc.add, 
		count = superfunc.count,
		find = superfunc.find,
		table = superfunc.table,
		clone = func.clone,
		others = superfunc.others,
		others_ = superfunc.others_,
		}, buddies)
		for i,v in ipairs({...}) do
			table.insert(t, v)
		end
	else
		t =  setmetatable({
		add = func.add,
		addAt = func.addAt,
		remove = func.remove,
		removeIf = func.removeIf,
		count = func.count,
		find = func.find,
		table = func.table,
		clone = func.clone,
		call = func.call,
		call_ = func.call_,
		others = func.others,
		others_ = func.others_,
		flush = func.flush,
		set = func.set,
		sort = func.sort
		}, buddies)
		t:add(sb, ...)
	end
	return t
end

function func:add(n, ...)
	if type(n) == "number" then
		for i,v in ipairs({...}) do
			table.insert(self, n + i - 1, v)
		end
	else
		table.insert(self, n)
		for i,v in ipairs({...}) do
			table.insert(self, v)
		end
	end
end

--Removes the object. If a number is passed, the object on that position will be removed instead.
function func:remove(obj)
	if not obj then return end
	t = type(obj)

	if t == "function" then
		for i=#self,1,-1 do
			if obj(self[i]) then
				self:remove(self[i])
			end
		end
		return
	end

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
		if #self == 1 then
			self[1] = nil
		else
			for i=kill + 1,#self do
				self[i-1] = self[i]
			end

			self[#self] = nil
		end
	end
end

function func:flush()
	for i=1,#self do
		self[i] = nil
	end
end

function func:table(f)
	local t = {}
	for i=#self,1,-1 do
		if not f or f(self[i]) then
			table.insert(t, self[i])
		end
	end
	return t
end


function func:clone(f)
	return buddies.new(unpack(self:table(f)))
end

function func:count(f)
	if not func then return #self end
	local n = 0
	for i=1,#self do
		if not f or f(self[i]) then
			n = n + 1
		end
	end
	return n
end

function func:call(f, ...)
	if type(f) == "string" then
		for i=#self,1,-1 do
			if self[i][f] then
				self[i][f](self[i], ...)
			end
		end
	else
		for i=#self,1,-1 do
			f(self[i], ...)
		end
	end
end

function func:call_(f, ...)
	if type(f) == "string" then
		for i=1,#self do
			if self[i][f] then
				self[i][f](self[i], ...)
			end
		end
	else
		for i=1,#self do
			f(self[i], ...)
		end
	end
end

--Has all the objects iterate through the other objects, allowing for interactivity.
--Calls the passed function, giving both objects as arguments.
function func:others(f)
	for i=#self,2,-1 do
		for j=i-1,1,-1 do
			if f(self[i],self[j]) then break end
		end
	end
end

function func:others_(f)
	for i=1,#self-1 do
		for j=i+1,#self do
			if f(self[i],self[j]) then break end
		end
	end
end

--Sets a value to all the objects.
--Will only set the value if the object already has the property, unless force is true.
function func:set(k,v,force)
	for i=1,#self do
		if force or self[i][k]~=nil then
			self[i][k] = v
		end
	end
end

--Sorts all the objects on a property.
--If an object does not have the passed property, it will be treated as 0.
--Will automatically sort from low to high, unlesss htl (high to low) is true.
function func:sort(k,htl)
	local sorted = false
	while not sorted do
		sorted = true
		for i=1,#self-1 do
			for j=i+1,#self do
				local propA, propB
				propA = self[i][k] or 0
				propB = self[j][k] or 0
				
				if (htl and propA < propB) or (not htl and propA > propB) then
					local old = self[j]
					self[j] = self[i]
					self[i] = old
					sorted = false
				end
			end
		end
	end
end

function superfunc:add(n, n2, ...)
	if type(n) == "number" then
		if type(n2) == "number" then
			for i,v in ipairs({...}) do
				table.insert(self[n], n2 + i - 1, v)
			end
		else
			table.insert(self, n)
			for i,v in ipairs({...}) do
				table.insert(self[n], v)
			end
		end
	else
		table.insert(self, n)
		table.insert(self, n2)
		for i,v in ipairs({...}) do
			table.insert(self, v)
		end
	end
end

function superfunc:count(f)
	local n = 0
	for i,v in ipairs(self) do
		n = n + v:count(f)
	end
	return n
end

function superfunc:others(f)
	local t = self:table()
	for i=#t,2,-1 do
		for j=i-1,1,-1 do
			if f(t[i],t[j]) then break end
		end
	end
end

function superfunc:others_(f)
	local t = self:find(function () return true end)
	for i=#t,#t-1 do
		for j=i+1,#t do
			if f(t[i],t[j]) then break end
		end
	end
end

function superfunc:table(f)
	local t = {}
	for i,v in ipairs(self) do
		for j,w in ipairs(v:table(f)) do
			table.insert(t, w)
		end
	end
	return t
end

return buddies