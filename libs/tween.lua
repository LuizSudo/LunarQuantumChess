-- tween.lua - Animation Tweening Library
-- Provides smooth interpolation between values over time

local tween = {}

-- Easing functions
local easing = {
	linear = function(t)
		return t
	end,

	-- Quadratic
	inQuad = function(t)
		return t * t
	end,
	outQuad = function(t)
		return 1 - (1 - t) ^ 2
	end,
	inOutQuad = function(t)
		return t < 0.5 and 2 * t * t or 1 - 2 * (1 - t) ^ 2
	end,

	-- Cubic
	inCubic = function(t)
		return t * t * t
	end,
	outCubic = function(t)
		return 1 - (1 - t) ^ 3
	end,
	inOutCubic = function(t)
		return t < 0.5 and 4 * t * t * t or 1 - 4 * (1 - t) ^ 3
	end,

	-- Quartic
	inQuart = function(t)
		return t * t * t * t
	end,
	outQuart = function(t)
		return 1 - (1 - t) ^ 4
	end,
	inOutQuart = function(t)
		return t < 0.5 and 8 * t * t * t * t or 1 - 8 * (1 - t) ^ 4
	end,

	-- Quintic
	inQuint = function(t)
		return t * t * t * t * t
	end,
	outQuint = function(t)
		return 1 - (1 - t) ^ 5
	end,
	inOutQuint = function(t)
		return t < 0.5 and 16 * t * t * t * t * t or 1 - 16 * (1 - t) ^ 5
	end,

	-- Sine
	inSine = function(t)
		return 1 - math.cos(t * math.pi / 2)
	end,
	outSine = function(t)
		return math.sin(t * math.pi / 2)
	end,
	inOutSine = function(t)
		return -(math.cos(math.pi * t) - 1) / 2
	end,

	-- Exponential
	inExpo = function(t)
		return t == 0 and 0 or 2 ^ (10 * (t - 1))
	end,
	outExpo = function(t)
		return t == 1 and 1 or 1 - 2 ^ (-10 * t)
	end,
	inOutExpo = function(t)
		if t == 0 then
			return 0
		end
		if t == 1 then
			return 1
		end
		if t < 0.5 then
			return 2 ^ (20 * t - 10) / 2
		else
			return (2 - 2 ^ (-20 * t + 10)) / 2
		end
	end,

	-- Circular
	inCirc = function(t)
		return 1 - math.sqrt(1 - t * t)
	end,
	outCirc = function(t)
		return math.sqrt(1 - (t - 1) ^ 2)
	end,
	inOutCirc = function(t)
		if t < 0.5 then
			return (1 - math.sqrt(1 - 4 * t * t)) / 2
		else
			return (math.sqrt(1 - (-2 * t + 2) ^ 2) + 1) / 2
		end
	end,

	-- Elastic
	inElastic = function(t)
		local c4 = (2 * math.pi) / 3
		if t == 0 then
			return 0
		end
		if t == 1 then
			return 1
		end
		return -2 ^ (10 * t - 10) * math.sin((t * 10 - 10.75) * c4)
	end,
	outElastic = function(t)
		local c4 = (2 * math.pi) / 3
		if t == 0 then
			return 0
		end
		if t == 1 then
			return 1
		end
		return 2 ^ (-10 * t) * math.sin((t * 10 - 0.75) * c4) + 1
	end,
	inOutElastic = function(t)
		local c5 = (2 * math.pi) / 4.5
		if t == 0 then
			return 0
		end
		if t == 1 then
			return 1
		end
		if t < 0.5 then
			return -(2 ^ (20 * t - 10) * math.sin((20 * t - 11.125) * c5)) / 2
		else
			return (2 ^ (-20 * t + 10) * math.sin((20 * t - 11.125) * c5)) / 2 + 1
		end
	end,

	-- Back
	inBack = function(t)
		local c1 = 1.70158
		local c3 = c1 + 1
		return c3 * t * t * t - c1 * t * t
	end,
	outBack = function(t)
		local c1 = 1.70158
		local c3 = c1 + 1
		return 1 + c3 * (t - 1) ^ 3 + c1 * (t - 1) ^ 2
	end,
	inOutBack = function(t)
		local c1 = 1.70158
		local c2 = c1 * 1.525
		if t < 0.5 then
			return (2 * t) ^ 2 * ((c2 + 1) * 2 * t - c2) / 2
		else
			return ((2 * t - 2) ^ 2 * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2
		end
	end,

	-- Bounce
	outBounce = function(t)
		local n1 = 7.5625
		local d1 = 2.75
		if t < 1 / d1 then
			return n1 * t * t
		elseif t < 2 / d1 then
			t = t - 1.5 / d1
			return n1 * t * t + 0.75
		elseif t < 2.5 / d1 then
			t = t - 2.25 / d1
			return n1 * t * t + 0.9375
		else
			t = t - 2.625 / d1
			return n1 * t * t + 0.984375
		end
	end,
	inBounce = function(t)
		return 1 - easing.outBounce(1 - t)
	end,
	inOutBounce = function(t)
		if t < 0.5 then
			return (1 - easing.outBounce(1 - 2 * t)) / 2
		else
			return (1 + easing.outBounce(2 * t - 1)) / 2
		end
	end,
}

-- Tween class
local Tween = {}
Tween.__index = Tween

function Tween.new(duration, target, properties, easingFunc, onComplete, onUpdate)
	local self = setmetatable({}, Tween)

	self.duration = duration or 1
	self.target = target
	self.properties = properties or {}
	self.easing = easingFunc or easing.linear
	self.onComplete = onComplete
	self.onUpdate = onUpdate

	self.time = 0
	self.isComplete = false
	self.isPaused = false
	self.startValues = {}

	-- Store initial values
	for prop, endValue in pairs(self.properties) do
		if type(self.target[prop]) == "number" then
			self.startValues[prop] = self.target[prop]
		elseif type(self.target[prop]) == "table" and self.target[prop].x and self.target[prop].y then
			-- Handle vector-like objects
			self.startValues[prop] = { x = self.target[prop].x, y = self.target[prop].y }
		end
	end

	return self
end

function Tween:update(dt)
	if self.isPaused or self.isComplete then
		return
	end

	self.time = self.time + dt
	local progress = math.min(self.time / self.duration, 1)
	local easedProgress = self.easing(progress)

	-- Update properties
	for prop, endValue in pairs(self.properties) do
		local startValue = self.startValues[prop]

		if type(startValue) == "number" then
			self.target[prop] = startValue + (endValue - startValue) * easedProgress
		elseif type(startValue) == "table" and startValue.x and startValue.y then
			-- Handle vector-like objects
			self.target[prop].x = startValue.x + (endValue.x - startValue.x) * easedProgress
			self.target[prop].y = startValue.y + (endValue.y - startValue.y) * easedProgress
		end
	end

	-- Call update callback
	if self.onUpdate then
		self.onUpdate(self.target, progress)
	end

	-- Check if complete
	if progress >= 1 then
		self.isComplete = true
		if self.onComplete then
			self.onComplete(self.target)
		end
	end
end

function Tween:pause()
	self.isPaused = true
end

function Tween:resume()
	self.isPaused = false
end

function Tween:reset()
	self.time = 0
	self.isComplete = false
	self.isPaused = false

	-- Reset to start values
	for prop, startValue in pairs(self.startValues) do
		if type(startValue) == "number" then
			self.target[prop] = startValue
		elseif type(startValue) == "table" and startValue.x and startValue.y then
			self.target[prop].x = startValue.x
			self.target[prop].y = startValue.y
		end
	end
end

-- Tween Manager
local TweenManager = {
	tweens = {},
}

function TweenManager:add(tween)
	table.insert(self.tweens, tween)
	return tween
end

function TweenManager:update(dt)
	for i = #self.tweens, 1, -1 do
		local tween = self.tweens[i]
		tween:update(dt)

		if tween.isComplete then
			table.remove(self.tweens, i)
		end
	end
end

function TweenManager:clear()
	self.tweens = {}
end

function TweenManager:pauseAll()
	for _, tween in ipairs(self.tweens) do
		tween:pause()
	end
end

function TweenManager:resumeAll()
	for _, tween in ipairs(self.tweens) do
		tween:resume()
	end
end

-- Main tween interface
function tween.new(duration, target, properties, easingFunc, onComplete, onUpdate)
	local t = Tween.new(duration, target, properties, easingFunc, onComplete, onUpdate)
	return TweenManager:add(t)
end

function tween.to(target, duration, properties, easingFunc, onComplete, onUpdate)
	return tween.new(duration, target, properties, easingFunc, onComplete, onUpdate)
end

function tween.update(dt)
	TweenManager:update(dt)
end

function tween.clear()
	TweenManager:clear()
end

function tween.pauseAll()
	TweenManager:pauseAll()
end

function tween.resumeAll()
	TweenManager:resumeAll()
end

-- Expose easing functions
tween.easing = easing

-- Convenience functions for common tweens
function tween.fadeIn(target, duration, easingFunc, onComplete)
	target.alpha = target.alpha or 0
	return tween.to(target, duration or 0.5, { alpha = 1 }, easingFunc or easing.outQuad, onComplete)
end

function tween.fadeOut(target, duration, easingFunc, onComplete)
	target.alpha = target.alpha or 1
	return tween.to(target, duration or 0.5, { alpha = 0 }, easingFunc or easing.outQuad, onComplete)
end

function tween.scaleTo(target, scale, duration, easingFunc, onComplete)
	local props = {}
	if type(scale) == "number" then
		props.scaleX = scale
		props.scaleY = scale
	else
		props.scaleX = scale.x or scale[1]
		props.scaleY = scale.y or scale[2]
	end
	return tween.to(target, duration or 0.5, props, easingFunc or easing.outBack, onComplete)
end

function tween.moveTo(target, x, y, duration, easingFunc, onComplete)
	return tween.to(target, duration or 1, { x = x, y = y }, easingFunc or easing.outQuad, onComplete)
end

return tween

