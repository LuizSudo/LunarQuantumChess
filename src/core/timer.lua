local Timer = {}
Timer.__index = Timer

-- Create a new timer instance
function Timer:new()
	local timer = {
		timers = {}, -- Active timers
		intervals = {}, -- Repeating intervals
		tweens = {}, -- Animation tweens
		nextId = 1, -- Unique ID counter
		paused = false, -- Global pause state
		timeScale = 1.0, -- Time scaling factor
	}
	setmetatable(timer, Timer)
	return timer
end

-- Timer types
local TIMER_TYPES = {
	DELAY = "delay",
	INTERVAL = "interval",
	TWEEN = "tween",
}

-- Easing functions for tweening
local Easing = {
	linear = function(t)
		return t
	end,

	quadIn = function(t)
		return t * t
	end,
	quadOut = function(t)
		return 1 - (1 - t) * (1 - t)
	end,
	quadInOut = function(t)
		return t < 0.5 and 2 * t * t or 1 - math.pow(-2 * t + 2, 2) / 2
	end,

	cubicIn = function(t)
		return t * t * t
	end,
	cubicOut = function(t)
		return 1 - math.pow(1 - t, 3)
	end,
	cubicInOut = function(t)
		return t < 0.5 and 4 * t * t * t or 1 - math.pow(-2 * t + 2, 3) / 2
	end,

	quartIn = function(t)
		return t * t * t * t
	end,
	quartOut = function(t)
		return 1 - math.pow(1 - t, 4)
	end,
	quartInOut = function(t)
		return t < 0.5 and 8 * t * t * t * t or 1 - math.pow(-2 * t + 2, 4) / 2
	end,

	quintIn = function(t)
		return t * t * t * t * t
	end,
	quintOut = function(t)
		return 1 - math.pow(1 - t, 5)
	end,
	quintInOut = function(t)
		return t < 0.5 and 16 * t * t * t * t * t or 1 - math.pow(-2 * t + 2, 5) / 2
	end,

	sineIn = function(t)
		return 1 - math.cos((t * math.pi) / 2)
	end,
	sineOut = function(t)
		return math.sin((t * math.pi) / 2)
	end,
	sineInOut = function(t)
		return -(math.cos(math.pi * t) - 1) / 2
	end,

	expoIn = function(t)
		return t == 0 and 0 or math.pow(2, 10 * (t - 1))
	end,
	expoOut = function(t)
		return t == 1 and 1 or 1 - math.pow(2, -10 * t)
	end,
	expoInOut = function(t)
		if t == 0 then
			return 0
		end
		if t == 1 then
			return 1
		end
		if t < 0.5 then
			return math.pow(2, 20 * t - 10) / 2
		else
			return (2 - math.pow(2, -20 * t + 10)) / 2
		end
	end,

	circIn = function(t)
		return 1 - math.sqrt(1 - t * t)
	end,
	circOut = function(t)
		return math.sqrt(1 - math.pow(t - 1, 2))
	end,
	circInOut = function(t)
		return t < 0.5 and (1 - math.sqrt(1 - math.pow(2 * t, 2))) / 2
			or (math.sqrt(1 - math.pow(-2 * t + 2, 2)) + 1) / 2
	end,

	backIn = function(t)
		local c1 = 1.70158
		local c3 = c1 + 1
		return c3 * t * t * t - c1 * t * t
	end,
	backOut = function(t)
		local c1 = 1.70158
		local c3 = c1 + 1
		return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2)
	end,
	backInOut = function(t)
		local c1 = 1.70158
		local c2 = c1 * 1.525
		return t < 0.5 and (math.pow(2 * t, 2) * ((c2 + 1) * 2 * t - c2)) / 2
			or (math.pow(2 * t - 2, 2) * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2
	end,

	elasticIn = function(t)
		local c4 = (2 * math.pi) / 3
		if t == 0 then
			return 0
		end
		if t == 1 then
			return 1
		end
		return -math.pow(2, 10 * t - 10) * math.sin((t * 10 - 10.75) * c4)
	end,
	elasticOut = function(t)
		local c4 = (2 * math.pi) / 3
		if t == 0 then
			return 0
		end
		if t == 1 then
			return 1
		end
		return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1
	end,
	elasticInOut = function(t)
		local c5 = (2 * math.pi) / 4.5
		if t == 0 then
			return 0
		end
		if t == 1 then
			return 1
		end
		if t < 0.5 then
			return -(math.pow(2, 20 * t - 10) * math.sin((20 * t - 11.125) * c5)) / 2
		else
			return (math.pow(2, -20 * t + 10) * math.sin((20 * t - 11.125) * c5)) / 2 + 1
		end
	end,

	bounceIn = function(t)
		return 1 - Easing.bounceOut(1 - t)
	end,
	bounceOut = function(t)
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
	bounceInOut = function(t)
		return t < 0.5 and (1 - Easing.bounceOut(1 - 2 * t)) / 2 or (1 + Easing.bounceOut(2 * t - 1)) / 2
	end,
}

-- Add a delay timer
function Timer:delay(duration, callback, tag)
	local id = self:_generateId()
	local timer = {
		id = id,
		type = TIMER_TYPES.DELAY,
		duration = duration,
		elapsed = 0,
		callback = callback,
		tag = tag,
		active = true,
	}

	self.timers[id] = timer
	return id
end

-- Add an interval timer (repeating)
function Timer:interval(duration, callback, tag)
	local id = self:_generateId()
	local timer = {
		id = id,
		type = TIMER_TYPES.INTERVAL,
		duration = duration,
		elapsed = 0,
		callback = callback,
		tag = tag,
		active = true,
	}

	self.intervals[id] = timer
	return id
end

-- Add a tween animation
function Timer:tween(duration, target, properties, easing, callback, tag)
	local id = self:_generateId()

	-- Store initial values
	local startValues = {}
	for key, endValue in pairs(properties) do
		startValues[key] = target[key] or 0
	end

	local tween = {
		id = id,
		type = TIMER_TYPES.TWEEN,
		duration = duration,
		elapsed = 0,
		target = target,
		startValues = startValues,
		endValues = properties,
		easing = easing or "linear",
		callback = callback,
		tag = tag,
		active = true,
	}

	self.tweens[id] = tween
	return id
end

-- Update all timers
function Timer:update(dt)
	if self.paused then
		return
	end

	dt = dt * self.timeScale

	-- Update delay timers
	for id, timer in pairs(self.timers) do
		if timer.active then
			timer.elapsed = timer.elapsed + dt
			if timer.elapsed >= timer.duration then
				if timer.callback then
					timer.callback()
				end
				self.timers[id] = nil
			end
		end
	end

	-- Update interval timers
	for id, interval in pairs(self.intervals) do
		if interval.active then
			interval.elapsed = interval.elapsed + dt
			if interval.elapsed >= interval.duration then
				if interval.callback then
					interval.callback()
				end
				interval.elapsed = 0 -- Reset for next interval
			end
		end
	end

	-- Update tweens
	for id, tween in pairs(self.tweens) do
		if tween.active then
			tween.elapsed = tween.elapsed + dt
			local progress = math.min(tween.elapsed / tween.duration, 1)

			-- Apply easing
			local easingFunc = Easing[tween.easing] or Easing.linear
			local easedProgress = easingFunc(progress)

			-- Interpolate values
			for key, endValue in pairs(tween.endValues) do
				local startValue = tween.startValues[key]
				tween.target[key] = startValue + (endValue - startValue) * easedProgress
			end

			-- Check if tween is complete
			if progress >= 1 then
				if tween.callback then
					tween.callback()
				end
				self.tweens[id] = nil
			end
		end
	end
end

-- Cancel a specific timer by ID
function Timer:cancel(id)
	if self.timers[id] then
		self.timers[id] = nil
		return true
	elseif self.intervals[id] then
		self.intervals[id] = nil
		return true
	elseif self.tweens[id] then
		self.tweens[id] = nil
		return true
	end
	return false
end

-- Cancel all timers with a specific tag
function Timer:cancelTag(tag)
	local cancelled = 0

	-- Cancel delay timers
	for id, timer in pairs(self.timers) do
		if timer.tag == tag then
			self.timers[id] = nil
			cancelled = cancelled + 1
		end
	end

	-- Cancel intervals
	for id, interval in pairs(self.intervals) do
		if interval.tag == tag then
			self.intervals[id] = nil
			cancelled = cancelled + 1
		end
	end

	-- Cancel tweens
	for id, tween in pairs(self.tweens) do
		if tween.tag == tag then
			self.tweens[id] = nil
			cancelled = cancelled + 1
		end
	end

	return cancelled
end

-- Cancel all active timers
function Timer:cancelAll()
	self.timers = {}
	self.intervals = {}
	self.tweens = {}
end

-- Pause all timers
function Timer:pause()
	self.paused = true
end

-- Resume all timers
function Timer:resume()
	self.paused = false
end

-- Check if timer is paused
function Timer:isPaused()
	return self.paused
end

-- Set time scale (for slow motion effects, etc.)
function Timer:setTimeScale(scale)
	self.timeScale = scale
end

-- Get time scale
function Timer:getTimeScale()
	return self.timeScale
end

-- Get count of active timers
function Timer:getActiveCount()
	local count = 0
	for _ in pairs(self.timers) do
		count = count + 1
	end
	for _ in pairs(self.intervals) do
		count = count + 1
	end
	for _ in pairs(self.tweens) do
		count = count + 1
	end
	return count
end

-- Check if a timer exists
function Timer:exists(id)
	return self.timers[id] ~= nil or self.intervals[id] ~= nil or self.tweens[id] ~= nil
end

-- Get remaining time for a timer
function Timer:getRemaining(id)
	local timer = self.timers[id] or self.intervals[id] or self.tweens[id]
	if timer then
		return math.max(0, timer.duration - timer.elapsed)
	end
	return 0
end

-- Get progress (0-1) for a timer
function Timer:getProgress(id)
	local timer = self.timers[id] or self.intervals[id] or self.tweens[id]
	if timer then
		return math.min(1, timer.elapsed / timer.duration)
	end
	return 0
end

-- Generate unique ID
function Timer:_generateId()
	local id = self.nextId
	self.nextId = self.nextId + 1
	return id
end

-- Utility functions for common patterns

-- Chain multiple delays
function Timer:chain(delays)
	local currentIndex = 1
	local function executeNext()
		if currentIndex <= #delays then
			local delay = delays[currentIndex]
			currentIndex = currentIndex + 1
			self:delay(delay.duration, function()
				if delay.callback then
					delay.callback()
				end
				executeNext()
			end, delay.tag)
		end
	end
	executeNext()
end

-- Fade in/out helper
function Timer:fade(target, property, fromValue, toValue, duration, easing, callback)
	target[property] = fromValue
	return self:tween(duration, target, { [property] = toValue }, easing, callback)
end

-- Shake effect helper
function Timer:shake(target, intensity, duration, callback, tag)
	local originalX = target.x or 0
	local originalY = target.y or 0

	local shakeTimer = self:interval(0.016, function() -- ~60fps
		target.x = originalX + (math.random() - 0.5) * intensity * 2
		target.y = originalY + (math.random() - 0.5) * intensity * 2
	end, tag)

	return self:delay(duration, function()
		self:cancel(shakeTimer)
		target.x = originalX
		target.y = originalY
		if callback then
			callback()
		end
	end, tag)
end

-- Pulse effect helper
function Timer:pulse(target, property, baseValue, amplitude, frequency, duration, callback, tag)
	local startTime = love.timer.getTime()

	local pulseTimer = self:interval(0.016, function()
		local elapsed = love.timer.getTime() - startTime
		local phase = elapsed * frequency * 2 * math.pi
		target[property] = baseValue + math.sin(phase) * amplitude
	end, tag)

	return self:delay(duration, function()
		self:cancel(pulseTimer)
		target[property] = baseValue
		if callback then
			callback()
		end
	end, tag)
end

-- Create global timer instance
local globalTimer = Timer:new()

-- Export both the class and global instance
return {
	Timer = Timer,
	delay = function(...)
		return globalTimer:delay(...)
	end,
	interval = function(...)
		return globalTimer:interval(...)
	end,
	tween = function(...)
		return globalTimer:tween(...)
	end,
	update = function(...)
		return globalTimer:update(...)
	end,
	cancel = function(...)
		return globalTimer:cancel(...)
	end,
	cancelTag = function(...)
		return globalTimer:cancelTag(...)
	end,
	cancelAll = function(...)
		return globalTimer:cancelAll(...)
	end,
	pause = function(...)
		return globalTimer:pause(...)
	end,
	resume = function(...)
		return globalTimer:resume(...)
	end,
	isPaused = function(...)
		return globalTimer:isPaused(...)
	end,
	setTimeScale = function(...)
		return globalTimer:setTimeScale(...)
	end,
	getTimeScale = function(...)
		return globalTimer:getTimeScale(...)
	end,
	getActiveCount = function(...)
		return globalTimer:getActiveCount(...)
	end,
	exists = function(...)
		return globalTimer:exists(...)
	end,
	getRemaining = function(...)
		return globalTimer:getRemaining(...)
	end,
	getProgress = function(...)
		return globalTimer:getProgress(...)
	end,
	chain = function(...)
		return globalTimer:chain(...)
	end,
	fade = function(...)
		return globalTimer:fade(...)
	end,
	shake = function(...)
		return globalTimer:shake(...)
	end,
	pulse = function(...)
		return globalTimer:pulse(...)
	end,
	Easing = Easing,
}

