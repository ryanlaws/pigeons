local core = {}

-- ok, I added env and it looks kinda silly now. oh well.
-- I think this might be useless now w/ non-nested messages
core['print-message'] = function (_, env)
    print(math.floor(env.now * 1000)..' - message of type '
        ..env.message_type..':')
    for k, v in pairs(env.message) do
        print(k .. ' = ' .. v)
    end
end

core['print-expr'] = function (args, env)
    local printable = args[1]
    -- assume we only care about first arg of expression
    -- I need to be able to get the whole env... I know this is gross
    local result 
    if printable and #printable > 0 then 
        result = lisp.exec(printable, env)
    else
        result = env
    end
    print(utils.table_to_string(result))
end

core['print-table'] = function (args, env)
    print(utils.table_to_string(args[1]))
end

core['env'] = function (args, env)
    return env
end

core['='] = function (args, env)
    return lisp.exec(args[1], env) == lisp.exec(args[2], env)
end

core['!'] = function (args, env)
    return not lisp.exec(args[1], env)
end

core['&'] = function (args, env)
    local result = true
    for i=1,#args do
        if not lisp.exec(args[i], env) then
            return false
        end
    end
    return result
end

core['|'] = function (args, env)
    local result = false
    for i=1,#args do
        if lisp.exec(args[i], env) then
            return true
        end
    end
    return result
end

core['?'] = function (args, env)
    local result = lisp.exec(args[1], env)
    if result then
        return lisp.exec(args[2], env)
    else
        return lisp.exec(args[3], env)
    end
end

core['-'] = function (args, env)
    local result = lisp.exec(args[1], env)
    for i=2,#args do
        result = result - lisp.exec(args[i], env)
    end
    return result
end

core['+'] = function (args, env)
    local result = lisp.exec(args[1], env)
    for i=2,#args do
        result = result + lisp.exec(args[i], env)
    end
    return result
end

core['%'] = function (args, env)
    print('oh hi '..#args..':')

    local num = lisp.exec(args[1], env)
    local denom = lisp.exec(args[2], env)

    -- TODO: validate:
    -- - num and denom should be numbers
    -- - denom should not be 0 (or negative?)

    return num % denom
end

-- TODO: move to _midi somehow
-- TODO: use vports to find device
core['midi'] = function (args, env)
    local dev_id = lisp.exec(args[1], env)
    local device = type(dev_id) == 'number' and midi.devices[dev_id] or nil
    if device == nil then 
        error("bogus MIDI device ID!")
    end

    device:send(lisp.exec(args[2], env))
end

core['smush'] = function (args, env)
    local str = ""
    for i=1,#args do
        local val = lisp.exec(args[i], env)
        if type(val) == 'boolean' then
            val = val and '(true)' or '(false)'
        end
        str = str..(val or "(nil)")
    end
    return str
end

core['prop'] = function (args, env)
    local prop = args[1]
    if type(prop) ~= 'string' then return nil end

    local t = lisp.exec(args[2], env)
    if type(t) ~= 'table' then return nil end
    return t[prop]
end

-- gonna want defn too, eventually
-- that sounds like a pain
core['def'] = function(args, env)
    if type(args[1]) ~= 'string' then
        error("def name is not a string, what the heck dude?")
        return nil
    elseif args[2] ~= nil then
        utils.warn("what's the point of defining "..args[1].." as (nil)?")
    end

    return env[args[1]] == args[2]
    -- do we care if we're re-defining an existing name?
    -- nah, not yet. REASONS TO CARE NEEDED
end

-- this is kinda tacky.
-- we want something that copies the table and redefines in the copy.
core['defk'] = function(args, env)
    if type(args[1]) ~= 'string' then
        error("def name is not a string, what the heck dude?")
        return nil
    elseif type(args[2]) ~= 'string' and type(args[2]) ~= 'number' then
        error("key name is not a string or number, what the heck dude?")
        return nil
    elseif args[3] == nil then
        utils.warn("what's the point of defining "..args[1].."."..args[2].." as (nil)?")
    end

    env[args[1]][args[2]] = lisp.exec(args[3], env)
end

-- mayyyybe a bad idea
core['gdef'] = function(args, env)
    if type(args[1]) ~= 'string' then
        error("non-string key to ['gdef']")
    elseif type(args[2]) == nil then
        error("nil value to ['gdef']")
    else
        -- totally fine to eval here
        lisp.defglobal(args[1], lisp.exec(args[2], env))
    end
end

core['do'] = function(args, env)
    local result
    for i=1,#args do
        result = lisp.exec(args[i], env)
    end
    return result
end

core['pairs-to-table'] = function (args, env)
    local t = {}
    local count = #args
    for i=1, #args, 2  do
        if i+1 <= #args then
            local k = lisp.exec(args[i], env)
            local v = lisp.exec(args[i + 1], env)
            if type(k) == 'string' and v ~= nil then
                t[k] = t[v]
            end
        end 
    end
end

core['tx'] = function(args, env)
    local message_type = lisp.exec(args[1], env)
    local msg = lisp.exec(args[2], env)
    message.transmit(message_type, msg, "lisp")
end


core['expr-to-sexpr'] = function(args, env, list)
    if type(args) ~= 'table' then error('bad args') end
    if type(args[1]) ~= 'table' then error('arg is not a table') end

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

core['at'] = function(args, env)
    if type(args) ~= 'table' or #args < 2 then 
        error('bad args - not table or empty table') 
    end

    local table = lisp.exec(args[1], env)
    local key = lisp.exec(args[2], env)

    if type(table) ~= 'table' then 
        error('.at arg[1] is not a table') 
    end

    -- in fact lua accepts anything besides nil
    -- but what's useful besides string and number?
    if (type(key) ~= 'string') and (type(key) ~= 'number') then 
        error('.at arg[2] is not a string or number') 
    end

    return table[key]
end

-- having both of these separate is probably only useful w/ currying
core['of'] = function(args, env)
    if type(args) ~= 'table' or #args < 2 then 
        error('bad args - not table or empty table') 
    end

    local key = args[1]
    local table = args[2]

    -- in fact lua accepts anything besides nil
    -- but what's useful besides string and number?
    if (type(key) ~= 'string') or (type(key) ~= 'number') then 
        error('.at arg[1] is not a string or number') 
    end

    if type(table) ~= 'table' then 
        error('.at arg[2] is not a table') 
    end

    return table[key]
end

core['join'] = function(args, env)
    if type(args) ~= 'table' then error('bad args') end
    if type(args[1]) ~= 'table' then error('arg is not a table') end

    local glue

    if args[2] == nil then 
        glue = " "
    elseif type(args[2]) ~= 'string' then 
        glue = args[2]
    else
        error("I don't know what to do with a "..type(args[2]))
    end

    local last_item
    local str = ""

    for i=1,#args[1] do
        local item = args[1][i]
        if type(item) == 'string' then
            -- TODO: move - doesn't belong here.
            if (last_item == "(") or (item == ")")  then
                str = str..item
            else
                str = str..glue..item
            end
        elseif type(item) == 'number' then
            str = str..glue..item
        else
            error("I don't know what to do with a "..type(item))
        end
        last_item = item
    end

    return str
end

-- stinky
-- could probably just iterate over all these keys
lisp.defglobal('print-message', core['print-message'])
lisp.defglobal('print-expr', core['print-expr'])
lisp.defglobal('print-table', core['print-table'])
lisp.defglobal('smush', core['smush'])
lisp.defglobal('env', core['env'])
lisp.defglobal('?', core['?'])
lisp.defglobal('=', core['='])
lisp.defglobal('&', core['&'])
lisp.defglobal('|', core['|'])
lisp.defglobal('!', core['!'])
lisp.defglobal('-', core['-'])
lisp.defglobal('+', core['+'])
lisp.defglobal('%', core['%'])
lisp.defglobal('at', core['at'])
lisp.defglobal('midi', core['midi'])
lisp.defglobal('prop', core['prop'])
lisp.defglobal('def', core['def'])
lisp.defglobal('defk', core['defk'])
lisp.defglobal('gdef', core['gdef'])
lisp.defglobal('do', core['do'])
lisp.defglobal('join', core['join'])
lisp.defglobal('expr-to-sexpr', core['expr-to-sexpr'])

return core
