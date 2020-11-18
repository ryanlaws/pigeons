local m = {}

m.logs = {}
m.listeners = {}

local max_log_size = 9
local spinner_max_index = 12
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
    msg.now = now
    msg.message_type = message_type

    if not message_type then
        utils.warn("message has no type, ignoring")
        return false
    end

    local handlers = m.listeners[message_type]
    if not handlers then
        utils.warn("message", message_type, "not identified, ignoring")
        return false
    end

    local env = lisp.make_env(msg)

    -- something feels off here
    for i = 1,#handlers do
        local derp = lisp.exec(handlers[i], env)
    end

    m.log(msg)
    -- this is very tacky. I don't like it. 
    ui.dirty = true
end

-- TODO: implement in lisp so we can utilize environment
--       this will be useful when e.g. switching modes (and envs)
m.attach = function (message_type, handler)
    if type(handler) == 'string' then handler = { handler } end
    if m.listeners[message_type] == nil then m.listeners[message_type] = {} end

    --[[ to avoid dupes, might convert to string
    (e.g. s-expression)  & check collisions ]]
    table.insert(m.listeners[message_type], handler)
end

-- this may be unnecessary
-- it is useful for discoverability though
m.identify = function (name)
    if m.listeners[name] ~= nil then
        utils.warn("message", name, "already identified")
        return false
    end
    m.listeners[name] = {}
    return true
end

return m
