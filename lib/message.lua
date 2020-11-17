local m = {}

m.logs = {}

local listeners = {}
local max_log_size = 8
local spinner_max_index = 10
local spinner_index = 0

m.log = function (msg)
    if #m.logs >= max_log_size then
        table.remove(m.logs, 1)
    end
    table.insert(m.logs, { message=msg, spinner_index=spinner_index })
    spinner_index = (spinner_index + 1) % spinner_max_index
end

-- may need responsibilities split somewhat
m.transmit = function (message_type, msg)
    -- getting time immediately is good for latency
    local now = util.time()
    local msg = {
        message_type=message_type, 
        message=msg, 
        now=now
    }

    if not message_type then
        utils.warn("message has no type, ignoring")
        return false
    end

    local handlers = listeners[message_type]
    if not handlers then
        utils.warn("message", message_type, "not identified, ignoring")
        return false
    end

    local env = lisp.make_env(msg)

    -- something feels off here
    for i = 1,#handlers do
        -- print((util.time() % 1000) .. " - start handler "..i.." for "..message_type) 
        -- print("message:"..utils.table_to_string(message))
        -- print("handler:"..utils.table_to_string(handlers[i]))
        -- lisp.exec(handlers[i], message_type, message, now)
        local derp = lisp.exec(handlers[i], env)
        -- print((util.time() % 1000) .. " - finish handler "..i.." for "..message_type) 
    end

    m.log(msg)
    -- this is very tacky. I don't like it. 
    ui.dirty = true
end

-- TODO: implement in lisp so we can utilize environment
--       this will be useful when e.g. switching modes (and envs)
m.attach = function (message_type, handler)
    if type(handler) == 'string' then handler = { handler } end
    if listeners[message_type] == nil then listeners[message_type] = {} end

    --[[ to avoid dupes, might convert to string
    (e.g. s-expression)  & check collisions ]]
    table.insert(listeners[message_type], handler)
end

-- this may be unnecessary
-- it is useful for discoverability though
m.identify = function (name)
    if listeners[name] ~= nil then
        utils.warn("message", name, "already identified")
        return false
    end
    listeners[name] = {}
    return true
end

return m
