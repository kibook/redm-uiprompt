local promptGroup = UipromptGroup:new("Test")

promptGroup:addPrompt(`INPUT_DYNAMIC_SCENARIO`, "Test 1")
promptGroup:addPrompt(`INPUT_RELOAD`, "Test 2")

promptGroup:setOnControlJustPressed(function(group, prompt)
	TriggerEvent("chat:addMessage", {args={"You pressed " .. prompt:getText() .. "!"}})
end)
