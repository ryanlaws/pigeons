function clear_all()
    -- TODO: rename to handlers
    messages = {}
        -- knob/enc
        -- UI?
        -- app-level (load, save, init, etc.)?
        -- MIDI
        -- HID
        -- crow?

    env = {}
        -- MIDI
        -- synth
        -- softcut
        -- crow
        -- UI
end

function tail(t, start)
    start = start or 2
    if type(t) ~= 'table' or #t == 0 then return {} end

    local result = {}
    for i=2,#t do
        table.insert(result, t[i])
    end
    return result
end


function warn(...)
    print("warn:", ...)
end

function identify_message(name)
    if messages[name] ~= nil then
        warn("message", name, "already identified")
        return false
    end
    messages[name] = {}
    return true
end

function defn(name, effect)
    env[name] = effect
end

-- IT MIGHT BE USEFUL
-- MSTERISOUS
function transmit(message_type, message)
    local now = util.time()
    if not message_type then
        warn("message has no type, ignoring")
        return false
    end

    local handlers = messages[message_type]
    if not handlers then
        warn("message", message_type, "not identified, ignoring")
        return false
    end

    for i = 1,#handlers do
        print("handler "..i.." for "..message_type, message)
        exec(handlers[i], message_type, message, now)
    end
end

-- IT'S LISP AGAIN!
--[[  we REALLY need to find a way to return a *function*
that takes message_type and message. the number of things
that are getting passed through is gonna creep.]]

-- TODO: setup temp env, f passing all this around
function exec(expr, message_type, message, now)
    if type(expr) == 'string' then
        print("expr " .. expr .. " is string. returning as-is.")
        return expr
    elseif type(expr) == 'number' then
        print("expr " .. expr .. " is number. returning as-is.")
        return expr
    elseif expr == nil then
        print("nil expr. BYE!")
        return expr
    elseif #expr == 0 then
        print("empty or non-sequential expr. BYE!")
        return expr
    end

    local fn_name = expr[1]
    if not fn_name then
        warn("bogus function name handling", message_type)
        -- should probably throw... but idk how to do that lol
        return
    end

    print ("seeing if fn " .. fn_name .. " exists")

    local fn = env[fn_name]
    if not fn or type(fn) ~= 'function' then
        -- I don't like this. handle it in the function.
        --warn("no function '"..fn_name.."', assuming string")
        warn("no function '"..fn_name)
        return
    end

    local args = tail(expr)
    print("expression: "..table_to_string(expr))
    print("args: "..table_to_string(args))
    print("message: "..table_to_string(message))
    print("executing fn "..fn_name.." on env")

    return fn(args, message_type, message, now)
end

-- now the first arg is always nil... lol
-- probably not great
function print_message(_, message_type, message, now)
    print(math.floor(now * 1000)..' - message of type ' .. message_type .. ':')
    for k, v in pairs(message) do
        print(k .. ' = ' .. v)
    end
end

function table_to_string(table, depth)
    depth = depth or 0

    if type(table) == 'string' or type(table) == 'number' then
        return table
    elseif table == nil then
        return "(nil)"
    elseif type(table) ~= 'table' then
        return '' + table
    end

    local str = '{\n'
    local indent = ''
    -- TODO: find a string function that does this for me
    for i = 1, depth do
        indent = indent.."  "
    end

    for k, v in pairs(table) do
        str = str..'\n'..indent.."  "
        if type(k) ~= 'number' then
            str = str..k..' = '
        end
        str = str..table_to_string(v, depth + 1)..'\n'
    end
    return str..indent..'}'
end

function print_expr(args, message_type, message, now)
    local printable = args[1]
    print("printing result of expression "..table_to_string(printable))
    -- assume we only care about first arg of expression
    local result = exec(printable, message_type, message, now)
    print(result)
end

function eq(args, message_type, message, now)
    print("checking equality")
    local first = exec(args[1], message_type, message, now)
    local second = exec(args[2], message_type, message, now)
    print("first value = "..table_to_string(first))
    print("second value = "..table_to_string(second))
    local equals = first == second
    print("equality test "..(equals and "passed" or "failed"))
    return equals
end

function cond(args, message_type, message, now)
    print("executing IF")
    local result = exec(args[1], message_type, message, now)
    if result then
        return exec(args[2], message_type, message, now)
    else
        return exec(args[3], message_type, message, now)
    end
end

function smush(args, message_type, message, now)
    print("exectuing SMUUUSH")
    local str = ""
    for i=1,#args do
        str = str..(exec(args[i], message_type, message, now) or "(nil)")
    end
    return str
end

function message_prop(args, message_type, message, now)
    local prop = args[1]

    -- return fn(args, message_type, message, now)
    print("checking message prop "..table_to_string(prop)
        .." on "..table_to_string(message))
    -- TODO: validate / handle errors
    local value = message[prop]
    print("found value " .. table_to_string(value))
    return message[prop]
end

function warn_bogus(_, message_type, message, now)
    warn(math.floor(now * 1000)..' - message of type '
        .. message_type .. ' has some bogus stuff!')
end

function attach(message_type, handler)
    -- handler can be an implementation (w/ conditions, etc.) or a name
    if type(handler) == 'string' then handler = { handler } end
    if messages[message_type] == nil then messages[message_type] = {} end

    --[[ to avoid dupes, might convert to string
    (e.g. s-expression)  & check collisions ]]
    table.insert(messages[message_type], handler)
end

function init()
    clear_all()

    defn('print_message', print_message)
    defn('print_expr', print_expr)
    defn('smush', smush)
    defn('if', cond)
    defn('=', eq)
    defn('message_prop', message_prop)

    identify_message('encoder')
    identify_message('button')

    attach('encoder', 'print_message')
    attach('encoder',
        { 'if',
            { '=', 3,  { 'message_prop', 'number' } },
            { 'print_expr', 'we got a THREE!'},
            { 'print_expr',
                { 'smush', "what's '", { 'message_prop', 'number' }, "' ?" }}})
    attach('button', 'print_message')
end

function enc(i, x)
    transmit('encoder', { number=i, value=x })
end

function key(i, x)
    transmit('button', { number=i, value=x })
end

function set(name, value)
    env[name] = value
end