--- UI prompts and prompt groups

-- Base class from which other classes are derived
local Class = {}

function Class:new()
	self.__index = self
	return setmetatable({}, self)
end

--- System for automatically handling and cleaning up prompts and groups.
-- @table UipromptManager
UipromptManager = Class:new()
UipromptManager.prompts = {}
UipromptManager.groups = {}

-- Register a prompt
function UipromptManager:addPrompt(prompt)
	self.prompts[prompt] = true
end

-- Remove a prompt
function UipromptManager:removePrompt(object)
	if self.prompts[prompt] then
		self.prompts[prompt] = nil
	end
end

-- Register a group
function UipromptManager:addGroup(group)
	self.groups[group] = true
end

-- Remove a group
function UipromptManager:removeGroup(group)
	if self.groups[group] then
		self.groups[group] = nil
	end
end

--- Start event handling thread
-- @usage UipromptManager:startEventThread()
function UipromptManager:startEventThread()
	CreateThread(function()
		while true do
			for group, _ in pairs(self.groups) do
				if group:isActive() then
					group:setActiveThisFrame()
					group:handleEvents()
				end
			end

			for prompt, _ in pairs(self.prompts) do
				prompt:handleEvents()
			end

			Wait(0)
		end
	end)
end

-- Clean up all registered prompts and groups
function UipromptManager:delete()
	for group, _ in pairs(UipromptManager.groups) do
		group:delete()
	end

	for prompt, _ in pairs(UipromptManager.prompts) do
		prompt:delete()
	end
end

-- Automatically clean up when resource stops
AddEventHandler("onResourceStop", function(resourceName)
	if GetCurrentResourceName() == resourceName then
		UipromptManager:delete()
	end
end)

--- A single UI prompt
-- @table Uiprompt
Uiprompt = Class:new()

--- Create a new UI prompt
-- @param controls An individual control or a table of controls associated with the prompt.
-- @param text The text label of the prompt.
-- @param enabled Whether the prompt is enabled. Default is true.
-- @param group An optional group ID to add the prompt to a prompt group.
-- @return A new Uiprompt object
-- @usage local prompt = Uiprompt:new(`INPUT_DYNAMIC_SCENARIO`, "Use")
function Uiprompt:new(controls, text, enabled, group)
	local self = getmetatable(self).new(self)

	self.handle = PromptRegisterBegin()

	if type(controls) ~= "table" then
		self.controls = {controls}
	else
		self.controls = controls
	end

	for _, control in ipairs(self.controls) do
		if type(control) == "string" then
			PromptSetControlAction(self.handle, GetHashKey(control))
		else
			PromptSetControlAction(self.handle, control)
		end
	end

	self:setText(text)

	if group then
		PromptSetGroup(self.handle, group)
	end

	if enabled == false then
		self:setEnabled(false)
		self:setVisible(false)
	end

	PromptRegisterEnd(self.handle)

	if not group then
		UipromptRegister:addPrompt(self)
	end

	return self
end

--- Get whether the prompt is active.
-- @return true or false
-- @usage if prompt:isActive() then ... end
function Uiprompt:isActive()
	return PromptIsActive(self.handle)
end

--- Get whether any control action is active
-- @return true or false
-- @usage if prompt:isControlActionActive() then ... end
function Uiprompt:isControlActionActive()
	for _, control in ipairs(self.controls) do
		if PromptIsControlActionActive(control) then
			return true
		end
	end

	return false
end

--- Get whether the prompt is enabled.
-- @return true or false
-- @usage if prompt:isEnabled() then ... end
function Uiprompt:isEnabled()
	return PromptIsEnabled(self.handle)
end

--- Enable or disable the prompt.
-- @param toggle true to enable, false to disable
-- @usage prompt:setEnabled(true)
function Uiprompt:setEnabled(toggle)
	PromptSetEnabled(self.handle, toggle)
	return self
end

--- Toggle visibility of the prompt.
-- @param toggle true to show, false to hide
function Uiprompt:setVisible(toggle)
	PromptSetVisible(self.handle, toggle)
	return self
end

--- Check if prompt was just pressed.
-- @return true or false
-- @usage if prompt:isJustPressed() then ... end
function Uiprompt:isJustPressed()
	return PromptIsJustPressed(self.handle)
end

--- Check if prompt was just released.
-- @return true or false
-- @usage if prompt:isJustReleased() then ... end
function Uiprompt:isJustReleased()
	return PromptIsJustReleased(self.handle)
end

--- Check if prompt is pressed.
-- @return true or false
-- @usage if prompt:isPressed() then ... end
function Uiprompt:isPressed()
	return PromptIsPressed(self.handle)
end

--- Check if prompt is released.
-- @return true or false
-- @usage if prompt:isReleased() then ... end
function Uiprompt:isReleased()
	return PromptIsReleased(self.handle)
end

--- Check if prompt is valid.
-- @return true or false
-- @usage if prompt:isValid() then ... end
function Uiprompt:isValid()
	return PromptIsValid(self.handle)
end

--- Get whether this prompt has hold mode enabled.
-- @return true or false
function Uiprompt:hasHoldMode()
	return PromptHasHoldMode(self.handle)
end

--- Toggle hold mode on the prompt.
-- @param toggle true to enable hold mode, false to disable
function Uiprompt:setHoldMode(toggle)
	PromptSetHoldMode(self.handle, toggle)
	return self
end

--- Check if the prompt's hold mode bar is filling up.
-- @return true or false
function Uiprompt:isHoldModeRunning()
	return PromptIsHoldModeRunning(self.handle)
end

--- Check if the prompt's hold mode bar is filled.
-- @return true or false
function Uiprompt:hasHoldModeCompleted()
	return PromptHasHoldModeCompleted(self.handle)
end

--- Get the text label of the prompt.
-- @return The text label of the UI prompt
-- @usage local text = prompt:getText()
function Uiprompt:getText()
	return self.text
end

--- Set the text label of the prompt.
-- @param text The new text for the UI prompt label
-- @usage prompt:setText("Hold")
function Uiprompt:setText(text)
	local str = CreateVarString(10, "LITERAL_STRING", text)
	PromptSetText(self.handle, str)
	self.text = text
	return self
end

-- Perform a control check for every control associated with the prompt.
function Uiprompt:doForEachControl(func, padIndex)
	for _, control in ipairs(self.controls) do
		if func(padIndex, control) then
			return true
		end
	end

	return false
end

--- Check if any of the controls associated with the prompt are pressed.
-- @param padIndex
-- @return true or false
-- @usage if prompt:isControlPressed(0) then ... end
function Uiprompt:isControlPressed(padIndex)
	return self:doForEachControl(IsControlPressed, padIndex)
end

--- Check if any of the controls associated with the prompt are released.
-- @param padIndex
-- @return true or false
-- @usage if prompt:isControlReleased(0) then ... end
function Uiprompt:isControlReleased(padIndex)
	return self:doForEachControl(IsControlReleased, padIndex)
end

--- Check if any of the controls associated with the prompt were just pressed.
-- @param padIndex
-- @return true or false
-- @usage if prompt:isControlJustPressed(0) then ... end
function Uiprompt:isControlJustPressed(padIndex)
	return self:doForEachControl(IsControlJustPressed, padIndex)
end

--- Check if any of the controls associated with the prompt were just released.
-- @param padIndex
-- @return true or false
-- @usage if prompt:isControlJustReleased(0) then ... end
function Uiprompt:isControlJustReleased(padIndex)
	return self:doForEachControl(IsControlJustReleased, padIndex)
end

--- Set a handler that is executed when the prompt was just pressed.
-- @param handler Handler function
-- @usage prompt:setOnJustPressed(function(prompt, data) ... end)
function Uiprompt:setOnJustPressed(handler)
	self.onJustPressed = handler
	return self
end

--- Set a handler that is executed when the prompt was just released.
-- @param handler Handler function
-- @usage prompt:setOnJustReleased(function(prompt, data) ... end)
function Uiprompt:setOnJustReleased(handler)
	self.onJustReleased = handler
	return self
end

--- Set a handler that is executed when the prompt is pressed.
-- @param handler Handler function
-- @usage prompt:setOnPressed(function(prompt, data) ... end)
function Uiprompt:setOnPressed(handler)
	self.onPressed = handler
	return self
end

--- Set a handler that is executed when the prompt is released.
-- @param handler Handler function
-- @usage prompt:setOnReleased(function(prompt, data) ... end)
function Uiprompt:setOnReleased(handler)
	self.onReleased = handler
	return self
end

--- Set a handler that is executed when any control associated with the prompt is pressed.
-- @param handler Handler function
-- @usage prompt:setOnControlPressed(function(prompt, data) ... end)
function Uiprompt:setOnControlPressed(handler)
	self.onControlPressed = handler
	return self
end

--- Set a handler that is executed when any control associated with the prompt is released.
-- @param handler Handler function
-- @usage prompt:setOnControlReleased(function(prompt, data) ... end)
function Uiprompt:setOnControlReleased(handler)
	self.onControlReleased = handler
	return self
end

--- Set a handler that is executed when any control associated with the prompt was just pressed.
-- @param handler Handler function
-- @usage prompt:setOnControlJustPressed(function(prompt, data) ... end)
function Uiprompt:setOnControlJustPressed(handler)
	self.onControlJustPressed = handler
	return self
end

--- Set a handler that is executed when any control associated with the prompt was just released.
-- @param handler Handler function
-- @usage prompt:setOnControlJustReleased(function(prompt, data) ... end)
function Uiprompt:setOnControlJustReleased(handler)
	self.onControlJustReleased = handler
	return self
end

--- Set a handler that is executed when the prompt's hold mode is running.
-- @param handler Handler function
-- @usage prompt:setOnHoldModeRunning(function(prompt, data) ... end)
function Uiprompt:setOnHoldModeRunning(handler)
	self.onHoldModeRunning = handler
	return self
end

--- Set a handler that is executed when the prompt's hold mode has completed.
-- @param handler Handler function
-- @usage prompt:setOnHoldModeCompleted(function(prompt, data) ... end)
function Uiprompt:setOnHoldModeCompleted(handler)
	self.onHoldModeCompleted = handler
	return self
end

--- Handle events for this prompt. Should be called every frame.
-- @param data Extra data passed to the handlers for any events
-- @usage prompt:handleEvents()
function Uiprompt:handleEvents(data)
	if self.onJustPressed and self:isJustPressed() then
		self:onJustPressed(data)
	end

	if self.onJustReleased and self:isJustReleased() then
		self:onJustReleased(data)
	end

	if self.onPressed and self:isPressed() then
		self:onPressed(data)
	end

	if self.onReleased and self:isReleased() then
		self:onReleased(data)
	end

	if self.onHoldModeRunning and self:isHoldModeRunning() then
		self:onHoldModeRunning(data)
	end

	if self.onHoldModeCompleted and self:hasHoldModeCompleted() then
		self:onHoldModeCompleted(data)
	end

	if self:isEnabled() then
		if self.onControlPressed and self:isControlPressed(0) then
			self:onControlPressed(data)
		end

		if self.onControlReleased and self:isControlReleased(0) then
			self:onControlReleased(data)
		end

		if self.onControlJustPressed and self:isControlJustPressed(0) then
			self:onControlJustPressed(data)
		end

		if self.onControlJustReleased and self:isControlJustReleased(0) then
			self:onControlJustReleased(data)
		end
	end
end

--- Clean up the prompt
-- @usage prompt:delete()
function Uiprompt:delete()
	UipromptRegister:removePrompt(self)

	PromptDelete(self.handle)
end

--- A group of UI prompts
-- @table UipromptGroup
UipromptGroup = Class:new()

--- Create a new UI prompt group
-- @param text The text label for the prompt group
-- @param active Whether the group is active. Default is false.
-- @return A new UipromptGroup object
-- @usage local promptGroup = UipromptGroup:new("Interact")
function UipromptGroup:new(text, active)
	local self = getmetatable(self).new(self)

	self.groupId = GetRandomIntInRange(0, 0xFFFFFF)
	self.text = text
	self.prompts = {}
	self.active = active == true

	UipromptRegister:addGroup(self)

	return self
end

--- Display the prompt group. This must be called every frame.
-- @usage promptGroup:setActiveThisFrame()
function UipromptGroup:setActiveThisFrame()
	local str = CreateVarString(10, "LITERAL_STRING", self.text)
	PromptSetActiveGroupThisFrame(self.groupId, str)
	return self
end

--- Get the text label of the prompt group
-- @return The text label of the prompt group
-- @usage local text = promptGroup:getText()
function UipromptGroup:getText()
	return self.text
end

--- Set the text label of the prompt group
-- @param text The new label
-- @usage promptGroup:setText("Food")
function UipromptGroup:setText(text)
	self.text = text
	return self
end

--- Get a table of the individual prompts in the prompt group
-- @return A table of Uiprompt objects
-- @usage for _, prompt in ipairs(promptGroup:getPrompts()) do ... end
function UipromptGroup:getPrompts()
	return self.prompts
end

--- Add a new prompt to the prompt group
-- @param controls An individual control or table of controls associated with the prompt.
-- @param text The text label of the prompt.
-- @param enabled Whether the prompt is enabled. Default is true.
-- @return The new Uiprompt object added to the group
-- @usage local prompt = promptGroup:addPrompt(`INPUT_DYNAMIC_SCENARIO`, "Use")
function UipromptGroup:addPrompt(controls, text, enabled)
	local prompt = Uiprompt:new(controls, text, enabled, self.groupId)
	table.insert(self.prompts, prompt)
	return prompt
end

-- Do something for every prompt in the group
function UipromptGroup:doForEachPrompt(func, args, callback)
	local result = false

	for _, prompt in ipairs(self.prompts) do
		if func(prompt, table.unpack(args)) then
			result = true

			if callback then
				callback(prompt)
			else
				break
			end
		end
	end

	return result
end

--- Check if any prompts in the group were just pressed.
-- @param callback An optional callback function that is executed for each prompt that was just pressed.
-- @return true or false
-- @usage if promptGroup:isJustPressed() then ... end
-- @usage promptGroup:isJustPressed(function(prompt) ... end)
function UipromptGroup:isJustPressed(callback)
	return self:doForEachPrompt(Uiprompt.isJustPressed, {}, callback)
end

--- Check if any prompts in the group were just released.
-- @param callback An optional callback function that is executed for each prompt that was just released.
-- @return true or false
-- @usage if promptGroup:isJustReleased() then ... end
-- @usage promptGroup:isJustReleased(function(prompt) ... end)
function UipromptGroup:isJustReleased(callback)
	return self:doForEachPrompt(Uiprompt.isJustReleased, {}, callback)
end

--- Check if any prompts in the group are pressed.
-- @param callback An optional callback function that is executed for each prompt that is pressed.
-- @return true or false
-- @usage if promptGroup:isPressed() then ... end
-- @usage promptGroup:isPressed(function(prompt) ... end)
function UipromptGroup:isPressed(callback)
	return self:doForEachPrompt(Uiprompt.isPressed, {}, callback)
end

--- Check if any prompts in the group are released.
-- @param callback An optional callback function that is executed for each prompt that is released.
-- @return true or false
-- @usage if promptGroup:isReleased() then ... end
-- @usage promptGroup:isReleased(function(prompt) ... end)
function UipromptGroup:isReleased(callback)
	return self:doForEachPrompt(Uiprompt.isReleased, {}, callback)
end

--- Check if any of the controls of any of the prompts in the group are pressed
-- @param padIndex
-- @param callback An optional callback function that is executed for each prompt that has a control pressed.
-- @return true or false
-- @usage if promptGroup:isControlPressed(0) then ... end
-- @usage promptGroup:isControlPressed(0, function(prompt) ... end)
function UipromptGroup:isControlPressed(padIndex, callback)
	return self:doForEachPrompt(Uiprompt.doForEachControl, {IsControlPressed, padIndex}, callback)
end

--- Check if any of the controls of any of the prompts in the group are released
-- @param padIndex
-- @param callback An optional callback function that is executed for each prompt that has a control released.
-- @return true or false
-- @usage if promptGroup:isControlReleased(0) then ... end
-- @usage promptGroup:isControlReleased(0, function(prompt) ... end)
function UipromptGroup:isControlReleased(padIndex, callback)
	return self:doForEachPrompt(Uiprompt.doForEachControl, {IsControlReleased, padIndex}, callback)
end

--- Check if any of the controls of any of the prompts in the group were just pressed
-- @param padIndex
-- @param callback An optional callback that is executed for each prompt that has a control that was just pressed.
-- @return true or false
-- @usage if promptGroup:isControlJustPressed(0) then ... end
-- @usage if promptGroup:isControlJustPressed(0, function(prompt) ... end)
function UipromptGroup:isControlJustPressed(padIndex, callback)
	return self:doForEachPrompt(Uiprompt.doForEachControl, {IsControlJustPressed, padIndex}, callback)
end

--- Check if any of the controls of any of the prompts in the group were just released
-- @param padIndex
-- @param callback An optional callback that is executed for each prompt that has a control that was just released.
-- @return true or false
-- @usage if promptGroup:isControlJustReleased(0) then ... end
-- @usage promptGroup:isControlJustReleased(0, function(prompt) ... end)
function UipromptGroup:isControlJustReleased(padIndex, callback)
	return self:doForEachPrompt(Uiprompt.doForEachControl, {IsControlJustReleased, padIndex}, callback)
end

--- Check if the hold mode of any of the prompts in the group is running.
-- @param callback An optional callback function that is executed for each prompt who's hold mode is running.
-- @return true or false
-- @usage if promptGroup:isHoldModeRunning() then ... end
-- @usage promptGroup:isHoldModeRunning(function(prompt) ... end)
function UipromptGroup:isHoldModeRunning(callback)
	return self:doForEachPrompt(Uiprompt.isHoldModeRunning, {}, callback)
end

--- Check if the hold mode of any of the prompts in the group has completed.
-- @param callback An optional callback function that is executed for each prompt who's hold mode has completed.
-- @return true or false
-- @usage if promptGroup:hasHoldModeCompleted() then ... end
-- @usage promptGroup:hasHoldModeCompleted(function(prompt) ... end)
function UipromptGroup:hasHoldModeCompleted(callback)
	return self:doForEachPrompt(Uiprompt.hasHoldModeCompleted, {}, callback)
end

--- Set a handler that is executed when any prompt in the group was just pressed.
-- @param handler Handler function
-- @usage promptGroup:setOnJustPressed(function(prompt, data) ... end)
function UipromptGroup:setOnJustPressed(handler)
	self.onJustPressed = handler
	return self
end

--- Set a handler that is executed when any prompt in the group was just released.
-- @param handler Handler function
-- @usage promptGroup:setOnJustReleased(function(prompt, data) ... end)
function UipromptGroup:setOnJustReleased(handler)
	self.onJustReleased = handler
	return self
end

--- Set a handler that is executed when any prompt in the group is pressed.
-- @param handler Handler function
-- @usage promptGroup:setOnPressed(function(prompt, data) ... end)
function UipromptGroup:setOnPressed(handler)
	self.onPressed = handler
	return self
end

--- Set a handler that is executed when any prompt in the group is released.
-- @param handler Handler function
-- @usage promptGroup:setOnReleased(function(prompt, data) ... end)
function UipromptGroup:setOnReleased(handler)
	self.onReleased = handler
	return self
end

--- Set a handler that is executed when any prompt in the group is running its hold mode.
-- @param handler Handler function
-- @usage promptGroup:setOnHoldModeRunning(function(prompt, data) ... end)
function UipromptGroup:setOnHoldModeRunning(handler)
	self.onHoldModeRunning = handler
	return self
end

--- Set a handler that is executed when any prompt in the group has completed its hold mode.
-- @param handler Handler function
-- @usage promptGroup:setOnHoldModeCompleted(function(prompt, data) ... end)
function UipromptGroup:setOnHoldModeCompleted(handler)
	self.onHoldModeCompleted = handler
	return self
end

--- Set a handler that is executed when any control of any prompt in the group was just pressed.
-- @param handler Handler function
-- @usage promptGroup:setOnControlJustPressed(function(prompt, data) ... end)
function UipromptGroup:setOnControlJustPressed(handler)
	self.onControlJustPressed = handler
	return self
end

--- Set a handler that is executed when any control of any prompt in the group was just released.
-- @param handler Handler function
-- @usage promptGroup:setOnControlJustReleased(function(prompt, data) ... end)
function UipromptGroup:setOnControlJustReleased(handler)
	self.onControlJustReleased = handler
	return self
end

--- Set a handler that is executed when any control of any prompt in the group is pressed.
-- @param handler Handler function
-- @usage promptGroup:setOnControlPressed(function(prompt, data) ... end)
function UipromptGroup:setOnControlPressed(handler)
	self.onControlPressed = handler
	return self
end

--- Set a handler that is executed when any control of any prompt in the group is released.
-- @param handler Handler function
-- @usage promptGroup:setOnControlReleased(function(prompt, data) ... end)
function Uiprompt:setOnControlReleased(handler)
	self.onControlReleased = handler
	return self
end

--- Handle events for all prompts in the group (should be called every frame)
-- @param data Extra data passed to the event handlers for each prompt
-- @usage promptGroup:handleEvents()
function UipromptGroup:handleEvents(data)
	for _, prompt in ipairs(self.prompts) do
		if self.onJustPressed and prompt:isJustPressed() then
			self:onJustPressed(prompt, data)
		end

		if self.onJustReleased and prompt:isJustReleased() then
			self:onJustReleased(prompt, data)
		end

		if self.onPressed and prompt:isPressed() then
			self:onPressed(prompt, data)
		end

		if self.onReleased and prompt:isReleased() then
			self:onReleased(prompt, data)
		end

		if self.onHoldModeRunning and prompt:isHoldModeRunning() then
			self:onHoldModeRunning(prompt, data)
		end

		if self.onHoldModeCompleted and prompt:hasHoldModeCompleted() then
			self:onHoldModeCompleted(prompt, data)
		end

		if prompt:isEnabled() then
			if self.onControlJustPressed and prompt:isControlJustPressed(0) then
				self:onControlJustPressed(prompt, data)
			end

			if self.onControlJustReleased and prompt:isControlJustReleased(0) then
				self:onControlJustReleased(prompt, data)
			end

			if self.onControlPressed and prompt:isControlPressed(0) then
				self:onControlPressed(prompt, data)
			end

			if self.onControlReleased and prompt:isControlReleased(0) then
				self:onControlReleased(prompt, data)
			end
		end

		prompt:handleEvents(data)
	end
end

--- Get whether the group is active.
-- @return true or false
-- @usage if promptGroup:isActive() then ... end
function UipromptGroup:isActive()
	return self.active
end

--- Set whether the group is active.
-- @return true or false
-- @usage promptGroup:setActive(true)
function UipromptGroup:setActive(toggle)
	self.active = toggle
	return self
end

--- Clean up all prompts in the prompt group
-- @usage promptGroup:delete()
function UipromptGroup:delete()
	UipromptRegister:removeGroup(self)

	for _, prompt in ipairs(self.prompts) do
		prompt:delete()
	end
end
