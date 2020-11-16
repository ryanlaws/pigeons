local core = {}

-- ok, I added env and it looks kinda silly now. oh well.
core.print_message = function (_, env)
    print(math.floor(env.now * 1000)..' - message of type '
        ..env.message_type..':')
    for k, v in pairs(env.message) do
        print(k .. ' = ' .. v)
    end
end

core.print_expr = function (args, env)
    local printable = args[1]
    -- print("printing result of expression "..utils.table_to_string(printable))
    -- assume we only care about first arg of expression
    local result = lisp.exec(printable, env)
    print(utils.table_to_string(result))
    -- print((util.time() % 1000).." - "..result)
end

core.print_table = function (args, env)
    print(utils.table_to_string(args[1]))
end

core.eq = function (args, env)
    -- print("checking equality")
    -- local first = lisp.exec(args[1], env)
    -- local second = lisp.exec(args[2], env)
    -- print("first value = "..utils.table_to_string(first))
    -- print("second value = "..utils.table_to_string(second))
    -- local equals = first == second
    -- print("equality test "..(equals and "passed" or "failed"))
    -- return equals
    return lisp.exec(args[1], env) == lisp.exec(args[2], env)
end

core.cond = function (args, env)
    -- print("executing IF")
    local result = lisp.exec(args[1], env)
    if result then
        return lisp.exec(args[2], env)
    else
        return lisp.exec(args[3], env)
    end
end

core.smush = function (args, env)
    -- print("exectuing SMUUUSH")
    local str = ""
    for i=1,#args do
        -- print("smushing expr: "..utils.table_to_string(args[i]).."")
        local val = lisp.exec(args[i], env)
        -- print("smushing value: "..utils.table_to_string(val).."")
        str = str..(val or "(nil)")
    end
    return str
end

core.message_prop = function (args, env)
    local prop = args[1]
    -- print("checking prop " .. prop)
    --[[print("checking message prop "
        ..utils.table_to_string(prop).." on "
        ..utils.table_to_string(env.message)) --]]
    -- TODO: validate / handle errors
    -- print("found value "..utils.table_to_string(env.message[prop]))
    return env.message[prop]
end

-- I got a feeling this one's gonna be short-lived
core.warn_bogus = function (_, env)
    utils.warn(math.floor(env.now * 1000)..' - message of type '
        ..env.message_type..' has some bogus stuff!')
end

-- gonna want defn too, eventually
-- that sounds like a pain
core.def = function(args, env)
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

-- mayyyybe a bad idea
core.defglobal = function(args, env)
    if type(args[1]) ~= 'string' then
        error("non-string key to defglobal")
    elseif type(args[2]) == nil then
        error("nil value to defglobal")
    else
        -- print("assigning "..args[1])
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
-- stinky
-- could probably just iterate over all these keys
-- TODO: use kebab case :)
lisp.defglobal('print_message', core.print_message)
lisp.defglobal('print_expr', core.print_expr)
lisp.defglobal('print_table', core.print_table)
lisp.defglobal('smush', core.smush)
lisp.defglobal('if', core.cond)
lisp.defglobal('=', core.eq)
lisp.defglobal('message_prop', core.message_prop)
lisp.defglobal('def', core.def)
lisp.defglobal('defglobal', core.defglobal)
lisp.defglobal('do', core['do'])

return core
