local promptGroup = UipromptGroup:new("Test")

promptGroup:addPrompt(`INPUT_DYNAMIC_SCENARIO`, "Test 1"):setHoldMode(true)
promptGroup:addPrompt(`INPUT_RELOAD`, "Test 2"):setHoldMode(true)

promptGroup:setOnHoldModeJustCompleted(function(group, prompt)
	TriggerEvent("chat:addMessage", {args={"You held " .. prompt:getText() .. "!"}})
end)

UipromptManager:startEventThread()
