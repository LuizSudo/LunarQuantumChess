-- lume.lua - Utility Functions Library
-- A collection of utility functions for Lua game development

local lume = { _version = "2.3.0" }

-- Math utilities
function lume.clamp(x, min, max)
	return x < min and min or (x > max and max or x)
end

function lume.round(x, increment)
	if increment then
		return lume.round(x / increment) * increment
	end
	return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

function lume.sign(x)
	return x < 0 and -1 or 1
end

function lume.lerp(a, b, amount)
	return a + (b - a) * lume.clamp(amount, 0, 1)
end

function lume.smooth(a, b, amount)
	local t = lume.clamp(amount, 0, 1)
	local m = t * t * (3 - 2 * t)
	return a + (b - a) * m
end

function lume.pingpong(x)
	return 1 - math.abs(1 - x % 2)
end

function lume.distance(x1, y1, x2, y2, squared)
	local dx = x1 - x2
	local dy = y1 - y2
	local s = dx * dx + dy * dy
	return squared and s or math.sqrt(s)
end

function lume.angle(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1)
end

function lume.random(a, b)
	if not a then
		a, b = 0, 1
	end
	if not b then
		b = 0
	end
	return a + math.random() * (b - a)
end

function lume.randomchoice(t)
	return t[math.random(#t)]
end

function lume.weightedchoice(t)
	local sum = 0
	for _, v in pairs(t) do
		sum = sum + v
	end
	local rnd = lume.random(sum)
	for k, v in pairs(t) do
		if rnd < v then
			return k
		end
		rnd = rnd - v
	end
end

-- Table utilities
function lume.isarray(x)
	return type(x) == "table" and x[1] ~= nil
end

function lume.push(t, ...)
	local n = select("#", ...)
	for i = 1, n do
		t[#t + 1] = select(i, ...)
	end
	return ...
end

function lume.remove(t, x)
	local idx = lume.find(t, x)
	if idx then
		return table.remove(t, idx)
	end
end

function lume.clear(t)
	local iter = lume.isarray(t) and ipairs or pairs
	for k in iter(t) do
		t[k] = nil
	end
	return t
end

function lume.extend(t, ...)
	for i = 1, select("#", ...) do
		local x = select(i, ...)
		if x then
			for k, v in pairs(x) do
				t[k] = v
			end
		end
	end
	return t
end

function lume.shuffle(t)
	local rtn = {}
	for i = 1, #t do
		local r = math.random(i)
		if r ~= i then
			rtn[i] = rtn[r]
		end
		rtn[r] = t[i]
	end
	return rtn
end

function lume.sort(t, comp)
	local rtn = lume.clone(t)
	if comp then
		table.sort(rtn, comp)
	else
		table.sort(rtn)
	end
	return rtn
end

function lume.array(...)
	local t = {}
	for x in ... do
		t[#t + 1] = x
	end
	return t
end

function lume.each(t, fn, ...)
	local iter = lume.isarray(t) and ipairs or pairs
	if type(fn) == "string" then
		for _, v in iter(t) do
			v[fn](v, ...)
		end
	else
		for _, v in iter(t) do
			fn(v, ...)
		end
	end
	return t
end

function lume.map(t, fn)
	local iter = lume.isarray(t) and ipairs or pairs
	local rtn = {}
	for k, v in iter(t) do
		rtn[k] = fn(v)
	end
	return rtn
end

function lume.all(t, fn)
	local iter = lume.isarray(t) and ipairs or pairs
	for k, v in iter(t) do
		if not fn(v) then
			return false
		end
	end
	return true
end

function lume.any(t, fn)
	local iter = lume.isarray(t) and ipairs or pairs
	for k, v in iter(t) do
		if fn(v) then
			return true
		end
	end
	return false
end

function lume.reduce(t, fn, first)
	local started = first ~= nil
	local acc = first
	local iter = lume.isarray(t) and ipairs or pairs
	for _, v in iter(t) do
		if started then
			acc = fn(acc, v)
		else
			acc = v
			started = true
		end
	end
	return acc
end

function lume.unique(t)
	local rtn = {}
	for k in pairs(lume.invert(t)) do
		rtn[#rtn + 1] = k
	end
	return rtn
end

function lume.filter(t, fn, retainkeys)
	local iter = lume.isarray(t) and ipairs or pairs
	local rtn = {}
	if retainkeys then
		for k, v in iter(t) do
			if fn(v) then
				rtn[k] = v
			end
		end
	else
		for _, v in iter(t) do
			if fn(v) then
				rtn[#rtn + 1] = v
			end
		end
	end
	return rtn
end

function lume.reject(t, fn, retainkeys)
	local iter = lume.isarray(t) and ipairs or pairs
	local rtn = {}
	if retainkeys then
		for k, v in iter(t) do
			if not fn(v) then
				rtn[k] = v
			end
		end
	else
		for _, v in iter(t) do
			if not fn(v) then
				rtn[#rtn + 1] = v
			end
		end
	end
	return rtn
end

function lume.merge(...)
	local rtn = {}
	for i = 1, select("#", ...) do
		local t = select(i, ...)
		local iter = lume.isarray(t) and ipairs or pairs
		for k, v in iter(t) do
			rtn[k] = v
		end
	end
	return rtn
end

function lume.concat(...)
	local rtn = {}
	for i = 1, select("#", ...) do
		local t = select(i, ...)
		if t ~= nil then
			local iter = lume.isarray(t) and ipairs or pairs
			for _, v in iter(t) do
				rtn[#rtn + 1] = v
			end
		end
	end
	return rtn
end

function lume.find(t, value)
	local iter = lume.isarray(t) and ipairs or pairs
	for k, v in iter(t) do
		if v == value then
			return k
		end
	end
	return nil
end

function lume.match(t, fn)
	local iter = lume.isarray(t) and ipairs or pairs
	for k, v in iter(t) do
		if fn(v) then
			return v, k
		end
	end
	return nil
end

function lume.count(t, fn)
	local count = 0
	local iter = lume.isarray(t) and ipairs or pairs
	if fn then
		fn = type(fn) == "string" and function(a)
			return a == fn
		end or fn
		for _, v in iter(t) do
			if fn(v) then
				count = count + 1
			end
		end
	else
		if lume.isarray(t) then
			return #t
		end
		for _ in iter(t) do
			count = count + 1
		end
	end
	return count
end

function lume.slice(t, i, j)
	i = i and i or 1
	j = j and j or #t
	local rtn = {}
	for x = i < 1 and #t + i or i, j < 1 and #t + j or j do
		rtn[#rtn + 1] = t[x]
	end
	return rtn
end

function lume.first(t, n)
	if not n then
		return t[1]
	end
	return lume.slice(t, 1, n)
end

function lume.last(t, n)
	if not n then
		return t[#t]
	end
	return lume.slice(t, -n, -1)
end

function lume.invert(t)
	local rtn = {}
	for k, v in pairs(t) do
		rtn[v] = k
	end
	return rtn
end

function lume.pick(t, ...)
	local rtn = {}
	for i = 1, select("#", ...) do
		local k = select(i, ...)
		rtn[k] = t[k]
	end
	return rtn
end

function lume.keys(t)
	local rtn = {}
	local iter = lume.isarray(t) and ipairs or pairs
	for k in iter(t) do
		rtn[#rtn + 1] = k
	end
	return rtn
end

function lume.clone(t)
	local rtn = {}
	for k, v in pairs(t) do
		rtn[k] = v
	end
	return rtn
end

function lume.fn(fn, ...)
	assert(type(fn) == "function", "expected a function")
	local args = { ... }
	return function(...)
		local a = lume.concat(args, { ... })
		return fn(unpack(a))
	end
end

function lume.once(fn, ...)
	local f = lume.fn(fn, ...)
	local done = false
	return function(...)
		if done then
			return
		end
		done = true
		return f(...)
	end
end

function lume.memoize(fn)
	local cache = {}
	return function(...)
		local c = cache
		for i = 1, select("#", ...) do
			local a = select(i, ...)
			c[a] = c[a] or {}
			c = c[a]
		end
		if c[1] == nil then
			c[1] = { fn(...) }
		end
		return unpack(c[1])
	end
end

function lume.combine(...)
	local n = select("#", ...)
	if n == 0 then
		return noop
	end
	if n == 1 then
		local fn = select(1, ...)
		if not fn then
			return noop
		end
		assert(type(fn) == "function", "expected a function")
		return fn
	end
	local funcs = {}
	for i = 1, n do
		local fn = select(i, ...)
		if fn ~= nil then
			assert(type(fn) == "function", "expected a function")
			funcs[#funcs + 1] = fn
		end
	end
	return function(...)
		for _, f in ipairs(funcs) do
			f(...)
		end
	end
end

function lume.call(fn, ...)
	if fn then
		return fn(...)
	end
end

function lume.time(fn, ...)
	local start = os.clock()
	local rtn = { fn(...) }
	return (os.clock() - start), unpack(rtn)
end

function lume.lambda(str)
	return assert(loadstring("return function(_) return " .. str .. " end"))()
end

-- String utilities
function lume.serialize(x)
	local f = {
		["nil"] = tostring,
		["boolean"] = tostring,
		["number"] = tostring,
		["string"] = function(v)
			return string.format("%q", v)
		end,
		["table"] = function(t, stk)
			stk = stk or {}
			if stk[t] then
				error("circular reference")
			end
			local rtn = {}
			stk[t] = true
			for k, v in pairs(t) do
				rtn[#rtn + 1] = "[" .. lume.serialize(k, stk) .. "]=" .. lume.serialize(v, stk)
			end
			stk[t] = nil
			return "{" .. table.concat(rtn, ",") .. "}"
		end,
	}
	return f[type(x)](x)
end

function lume.deserialize(str)
	return assert(loadstring("return " .. str))()
end

function lume.split(str, sep)
	if not sep then
		return lume.array(str:gmatch("([%S]+)"))
	else
		assert(sep ~= "", "empty separator")
		local psep = sep:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
		return lume.array((str .. sep):gmatch("(.-)(" .. psep .. ")"))
	end
end

function lume.trim(str, chars)
	if not chars then
		return str:match("^[%s]*(.-)[%s]*$")
	end
	chars = chars:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
	return str:match("^[" .. chars .. "]*(.-)[" .. chars .. "]*$")
end

function lume.wordwrap(str, limit)
	limit = limit or 72
	local check
	if type(limit) == "number" then
		check = function(s)
			return #s >= limit
		end
	else
		check = limit
	end
	local rtn = {}
	local line = ""
	for word in str:gmatch("%S+") do
		local s = line .. word
		if check(s) then
			table.insert(rtn, line .. "\n")
			line = word
		else
			line = s .. " "
		end
	end
	table.insert(rtn, line)
	return table.concat(rtn):gsub("%s+$", "")
end

function lume.format(str, vars)
	if not vars then
		return str
	end
	local f = function(x)
		return tostring(vars[x] or vars[tonumber(x)] or "{" .. x .. "}")
	end
	return (str:gsub("{(.-)}", f))
end

-- Color utilities
function lume.color(str, mul)
	mul = mul or 1
	local r, g, b, a
	r, g, b = str:match("#(%x%x)(%x%x)(%x%x)")
	if r then
		r = tonumber(r, 16) / 0xff
		g = tonumber(g, 16) / 0xff
		b = tonumber(b, 16) / 0xff
		a = 1
	elseif str:match("rgba?%s*%([%d%s%.,]+%)") then
		local f = str:gmatch("[%d.]+")
		r = (f() or 0) / 0xff
		g = (f() or 0) / 0xff
		b = (f() or 0) / 0xff
		a = f() or 1
	else
		error(("bad color string '%s'"):format(str))
	end
	return r * mul, g * mul, b * mul, a * mul
end

function lume.rgba(color)
	local a = math.floor((color / 16777216) % 256)
	local r = math.floor((color / 65536) % 256)
	local g = math.floor((color / 256) % 256)
	local b = math.floor(color % 256)
	return r / 255, g / 255, b / 255, a / 255
end

-- File utilities
function lume.getdir(path)
	return path:match("(.*)[/\\]")
end

function lume.getname(path)
	return path:match("([^/\\]+)$")
end

function lume.getextension(path)
	return path:match("%.([^.]*)$")
end

function lume.uuid()
	local fn = function(x)
		local r = math.random(16) - 1
		r = (x == "x") and (r + 1) or (r % 4) + 9
		return ("0123456789abcdef"):sub(r, r)
	end
	return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

function lume.hotswap(modname)
	local oldglobal = lume.clone(_G)
	local updated = {}
	local function update(old, new)
		if updated[old] then
			return
		end
		updated[old] = true
		local oldmt, newmt = getmetatable(old), getmetatable(new)
		if oldmt and newmt then
			update(oldmt, newmt)
		end
		for k, v in pairs(new) do
			if type(v) == "table" then
				update(old[k], v)
			else
				old[k] = v
			end
		end
	end
	local err = nil
	local function onerror(e)
		for k, v in pairs(_G) do
			_G[k] = oldglobal[k]
		end
		err = lume.trim(e)
	end
	local ok, oldmod = pcall(require, modname)
	oldmod = ok and oldmod or nil
	xpcall(function()
		package.loaded[modname] = nil
		local newmod = require(modname)
		if type(oldmod) == "table" then
			update(oldmod, newmod)
		end
		for k, v in pairs(oldglobal) do
			if v ~= _G[k] and type(v) == "table" then
				update(v, _G[k])
			end
		end
	end, onerror)
	package.loaded[modname] = oldmod
	if err then
		error(err)
	end
end

function lume.ripairs(t)
	return function(t, i)
		i = i - 1
		if i > 0 then
			return i, t[i]
		end
	end, t, #t + 1
end

function lume.chain(value)
	return setmetatable({ _value = value }, {
		__index = function(t, k)
			if lume[k] then
				return function(...)
					t._value = lume[k](t._value, ...)
					return t
				end
			end
			return rawget(t, k)
		end,
		__call = function(t, ...)
			return t._value
		end,
	})
end

function lume.dostring(str)
	return assert(loadstring(str))()
end

function lume.noop() end

function lume.identity(x)
	return x
end

return lume

