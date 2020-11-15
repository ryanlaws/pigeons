local utils = include('lib/utils')
local lisp = include('lib/lisp')

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

    -- something feels off here
    for i = 1,#handlers do
        print("handler "..i.." for "..message_type, message)
        lisp.exec(handlers[i], message_type, message, now)
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
