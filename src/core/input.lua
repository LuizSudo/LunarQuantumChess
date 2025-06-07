local InputManager = {}

-- Input state tracking
local keyStates = {}
local previousKeyStates = {}
local mouseStates = {}
local previousMouseStates = {}
local mousePosition = { x = 0, y = 0 }
local previousMousePosition = { x = 0, y = 0 }
local mouseDelta = { x = 0, y = 0 }

-- Key bindings
local keyBindings = {
	-- Game controls
	["up"] = { "up", "w" },
	["down"] = { "down", "s" },
	["left"] = { "left", "a" },
	["right"] = { "right", "d" },
	["select"] = { "return", "space" },
	["back"] = { "escape", "backspace" },
	["pause"] = { "p", "escape" },

	-- Chess specific
	["confirm_move"] = { "return", "space" },
	["cancel_move"] = { "escape", "c" },
	["undo"] = { "u", "z" },
	["redo"] = { "r", "y" },
	["hint"] = { "h" },
	["new_game"] = { "n" },

	-- UI navigation
	["menu"] = { "escape", "m" },
	["settings"] = { "tab", "o" },
	["fullscreen"] = { "f11", "alt+return" },

	-- Debug
	["debug"] = { "f1" },
	["console"] = { "grave", "f12" },
}

-- Mouse button names for easier reference
local mouseButtons = {
	[1] = "left",
	[2] = "right",
	[3] = "middle",
	[4] = "x1",
	[5] = "x2",
}

-- Input event callbacks
local inputCallbacks = {}

-- Initialize input manager
function InputManager:init()
	keyStates = {}
	previousKeyStates = {}
	mouseStates = {}
	previousMouseStates = {}
	mousePosition = { x = 0, y = 0 }
	previousMousePosition = { x = 0, y = 0 }
	mouseDelta = { x = 0, y = 0 }
	inputCallbacks = {}

	-- Get initial mouse position
	mousePosition.x, mousePosition.y = love.mouse.getPosition()
	previousMousePosition.x = mousePosition.x
	previousMousePosition.y = mousePosition.y

	print("InputManager initialized")
end

-- Update input states
function InputManager:update(dt)
	-- Update previous states
	previousKeyStates = self:copyTable(keyStates)
	previousMouseStates = self:copyTable(mouseStates)
	previousMousePosition.x = mousePosition.x
	previousMousePosition.y = mousePosition.y

	-- Update mouse position and delta
	mousePosition.x, mousePosition.y = love.mouse.getPosition()
	mouseDelta.x = mousePosition.x - previousMousePosition.x
	mouseDelta.y = mousePosition.y - previousMousePosition.y
end

-- Key input handling
function InputManager:keypressed(key)
	keyStates[key] = true

	-- Trigger callbacks for this key
	self:triggerKeyCallbacks(key, "pressed")

	-- Check for key bindings and trigger action callbacks
	for action, keys in pairs(keyBindings) do
		for _, boundKey in ipairs(keys) do
			if self:matchesKeyCombo(boundKey, key) then
				self:triggerActionCallbacks(action, "pressed")
				break
			end
		end
	end
end

function InputManager:keyreleased(key)
	keyStates[key] = false

	-- Trigger callbacks for this key
	self:triggerKeyCallbacks(key, "released")

	-- Check for key bindings and trigger action callbacks
	for action, keys in pairs(keyBindings) do
		for _, boundKey in ipairs(keys) do
			if self:matchesKeyCombo(boundKey, key) then
				self:triggerActionCallbacks(action, "released")
				break
			end
		end
	end
end

-- Mouse input handling
function InputManager:mousepressed(x, y, button)
	local buttonName = mouseButtons[button] or tostring(button)
	mouseStates[buttonName] = true

	-- Trigger callbacks
	self:triggerMouseCallbacks(buttonName, "pressed", x, y)
end

function InputManager:mousereleased(x, y, button)
	local buttonName = mouseButtons[button] or tostring(button)
	mouseStates[buttonName] = false

	-- Trigger callbacks
	self:triggerMouseCallbacks(buttonName, "released", x, y)
end

function InputManager:mousemoved(x, y, dx, dy)
	-- Trigger movement callbacks
	self:triggerMouseMoveCallbacks(x, y, dx, dy)
end

-- Input state queries
function InputManager:isKeyDown(key)
	return keyStates[key] == true
end

function InputManager:isKeyUp(key)
	return keyStates[key] ~= true
end

function InputManager:isKeyPressed(key)
	return keyStates[key] == true and previousKeyStates[key] ~= true
end

function InputManager:isKeyReleased(key)
	return keyStates[key] ~= true and previousKeyStates[key] == true
end

function InputManager:isMouseDown(button)
	local buttonName = mouseButtons[button] or button
	return mouseStates[buttonName] == true
end

function InputManager:isMouseUp(button)
	local buttonName = mouseButtons[button] or button
	return mouseStates[buttonName] ~= true
end

function InputManager:isMousePressed(button)
	local buttonName = mouseButtons[button] or button
	return mouseStates[buttonName] == true and previousMouseStates[buttonName] ~= true
end

function InputManager:isMouseReleased(button)
	local buttonName = mouseButtons[button] or button
	return mouseStates[buttonName] ~= true and previousMouseStates[buttonName] == true
end

-- Action-based input queries
function InputManager:isActionDown(action)
	local keys = keyBindings[action]
	if not keys then
		return false
	end

	for _, key in ipairs(keys) do
		if self:isKeyComboDown(key) then
			return true
		end
	end
	return false
end

function InputManager:isActionPressed(action)
	local keys = keyBindings[action]
	if not keys then
		return false
	end

	for _, key in ipairs(keys) do
		if self:isKeyComboPressed(key) then
			return true
		end
	end
	return false
end

function InputManager:isActionReleased(action)
	local keys = keyBindings[action]
	if not keys then
		return false
	end

	for _, key in ipairs(keys) do
		if self:isKeyComboReleased(key) then
			return true
		end
	end
	return false
end

-- Mouse position and movement
function InputManager:getMousePosition()
	return mousePosition.x, mousePosition.y
end

function InputManager:getMouseDelta()
	return mouseDelta.x, mouseDelta.y
end

function InputManager:getMouseX()
	return mousePosition.x
end

function InputManager:getMouseY()
	return mousePosition.y
end

-- Key binding management
function InputManager:addKeyBinding(action, keys)
	if type(keys) == "string" then
		keys = { keys }
	end
	keyBindings[action] = keys
end

function InputManager:removeKeyBinding(action)
	keyBindings[action] = nil
end

function InputManager:getKeyBinding(action)
	return keyBindings[action]
end

-- Callback system
function InputManager:addKeyCallback(key, eventType, callback)
	if not inputCallbacks.keys then
		inputCallbacks.keys = {}
	end
	if not inputCallbacks.keys[key] then
		inputCallbacks.keys[key] = {}
	end
	if not inputCallbacks.keys[key][eventType] then
		inputCallbacks.keys[key][eventType] = {}
	end

	table.insert(inputCallbacks.keys[key][eventType], callback)
end

function InputManager:addMouseCallback(button, eventType, callback)
	if not inputCallbacks.mouse then
		inputCallbacks.mouse = {}
	end
	if not inputCallbacks.mouse[button] then
		inputCallbacks.mouse[button] = {}
	end
	if not inputCallbacks.mouse[button][eventType] then
		inputCallbacks.mouse[button][eventType] = {}
	end

	table.insert(inputCallbacks.mouse[button][eventType], callback)
end

function InputManager:addMouseMoveCallback(callback)
	if not inputCallbacks.mousemove then
		inputCallbacks.mousemove = {}
	end
	table.insert(inputCallbacks.mousemove, callback)
end

function InputManager:addActionCallback(action, eventType, callback)
	if not inputCallbacks.actions then
		inputCallbacks.actions = {}
	end
	if not inputCallbacks.actions[action] then
		inputCallbacks.actions[action] = {}
	end
	if not inputCallbacks.actions[action][eventType] then
		inputCallbacks.actions[action][eventType] = {}
	end

	table.insert(inputCallbacks.actions[action][eventType], callback)
end

-- Helper functions for key combinations (e.g., "ctrl+s", "alt+return")
function InputManager:matchesKeyCombo(combo, pressedKey)
	local parts = {}
	for part in combo:gmatch("[^+]+") do
		table.insert(parts, part:lower())
	end

	if #parts == 1 then
		return parts[1] == pressedKey:lower()
	end

	-- Check if all modifier keys are down and the main key matches
	local mainKey = parts[#parts]
	if mainKey ~= pressedKey:lower() then
		return false
	end

	for i = 1, #parts - 1 do
		local modifier = parts[i]
		if modifier == "ctrl" and not (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
			return false
		elseif modifier == "alt" and not (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")) then
			return false
		elseif modifier == "shift" and not (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
			return false
		elseif
			modifier ~= "ctrl"
			and modifier ~= "alt"
			and modifier ~= "shift"
			and not love.keyboard.isDown(modifier)
		then
			return false
		end
	end

	return true
end

function InputManager:isKeyComboDown(combo)
	local parts = {}
	for part in combo:gmatch("[^+]+") do
		table.insert(parts, part:lower())
	end

	for _, part in ipairs(parts) do
		if part == "ctrl" then
			if not (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
				return false
			end
		elseif part == "alt" then
			if not (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")) then
				return false
			end
		elseif part == "shift" then
			if not (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
				return false
			end
		else
			if not love.keyboard.isDown(part) then
				return false
			end
		end
	end

	return true
end

function InputManager:isKeyComboPressed(combo)
	local parts = {}
	for part in combo:gmatch("[^+]+") do
		table.insert(parts, part:lower())
	end

	local mainKey = parts[#parts]
	return self:isKeyPressed(mainKey) and self:isKeyComboDown(combo)
end

function InputManager:isKeyComboReleased(combo)
	local parts = {}
	for part in combo:gmatch("[^+]+") do
		table.insert(parts, part:lower())
	end

	local mainKey = parts[#parts]
	return self:isKeyReleased(mainKey)
end

-- Callback trigger functions
function InputManager:triggerKeyCallbacks(key, eventType)
	if inputCallbacks.keys and inputCallbacks.keys[key] and inputCallbacks.keys[key][eventType] then
		for _, callback in ipairs(inputCallbacks.keys[key][eventType]) do
			callback(key)
		end
	end
end

function InputManager:triggerMouseCallbacks(button, eventType, x, y)
	if inputCallbacks.mouse and inputCallbacks.mouse[button] and inputCallbacks.mouse[button][eventType] then
		for _, callback in ipairs(inputCallbacks.mouse[button][eventType]) do
			callback(button, x, y)
		end
	end
end

function InputManager:triggerMouseMoveCallbacks(x, y, dx, dy)
	if inputCallbacks.mousemove then
		for _, callback in ipairs(inputCallbacks.mousemove) do
			callback(x, y, dx, dy)
		end
	end
end

function InputManager:triggerActionCallbacks(action, eventType)
	if inputCallbacks.actions and inputCallbacks.actions[action] and inputCallbacks.actions[action][eventType] then
		for _, callback in ipairs(inputCallbacks.actions[action][eventType]) do
			callback(action)
		end
	end
end

-- Utility functions
function InputManager:copyTable(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end

-- Clear all input states (useful for state transitions)
function InputManager:clearInput()
	keyStates = {}
	previousKeyStates = {}
	mouseStates = {}
	previousMouseStates = {}
	mouseDelta.x = 0
	mouseDelta.y = 0
end

-- Debug function to print current input state
function InputManager:debugPrint()
	print("INPUT DEBUG")
	print("Keys down:")
	for key, state in pairs(keyStates) do
		if state then
			print("  " .. key)
		end
	end
	print("Mouse buttons down:")
	for button, state in pairs(mouseStates) do
		if state then
			print("  " .. button)
		end
	end
	print("Mouse position: " .. mousePosition.x .. ", " .. mousePosition.y)
	print("Mouse delta: " .. mouseDelta.x .. ", " .. mouseDelta.y)
end

return InputManager

