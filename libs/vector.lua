-- vector.lua - Vector Math Library for LÖVE2D
-- Provides 2D vector operations for game development

local vector = {}
vector.__index = vector

-- Constructor
function vector.new(x, y)
	return setmetatable({ x = x or 0, y = y or 0 }, vector)
end

-- Alternative constructor syntax
setmetatable(vector, {
	__call = function(_, x, y)
		return vector.new(x, y)
	end,
})

-- Clone a vector
function vector:clone()
	return vector.new(self.x, self.y)
end

-- Unpack vector into x, y values
function vector:unpack()
	return self.x, self.y
end

-- String representation
function vector:__tostring()
	return string.format("(%g, %g)", self.x, self.y)
end

-- Equality check
function vector:__eq(other)
	return self.x == other.x and self.y == other.y
end

-- Addition
function vector:__add(other)
	return vector.new(self.x + other.x, self.y + other.y)
end

-- Subtraction
function vector:__sub(other)
	return vector.new(self.x - other.x, self.y - other.y)
end

-- Multiplication (scalar or vector)
function vector:__mul(scalar)
	if type(scalar) == "number" then
		return vector.new(self.x * scalar, self.y * scalar)
	else
		return vector.new(self.x * scalar.x, self.y * scalar.y)
	end
end

-- Division (scalar)
function vector:__div(scalar)
	return vector.new(self.x / scalar, self.y / scalar)
end

-- Unary minus
function vector:__unm()
	return vector.new(-self.x, -self.y)
end

-- Length/magnitude
function vector:len()
	return math.sqrt(self.x * self.x + self.y * self.y)
end

-- Squared length (faster when you don't need exact length)
function vector:len2()
	return self.x * self.x + self.y * self.y
end

-- Distance to another vector
function vector:dist(other)
	local dx = self.x - other.x
	local dy = self.y - other.y
	return math.sqrt(dx * dx + dy * dy)
end

-- Squared distance (faster)
function vector:dist2(other)
	local dx = self.x - other.x
	local dy = self.y - other.y
	return dx * dx + dy * dy
end

-- Normalize vector (unit vector)
function vector:normalized()
	local len = self:len()
	if len == 0 then
		return vector.new(0, 0)
	end
	return vector.new(self.x / len, self.y / len)
end

-- Normalize in place
function vector:normalize_inplace()
	local len = self:len()
	if len == 0 then
		return self
	end
	self.x = self.x / len
	self.y = self.y / len
	return self
end

-- Dot product
function vector:dot(other)
	return self.x * other.x + self.y * other.y
end

-- Cross product (returns scalar in 2D)
function vector:cross(other)
	return self.x * other.y - self.y * other.x
end

-- Angle of vector (in radians)
function vector:angle()
	return math.atan2(self.y, self.x)
end

-- Angle to another vector
function vector:angleTo(other)
	return math.atan2(other.y - self.y, other.x - self.x)
end

-- Rotate vector by angle (radians)
function vector:rotated(angle)
	local c = math.cos(angle)
	local s = math.sin(angle)
	return vector.new(c * self.x - s * self.y, s * self.x + c * self.y)
end

-- Rotate in place
function vector:rotate_inplace(angle)
	local c = math.cos(angle)
	local s = math.sin(angle)
	local x = c * self.x - s * self.y
	local y = s * self.x + c * self.y
	self.x = x
	self.y = y
	return self
end

-- Perpendicular vector (90 degrees counter-clockwise)
function vector:perpendicular()
	return vector.new(-self.y, self.x)
end

-- Project this vector onto another
function vector:projectOn(other)
	local dot = self:dot(other)
	local len2 = other:len2()
	if len2 == 0 then
		return vector.new(0, 0)
	end
	return other * (dot / len2)
end

-- Mirror/reflect vector across another vector
function vector:mirrorOn(other)
	local n = other:normalized()
	return self - n * (2 * self:dot(n))
end

-- Linear interpolation between two vectors
function vector:lerp(other, t)
	return self + (other - self) * t
end

-- Limit vector magnitude
function vector:trimmed(maxLen)
	local len = self:len()
	if len > maxLen then
		return self * (maxLen / len)
	end
	return self:clone()
end

-- Trim in place
function vector:trim_inplace(maxLen)
	local len = self:len()
	if len > maxLen then
		local scale = maxLen / len
		self.x = self.x * scale
		self.y = self.y * scale
	end
	return self
end

-- Check if vector is zero
function vector:isZero()
	return self.x == 0 and self.y == 0
end

-- Random vector with given length
function vector.random(len)
	local angle = math.random() * 2 * math.pi
	len = len or 1
	return vector.new(math.cos(angle) * len, math.sin(angle) * len)
end

-- Vector from angle and length
function vector.fromAngle(angle, len)
	len = len or 1
	return vector.new(math.cos(angle) * len, math.sin(angle) * len)
end

-- Common vector constants
vector.zero = vector.new(0, 0)
vector.one = vector.new(1, 1)
vector.up = vector.new(0, -1)
vector.down = vector.new(0, 1)
vector.left = vector.new(-1, 0)
vector.right = vector.new(1, 0)

return vector

