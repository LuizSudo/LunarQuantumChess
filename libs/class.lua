-- Class System for Lua
-- Simple, lightweight class system for object-oriented programming
-- Based on middleclass with game development optimizations

local class = {}

-- Default metamethods to keep
local defaultMethods = {
	"__add",
	"__sub",
	"__mul",
	"__div",
	"__mod",
	"__pow",
	"__unm",
	"__eq",
	"__lt",
	"__le",
	"__tostring",
	"__call",
	"__len",
}

-- Create a new class
function class:new()
	local cls = {}
	cls.__index = cls
	cls.super = self
	cls.class = cls

	-- Copy metamethods from parent
	if self ~= class then
		for _, method in ipairs(defaultMethods) do
			cls[method] = self[method]
		end
	end

	-- Set up inheritance
	setmetatable(cls, {
		__index = self,
		__call = function(c, ...)
			local instance = setmetatable({}, c)
			if c.init then
				c.init(instance, ...)
			end
			return instance
		end,
	})

	return cls
end

-- Include mixins
function class:include(mixin)
	assert(type(mixin) == "table", "mixin must be a table")

	for name, method in pairs(mixin) do
		if name ~= "included" and name ~= "static" then
			self[name] = method
		end
	end

	-- Include static methods
	if mixin.static then
		for name, method in pairs(mixin.static) do
			self[name] = method
		end
	end

	-- Call included callback if it exists
	if type(mixin.included) == "function" then
		mixin:included(self)
	end

	return self
end

-- Check if an object is an instance of a class
function class:isInstanceOf(cls)
	return type(cls) == "table"
		and type(self) == "table"
		and (
			self.class == cls
			or (
				type(self.class) == "table"
				and type(self.class.isSubclassOf) == "function"
				and self.class:isSubclassOf(cls)
			)
		)
end

-- Check if a class is a subclass of another
function class:isSubclassOf(cls)
	if type(cls) ~= "table" then
		return false
	end

	local current = self
	while current do
		if current == cls then
			return true
		end
		current = current.super
	end
	return false
end

-- Game-specific utility methods
function class:getName()
	return self.name or "UnnamedClass"
end

function class:setName(name)
	self.name = name
	return self
end

-- Create a subclass with automatic naming
function class:extend(name)
	local subclass = self:new()
	if name then
		subclass.name = name
	end
	return subclass
end

-- Common mixins for game development

-- Mixin for objects that can be enabled/disabled
class.Toggleable = {
	init = function(self)
		self.enabled = true
	end,

	enable = function(self)
		self.enabled = true
	end,

	disable = function(self)
		self.enabled = false
	end,

	toggle = function(self)
		self.enabled = not self.enabled
	end,

	isEnabled = function(self)
		return self.enabled
	end,
}

-- Mixin for objects with position
class.Positioned = {
	init = function(self, x, y)
		self.x = x or 0
		self.y = y or 0
	end,

	setPosition = function(self, x, y)
		self.x = x
		self.y = y
	end,

	getPosition = function(self)
		return self.x, self.y
	end,

	move = function(self, dx, dy)
		self.x = self.x + dx
		self.y = self.y + dy
	end,
}

-- Mixin for objects with size
class.Sized = {
	init = function(self, width, height)
		self.width = width or 0
		self.height = height or 0
	end,

	setSize = function(self, width, height)
		self.width = width
		self.height = height
	end,

	getSize = function(self)
		return self.width, self.height
	end,

	getArea = function(self)
		return self.width * self.height
	end,
}

-- Mixin for drawable objects
class.Drawable = {
	init = function(self)
		self.visible = true
		self.opacity = 1
		self.rotation = 0
		self.scaleX = 1
		self.scaleY = 1
	end,

	show = function(self)
		self.visible = true
	end,

	hide = function(self)
		self.visible = false
	end,

	setOpacity = function(self, opacity)
		self.opacity = math.max(0, math.min(1, opacity))
	end,

	getOpacity = function(self)
		return self.opacity
	end,

	setRotation = function(self, rotation)
		self.rotation = rotation
	end,

	getRotation = function(self)
		return self.rotation
	end,

	setScale = function(self, scaleX, scaleY)
		self.scaleX = scaleX
		self.scaleY = scaleY or scaleX
	end,

	getScale = function(self)
		return self.scaleX, self.scaleY
	end,

	isVisible = function(self)
		return self.visible and self.opacity > 0
	end,
}

-- Mixin for objects with update logic
class.Updateable = {
	init = function(self)
		self.active = true
	end,

	activate = function(self)
		self.active = true
	end,

	deactivate = function(self)
		self.active = false
	end,

	isActive = function(self)
		return self.active
	end,

	-- Override this method in your class
	update = function(self, dt)
		-- Default implementation does nothing
	end,
}

-- Mixin for objects that can be destroyed
class.Destroyable = {
	init = function(self)
		self.destroyed = false
	end,

	destroy = function(self)
		if not self.destroyed then
			self.destroyed = true
			if self.onDestroy then
				self:onDestroy()
			end
		end
	end,

	isDestroyed = function(self)
		return self.destroyed
	end,
}

-- Mixin for event handling
class.EventEmitter = {
	init = function(self)
		self.listeners = {}
	end,

	on = function(self, event, callback)
		if not self.listeners[event] then
			self.listeners[event] = {}
		end
		table.insert(self.listeners[event], callback)
	end,

	off = function(self, event, callback)
		if self.listeners[event] then
			for i, listener in ipairs(self.listeners[event]) do
				if listener == callback then
					table.remove(self.listeners[event], i)
					break
				end
			end
		end
	end,

	emit = function(self, event, ...)
		if self.listeners[event] then
			for _, callback in ipairs(self.listeners[event]) do
				callback(self, ...)
			end
		end
	end,

	removeAllListeners = function(self, event)
		if event then
			self.listeners[event] = {}
		else
			self.listeners = {}
		end
	end,
}

-- Set up the class system
setmetatable(class, {
	__call = function(c, ...)
		return c:new(...)
	end,
})

return class

