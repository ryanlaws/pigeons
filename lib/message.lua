local message = {}

-- may need responsibilities split somewhat
message.transmit = function (message_type, message)
    -- getting time immediately is good for latency
    local now = util.time()
    if not message_type then
        utils.warn("message has no type, ignoring")
        return false
    end

    local handlers = listeners[message_type]
    if not handlers then
        utils.warn("message", message_type, "not identified, ignoring")
        return false
    end

    local env = lisp.make_env({
        message_type=message_type, 
        message=message, 
        now=now
    })

    -- something feels off here
    for i = 1,#handlers do
        -- print((util.time() % 1000) .. " - start handler "..i.." for "..message_type) 
        -- print("message:"..utils.table_to_string(message))
        -- print("handler:"..utils.table_to_string(handlers[i]))
        -- lisp.exec(handlers[i], message_type, message, now)
        local derp = lisp.exec(handlers[i], env)
        -- print((util.time() % 1000) .. " - finish handler "..i.." for "..message_type) 
    end
end

message.attach = function (message_type, handler)
    if type(handler) == 'string' then handler = { handler } end
    if listeners[message_type] == nil then listeners[message_type] = {} end

    --[[ to avoid dupes, might convert to string
    (e.g. s-expression)  & check collisions ]]
    table.insert(listeners[message_type], handler)
end

-- this may be unnecessary
message.identify = function (name)
    if listeners[name] ~= nil then
        utils.warn("message", name, "already identified")
        return false
    end
    listeners[name] = {}
    return true
end

return message
