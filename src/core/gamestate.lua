local GameStateManager = {}

-- Private variables
local states = {}
local stateStack = {}
local currentState = nil
local nextState = nil
local transitionTime = 0
local maxTransitionTime = 0.3
local isTransitioning = false

-- Initialize the state manager
function GameStateManager:init()
	states = {}
	stateStack = {}
	currentState = nil
	nextState = nil
	transitionTime = 0
	isTransitioning = false
	print("GameStateManager initialized")
end

-- Add a new state to the manager
function GameStateManager:addState(name, state)
	if not name or not state then
		error("State name and state object are required")
	end

	states[name] = state
	state.name = name

	-- Initialize the state if it has an init method
	if state.init then
		state:init()
	end

	print("State '" .. name .. "' added to GameStateManager")
end

-- Remove a state from the manager
function GameStateManager:removeState(name)
	if states[name] then
		local state = states[name]

		-- Clean up the state if it has a cleanup method
		if state.cleanup then
			state:cleanup()
		end

		states[name] = nil
		print("State '" .. name .. "' removed from GameStateManager")
	end
end

-- Set the current state (replaces current state)
function GameStateManager:setState(name, ...)
	if not states[name] then
		error("State '" .. name .. "' does not exist")
	end

	-- Start transition
	nextState = { name = name, args = { ... } }
	isTransitioning = true
	transitionTime = 0

	print("Transitioning to state: " .. name)
end

-- Push a state onto the stack (current state remains active underneath)
function GameStateManager:pushState(name, ...)
	if not states[name] then
		error("State '" .. name .. "' does not exist")
	end

	-- Push current state to stack
	if currentState then
		table.insert(stateStack, currentState)

		-- Pause current state if it has a pause method
		if states[currentState.name].pause then
			states[currentState.name]:pause()
		end
	end

	-- Set new state
	currentState = { name = name, args = { ... } }

	-- Enter the new state
	if states[name].enter then
		states[name]:enter(unpack(currentState.args))
	end

	print("Pushed state: " .. name)
end

-- Pop the current state and return to the previous one
function GameStateManager:popState()
	if #stateStack == 0 then
		print("Cannot pop state - stack is empty")
		return false
	end

	-- Exit current state
	if currentState and states[currentState.name].exit then
		states[currentState.name]:exit()
	end

	-- Pop previous state from stack
	currentState = table.remove(stateStack)

	-- Resume previous state if it has a resume method
	if currentState and states[currentState.name].resume then
		states[currentState.name]:resume()
	end

	print("Popped state, returned to: " .. (currentState and currentState.name or "none"))
	return true
end

-- Get the current state name
function GameStateManager:getCurrentStateName()
	return currentState and currentState.name or nil
end

-- Get the current state object
function GameStateManager:getCurrentState()
	return currentState and states[currentState.name] or nil
end

-- Check if a specific state is active
function GameStateManager:isState(name)
	return currentState and currentState.name == name
end

-- Check if currently transitioning between states
function GameStateManager:isTransitioning()
	return isTransitioning
end

-- Get transition progress (0 to 1)
function GameStateManager:getTransitionProgress()
	if not isTransitioning then
		return 1
	end
	return math.min(transitionTime / maxTransitionTime, 1)
end

-- Update the state manager
function GameStateManager:update(dt)
	-- Handle state transitions
	if isTransitioning then
		transitionTime = transitionTime + dt

		if transitionTime >= maxTransitionTime then
			-- Complete the transition
			self:completeTransition()
		end
		return
	end

	-- Update current state
	if currentState and states[currentState.name] then
		local state = states[currentState.name]
		if state.update then
			state:update(dt)
		end
	end
end

-- Complete a state transition
function GameStateManager:completeTransition()
	if not nextState then
		return
	end

	-- Exit current state
	if currentState and states[currentState.name].exit then
		states[currentState.name]:exit()
	end

	-- Clear state stack when changing states (not pushing)
	stateStack = {}

	-- Set new current state
	currentState = nextState
	nextState = nil
	isTransitioning = false
	transitionTime = 0

	-- Enter new state
	if states[currentState.name].enter then
		states[currentState.name]:enter(unpack(currentState.args))
	end

	print("Transition completed to: " .. currentState.name)
end

-- Draw the current state
function GameStateManager:draw()
	-- Draw current state
	if currentState and states[currentState.name] then
		local state = states[currentState.name]
		if state.draw then
			state:draw()
		end
	end

	-- Draw transition effect
	if isTransitioning then
		self:drawTransition()
	end
end

-- Draw transition effect
function GameStateManager:drawTransition()
	local progress = self:getTransitionProgress()
	local alpha = math.sin(progress * math.pi) * 0.5

	love.graphics.setColor(0, 0, 0, alpha)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(1, 1, 1, 1)
end

-- Input handling - pass through to current state
function GameStateManager:keypressed(key)
	if isTransitioning then
		return
	end

	if currentState and states[currentState.name] then
		local state = states[currentState.name]
		if state.keypressed then
			state:keypressed(key)
		end
	end
end

function GameStateManager:keyreleased(key)
	if isTransitioning then
		return
	end

	if currentState and states[currentState.name] then
		local state = states[currentState.name]
		if state.keyreleased then
			state:keyreleased(key)
		end
	end
end

function GameStateManager:mousepressed(x, y, button)
	if isTransitioning then
		return
	end

	if currentState and states[currentState.name] then
		local state = states[currentState.name]
		if state.mousepressed then
			state:mousepressed(x, y, button)
		end
	end
end

function GameStateManager:mousereleased(x, y, button)
	if isTransitioning then
		return
	end

	if currentState and states[currentState.name] then
		local state = states[currentState.name]
		if state.mousereleased then
			state:mousereleased(x, y, button)
		end
	end
end

function GameStateManager:mousemoved(x, y, dx, dy)
	if isTransitioning then
		return
	end

	if currentState and states[currentState.name] then
		local state = states[currentState.name]
		if state.mousemoved then
			state:mousemoved(x, y, dx, dy)
		end
	end
end

function GameStateManager:textinput(text)
	if isTransitioning then
		return
	end

	if currentState and states[currentState.name] then
		local state = states[currentState.name]
		if state.textinput then
			state:textinput(text)
		end
	end
end

-- Cleanup all states
function GameStateManager:cleanup()
	-- Exit current state
	if currentState and states[currentState.name].exit then
		states[currentState.name]:exit()
	end

	-- Cleanup all states
	for name, state in pairs(states) do
		if state.cleanup then
			state:cleanup()
		end
	end

	-- Clear everything
	states = {}
	stateStack = {}
	currentState = nil
	nextState = nil

	print("GameStateManager cleaned up")
end

return GameStateManager

