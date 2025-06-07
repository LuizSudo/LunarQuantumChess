local Utils = {}

-- Math utilities
Utils.math = {}

-- Clamp a value between min and max
function Utils.math.clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

-- Linear interpolation between two values
function Utils.math.lerp(a, b, t)
	return a + (b - a) * t
end

-- Smooth step interpolation (smoother than linear)
function Utils.math.smoothstep(a, b, t)
	t = Utils.math.clamp((t - a) / (b - a), 0, 1)
	return t * t * (3 - 2 * t)
end

-- Smoother step interpolation (even smoother)
function Utils.math.smootherstep(a, b, t)
	t = Utils.math.clamp((t - a) / (b - a), 0, 1)
	return t * t * t * (t * (t * 6 - 15) + 10)
end

-- Round a number to specified decimal places
function Utils.math.round(num, decimals)
	local mult = 10 ^ (decimals or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- Check if a number is approximately equal to another (floating point comparison)
function Utils.math.approxEqual(a, b, epsilon)
	epsilon = epsilon or 1e-10
	return math.abs(a - b) < epsilon
end

-- Convert degrees to radians
function Utils.math.toRadians(degrees)
	return degrees * math.pi / 180
end

-- Convert radians to degrees
function Utils.math.toDegrees(radians)
	return radians * 180 / math.pi
end

-- Get distance between two points
function Utils.math.distance(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	return math.sqrt(dx * dx + dy * dy)
end

-- Get squared distance (faster when you don't need the actual distance)
function Utils.math.distanceSquared(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	return dx * dx + dy * dy
end

-- Get angle between two points
function Utils.math.angle(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1)
end

-- Normalize an angle to [-π, π]
function Utils.math.normalizeAngle(angle)
	while angle > math.pi do
		angle = angle - 2 * math.pi
	end
	while angle < -math.pi do
		angle = angle + 2 * math.pi
	end
	return angle
end

-- Get the shortest angular difference between two angles
function Utils.math.angleDifference(a1, a2)
	local diff = a2 - a1
	return Utils.math.normalizeAngle(diff)
end

-- Check if a point is inside a rectangle
function Utils.math.pointInRect(px, py, rx, ry, rw, rh)
	return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

-- Check if a point is inside a circle
function Utils.math.pointInCircle(px, py, cx, cy, radius)
	return Utils.math.distanceSquared(px, py, cx, cy) <= radius * radius
end

-- Generate a random number with normal distribution
function Utils.math.randomNormal(mean, stddev)
	mean = mean or 0
	stddev = stddev or 1

	-- Box-Muller transform
	if Utils.math._hasSpare then
		Utils.math._hasSpare = false
		return Utils.math._spare * stddev + mean
	end

	Utils.math._hasSpare = true
	local u = 0
	local v = 0
	local s = 0

	repeat
		u = math.random() * 2 - 1
		v = math.random() * 2 - 1
		s = u * u + v * v
	until s ~= 0 and s < 1

	s = math.sqrt(-2 * math.log(s) / s)
	Utils.math._spare = v * s
	return u * s * stddev + mean
end

-- String utilities
Utils.string = {}

-- Split a string by delimiter
function Utils.string.split(str, delimiter)
	delimiter = delimiter or "%s"
	local result = {}
	for match in str:gmatch("([^" .. delimiter .. "]+)") do
		table.insert(result, match)
	end
	return result
end

-- Trim whitespace from string
function Utils.string.trim(str)
	return str:match("^%s*(.-)%s*$")
end

-- Check if string starts with prefix
function Utils.string.startsWith(str, prefix)
	return str:sub(1, #prefix) == prefix
end

-- Check if string ends with suffix
function Utils.string.endsWith(str, suffix)
	return str:sub(-#suffix) == suffix
end

-- Capitalize first letter
function Utils.string.capitalize(str)
	return str:sub(1, 1):upper() .. str:sub(2):lower()
end

-- Convert string to title case
function Utils.string.titleCase(str)
	return str:gsub("(%w)([%w]*)", function(first, rest)
		return first:upper() .. rest:lower()
	end)
end

-- Count occurrences of substring
function Utils.string.count(str, substring)
	local count = 0
	local start = 1
	while true do
		local pos = str:find(substring, start, true)
		if not pos then
			break
		end
		count = count + 1
		start = pos + 1
	end
	return count
end

-- Pad string to specified length
function Utils.string.pad(str, length, char, left)
	char = char or " "
	local padding = string.rep(char, math.max(0, length - #str))
	if left then
		return padding .. str
	else
		return str .. padding
	end
end

-- Table utilities
Utils.table = {}

-- Deep copy a table
function Utils.table.deepCopy(orig)
	local copy
	if type(orig) == "table" then
		copy = {}
		for key, value in next, orig, nil do
			copy[Utils.table.deepCopy(key)] = Utils.table.deepCopy(value)
		end
		setmetatable(copy, Utils.table.deepCopy(getmetatable(orig)))
	else
		copy = orig
	end
	return copy
end

-- Shallow copy a table
function Utils.table.shallowCopy(orig)
	local copy = {}
	for key, value in pairs(orig) do
		copy[key] = value
	end
	return copy
end

-- Merge tables (shallow merge)
function Utils.table.merge(t1, t2)
	local result = Utils.table.shallowCopy(t1)
	for key, value in pairs(t2) do
		result[key] = value
	end
	return result
end

-- Get table length (works with non-sequential tables)
function Utils.table.count(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

-- Check if table is empty
function Utils.table.isEmpty(t)
	return next(t) == nil
end

-- Check if table contains value
function Utils.table.contains(t, value)
	for _, v in pairs(t) do
		if v == value then
			return true
		end
	end
	return false
end

-- Find key for value in table
function Utils.table.findKey(t, value)
	for k, v in pairs(t) do
		if v == value then
			return k
		end
	end
	return nil
end

-- Get random element from table
function Utils.table.random(t)
	local keys = {}
	for k in pairs(t) do
		table.insert(keys, k)
	end
	if #keys == 0 then
		return nil
	end
	local randomKey = keys[math.random(#keys)]
	return t[randomKey], randomKey
end

-- Filter table elements
function Utils.table.filter(t, predicate)
	local result = {}
	for k, v in pairs(t) do
		if predicate(v, k) then
			result[k] = v
		end
	end
	return result
end

-- Map table elements
function Utils.table.map(t, func)
	local result = {}
	for k, v in pairs(t) do
		result[k] = func(v, k)
	end
	return result
end

-- Reduce table to single value
function Utils.table.reduce(t, func, initial)
	local result = initial
	for k, v in pairs(t) do
		result = func(result, v, k)
	end
	return result
end

-- Get table keys as array
function Utils.table.keys(t)
	local keys = {}
	for k in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end

-- Get table values as array
function Utils.table.values(t)
	local values = {}
	for _, v in pairs(t) do
		table.insert(values, v)
	end
	return values
end

-- Reverse an array
function Utils.table.reverse(t)
	local result = {}
	for i = #t, 1, -1 do
		table.insert(result, t[i])
	end
	return result
end

-- Shuffle an array
function Utils.table.shuffle(t)
	local result = Utils.table.shallowCopy(t)
	for i = #result, 2, -1 do
		local j = math.random(i)
		result[i], result[j] = result[j], result[i]
	end
	return result
end

-- Color utilities
Utils.color = {}

-- Convert HSV to RGB
function Utils.color.hsvToRgb(h, s, v, a)
	local r, g, b
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)

	local remainder = i % 6
	if remainder == 0 then
		r, g, b = v, t, p
	elseif remainder == 1 then
		r, g, b = q, v, p
	elseif remainder == 2 then
		r, g, b = p, v, t
	elseif remainder == 3 then
		r, g, b = p, q, v
	elseif remainder == 4 then
		r, g, b = t, p, v
	elseif remainder == 5 then
		r, g, b = v, p, q
	end

	return r, g, b, a or 1
end

-- Convert RGB to HSV
function Utils.color.rgbToHsv(r, g, b, a)
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local delta = max - min

	local h, s, v = 0, 0, max

	if max ~= 0 then
		s = delta / max
	end

	if delta ~= 0 then
		if max == r then
			h = (g - b) / delta
			if g < b then
				h = h + 6
			end
		elseif max == g then
			h = (b - r) / delta + 2
		elseif max == b then
			h = (r - g) / delta + 4
		end
		h = h / 6
	end

	return h, s, v, a or 1
end

-- Lerp between two colors
function Utils.color.lerp(r1, g1, b1, a1, r2, g2, b2, a2, t)
	return Utils.math.lerp(r1, r2, t),
		Utils.math.lerp(g1, g2, t),
		Utils.math.lerp(b1, b2, t),
		Utils.math.lerp(a1 or 1, a2 or 1, t)
end

-- Convert hex color to RGB
function Utils.color.hexToRgb(hex)
	hex = hex:gsub("#", "")
	if #hex == 3 then
		hex = hex:gsub("(.)", "%1%1")
	end

	local r = tonumber(hex:sub(1, 2), 16) / 255
	local g = tonumber(hex:sub(3, 4), 16) / 255
	local b = tonumber(hex:sub(5, 6), 16) / 255

	return r, g, b, 1
end

-- Convert RGB to hex
function Utils.color.rgbToHex(r, g, b)
	return string.format("#%02X%02X%02X", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
end

-- File utilities
Utils.file = {}

-- Check if file exists
function Utils.file.exists(path)
	local info = love.filesystem.getInfo(path)
	return info ~= nil and info.type == "file"
end

-- Check if directory exists
function Utils.file.dirExists(path)
	local info = love.filesystem.getInfo(path)
	return info ~= nil and info.type == "directory"
end

-- Get file extension
function Utils.file.getExtension(filename)
	return filename:match("%.([^%.]+)$")
end

-- Get filename without extension
function Utils.file.getBasename(filename)
	return filename:match("(.+)%.[^%.]*$") or filename
end

-- Get directory from path
function Utils.file.getDirectory(path)
	return path:match("(.+)/[^/]*$") or ""
end

-- Join path components
function Utils.file.join(...)
	local parts = { ... }
	return table.concat(parts, "/"):gsub("//+", "/")
end

-- Save data to file (JSON format)
function Utils.file.saveData(filename, data)
	local json = require("lib.json")
	local success, result = pcall(function()
		local jsonString = json.encode(data)
		return love.filesystem.write(filename, jsonString)
	end)
	return success and result
end

-- Load data from file (JSON format)
function Utils.file.loadData(filename)
	if not Utils.file.exists(filename) then
		return nil
	end

	local json = require("lib.json")
	local success, result = pcall(function()
		local content = love.filesystem.read(filename)
		return json.decode(content)
	end)

	if success then
		return result
	else
		return nil
	end
end

-- Debug utilities
Utils.debug = {}

-- Print table contents (for debugging)
function Utils.debug.printTable(t, indent)
	indent = indent or 0
	local prefix = string.rep("  ", indent)

	if type(t) ~= "table" then
		print(prefix .. tostring(t))
		return
	end

	for k, v in pairs(t) do
		if type(v) == "table" then
			print(prefix .. tostring(k) .. ":")
			Utils.debug.printTable(v, indent + 1)
		else
			print(prefix .. tostring(k) .. ": " .. tostring(v))
		end
	end
end

-- Measure execution time of a function
function Utils.debug.benchmark(func, iterations)
	iterations = iterations or 1
	local startTime = love.timer.getTime()

	for i = 1, iterations do
		func()
	end

	local endTime = love.timer.getTime()
	local totalTime = endTime - startTime
	local avgTime = totalTime / iterations

	return totalTime, avgTime
end

-- Memory usage tracking
function Utils.debug.getMemoryUsage()
	return collectgarbage("count")
end

-- Force garbage collection and return memory freed
function Utils.debug.cleanMemory()
	local before = collectgarbage("count")
	collectgarbage("collect")
	local after = collectgarbage("count")
	return before - after
end

-- Chess-specific utilities
Utils.chess = {}

-- Convert chess notation to board coordinates
function Utils.chess.notationToCoords(notation)
	if #notation ~= 2 then
		return nil
	end

	local file = notation:sub(1, 1):lower()
	local rank = tonumber(notation:sub(2, 2))

	if file < "a" or file > "h" or rank < 1 or rank > 8 then
		return nil
	end

	local x = string.byte(file) - string.byte("a") + 1
	local y = 9 - rank -- Flip because chess boards are numbered from bottom

	return x, y
end

-- Convert board coordinates to chess notation
function Utils.chess.coordsToNotation(x, y)
	if x < 1 or x > 8 or y < 1 or y > 8 then
		return nil
	end

	local file = string.char(string.byte("a") + x - 1)
	local rank = 9 - y -- Flip because chess boards are numbered from bottom

	return file .. rank
end

-- Check if coordinates are valid on chess board
function Utils.chess.isValidCoord(x, y)
	return x >= 1 and x <= 8 and y >= 1 and y <= 8
end

-- Get opposite color
function Utils.chess.oppositeColor(color)
	return color == "white" and "black" or "white"
end

-- Random utilities
Utils.random = {}

-- Seed random number generator
function Utils.random.seed(seed)
	math.randomseed(seed or os.time())
end

-- Random float between min and max
function Utils.random.float(min, max)
	return min + math.random() * (max - min)
end

-- Random integer between min and max (inclusive)
function Utils.random.int(min, max)
	return math.random(min, max)
end

-- Random boolean with optional probability
function Utils.random.bool(probability)
	probability = probability or 0.5
	return math.random() < probability
end

-- Random choice from array
function Utils.random.choice(array)
	if #array == 0 then
		return nil
	end
	return array[math.random(#array)]
end

-- Weighted random choice
function Utils.random.weightedChoice(choices, weights)
	local totalWeight = 0
	for i = 1, #weights do
		totalWeight = totalWeight + weights[i]
	end

	local random = math.random() * totalWeight
	local currentWeight = 0

	for i = 1, #choices do
		currentWeight = currentWeight + weights[i]
		if random <= currentWeight then
			return choices[i]
		end
	end

	return choices[#choices] -- Fallback
end

-- UUID generation
function Utils.random.uuid()
	local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	return string.gsub(template, "[xy]", function(c)
		local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
		return string.format("%x", v)
	end)
end

return Utils

