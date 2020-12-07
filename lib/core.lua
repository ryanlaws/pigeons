local core = {}

core['print-expr'] = function (args, l)
    local printable = args[1]
    -- assume we only care about first arg of expression
    -- I need to be able to get the whole env... I know this is gross
    local result
    if printable and #printable > 0 then
        result = l.exec(printable)
    else
        result = l.env
    end
    print(Utils.table_to_string(result))
end

core['print-table'] = function (args, l)
    print(Utils.table_to_string(args[1]))
end

core['='] = function (args, l)
    return l.exec(args[1]) == l.exec(args[2])
end

core['>'] = function (args, l)
    return l.exec(args[1]) > l.exec(args[2])
end

core['<'] = function (args, l)
    return l.exec(args[1]) < l.exec(args[2])
end

core['>='] = function (args, l)
    return l.exec(args[1]) >= l.exec(args[2])
end

core['<='] = function (args, l)
    return l.exec(args[1]) <= l.exec(args[2])
end

core['!'] = function (args, l)
    return not l.exec(args[1])
end

core['&'] = function (args, l)
    local result = true
    for i=1,#args do
        if not l.exec(args[i]) then
            return false
        end
    end
    return result
end

core['|'] = function (args, l)
    local result = false
    for i=1,#args do
        if l.exec(args[i]) then
            return true
        end
    end
    return result
end

core['?'] = function (args, l)
    local result = l.exec(args[1])
    if result then
        return l.exec(args[2])
    else
        return l.exec(args[3])
    end
end

core['-'] = function (args, l)
    local result = l.exec(args[1])
    for i=2,#args do
        result = result - l.exec(args[i])
    end
    return result
end

core['+'] = function (args, l)
    local result = l.exec(args[1])
    for i=2,#args do
        result = result + l.exec(args[i])
    end
    return result
end

core['/'] = function (args, l)
    local result = l.exec(args[1])
    for i=2,#args do
        result = result / l.exec(args[i])
    end
    return result
end

core['*'] = function (args, l)
    local result = l.exec(args[1])
    for i=2,#args do
        result = result * l.exec(args[i])
    end
    return result
end

core['%'] = function (args, l)
    local num = l.exec(args[1])
    local denom = l.exec(args[2])

    -- TODO: validate:
    -- - num and denom should be numbers
    -- - denom should not be 0 (or negative?)

    return num % denom
end

-- TODO: move to _midi somehow
-- TODO: use vports to find device
core['midi'] = function (args, l)
    local dev_id = l.exec(args[1])
    local device = type(dev_id) == 'number' and midi.devices[dev_id] or nil
    if device == nil then
        error("bogus MIDI device ID!")
    end

    device:send(l.exec(args[2]))
end

core['smush'] = function (args, l)
    local str = ""
    for i=1,#args do
        local val = l.exec(args[i])
        if type(val) == 'boolean' then
            val = val and '(true)' or '(false)'
        end
        str = str..(val or "(nil)")
    end
    return str
end

core['prop'] = function (args, l)
    local prop = args[1]
    if type(prop) ~= 'string' then return nil end

    local t = l.exec(args[2])
    if type(t) ~= 'table' then return nil end
    return t[prop]
end

-- gonna want defn too, eventually
-- that sounds like a pain
core['def'] = function(args, l)
    if type(args[1]) ~= 'string' then
        error("def name is not a string, what the heck dude?")
        return nil
    end

    local result = l.exec(args[2])
    if result == nil then
        Utils.warn("what's the point of defining "..args[1].." as (nil)?")
    end

    l.env[args[1]] = result
    -- do we care if we're re-defining an existing name?
    -- nah, not yet. REASONS TO CARE NEEDED
end

-- this is kinda tacky.
-- we want something that copies the table and redefines in the copy.
core['def@'] = function(args, l)
    if type(args[1]) ~= 'string' then
        error("def name is not a string, what the heck dude?")
        return nil
    elseif type(args[2]) ~= 'string' and type(args[2]) ~= 'number' then
        error("key name is not a string or number, what the heck dude?")
        return nil
    elseif args[3] == nil then
        Utils.warn("what's the point of defining "..args[1].."."..args[2].." as (nil)?")
    end

    l.env[args[1]][args[2]] = l.exec(args[3])
end

-- mayyyybe a bad idea
core['gdef'] = function(args, l)
    if type(args[1]) ~= 'string' then
        error("non-string key to ['gdef']")
    elseif type(args[2]) == nil then
        error("nil value to ['gdef']")
    else
        -- totally fine to eval here
        l.defglobal(l.exec(args[1]), l.exec(args[2]))
    end
end

core['do'] = function(args, l)
    local result
    for i=1,#args do
        result = l.exec(args[i])
    end
    return result
end

core['pairs-to-table'] = function (args, l)
    local t = {}
    for i=1, #args, 2  do
        if i+1 <= #args then
            local k = l.exec(args[i])
            local v = l.exec(args[i + 1])
            if type(k) == 'string' and v ~= nil then
                t[k] = t[v]
            end
        end
    end
end

core['tx'] = function(args, l)
    local message_type = l.exec(args[1])
    local msg = l.exec(args[2])
    Message.transmit(message_type, msg, "lisp")
end

core[':'] = function(args, l)
    -- print('in pairs with '..#args..' args.')
    local t = {}
    for i=1,#args,2 do
        local key = l.exec(args[i])
        -- print('setting '..key)
        local value = l.exec(args[i + 1])
        t[key] = value
    end
    return t
end

core['expr-to-sexpr'] = function(args, env, list)
    if type(args) ~= 'table' then error('bad args') end
    if type(args[1]) ~= 'table' then error('expr-to-sexpr arg is not a table') end

    if list == nil then
        list = {}
    elseif type(list) ~= 'table' then
        error('list is not a table')
    end

    table.insert(list, '(')

    for i=1,#args[1] do
        local item = args[1][i]
        if type(item) == 'table' then
            -- gross mutation
            core['expr-to-sexpr']({ item }, env, list)
        elseif type(item) == 'string' then
            table.insert(list, item)
        elseif type(item) == 'number' then
            table.insert(list, item)
        else
            error("I don't know what to do with a "..type(item))
        end
    end

    table.insert(list, ')')
    return list
end

core['@'] = function(args, l)
    if type(args) ~= 'table' or #args < 2 then
        error('bad args - not table or empty table')
    end

    local table = l.exec(args[1])
    local key = l.exec(args[2])

    if type(table) ~= 'table' then
        error('.@ arg[1] is not a table, it is a '..type(table))
    end

    -- in fact lua accepts anything besides nil
    -- but what's useful besides string and number?
    if (type(key) ~= 'string') and (type(key) ~= 'number') then
        error('.@ arg[2] is not a string or number')
    end

    return table[key]
end

-- I may have implemented this elsewhere... ugh
core['`'] = function (args, l)
    return args
end

-- having both of these separate is probably only useful w/ currying
core['of'] = function(args, l)
    if type(args) ~= 'table' or #args < 2 then
        error('bad args - not table or empty table')
    end

    local key = args[1]
    local table = args[2]

    -- in fact lua accepts anything besides nil
    -- but what's useful besides string and number?
    if (type(key) ~= 'string') or (type(key) ~= 'number') then
        error('.of arg[1] is not a string or number')
    end

    if type(table) ~= 'table' then
        error('.of arg[2] is not a table')
    end

    return table[key]
end

core['join'] = function(args, l)
    if type(args) ~= 'table' then error('bad args') end
    if type(args[1]) ~= 'table' then error('join arg is not a table') end

    local glue

    if args[2] == nil then
        glue = " "
    elseif type(args[2]) ~= 'string' then
        glue = args[2]
    else
        error("join doen't know what to do with a "..type(args[2]))
    end

    local last_item
    local str = ''

    for i=1,#args[1] do
        local item = args[1][i]
        if type(item) == 'string' then
            -- TODO: move - doesn't belong here.
            if (last_item == "(") or (item == ")")  then
                str = str..item
            else
                str = str..((i ~= 1) and glue or '')..item
            end
        elseif type(item) == 'number' then
            str = str..glue..item
        elseif type(item) == 'table' then
            local item_str = l.exec(item)
            if item_str == nil then item_str = '(nil)' end
            str = str..((i ~= 1) and glue or '')..item_str
        else
            error("join doen't know what to do with a "..type(item))
        end
        last_item = item
    end

    return str
end

core['exec-file'] = function(args, l)
    local filename = l.exec(args[1])
    return l.exec_file(filename)
end

core['load-file'] = function(args, l)
    local filename = l.exec(args[1])
    return l.load_file(filename)
end

core['attach-message'] = function(args, l)
    local message_type = l.exec(args[1])
    local handler_def = l.exec(args[2]) -- actually need exec. ugh
    Message.attach(message_type, handler_def)
end

 -- must happen AFTER midi init
core['add-lens'] = function(args, l)
    local port_id = l.exec(args[1])
    local lens_def = l.exec(args[2])
    local lens_channels = args[3] and l.exec(args[3])
    _Midi.add_lens(port_id, lens_def, lens_channels)
end

-- actually do the defining
-- this uses the global Lisp (i.e., the file, not the env)
for name, def in pairs(core) do
    print('defining core function '..name)
    Lisp.defglobal(name, def)
end

return core
