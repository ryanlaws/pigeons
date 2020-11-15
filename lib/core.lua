local utils = include('lib/utils')
local lisp = include('lib/lisp')

local core = {}

-- TODO: add env (see above)
-- will allow removing dummy args
core.print_message = function (_, message_type, message, now)
    print(math.floor(now * 1000)..' - message of type ' .. message_type .. ':')
    for k, v in pairs(message) do
        print(k .. ' = ' .. v)
    end
end

core.print_expr = function (args, message_type, message, now)
    local printable = args[1]
    print("printing result of expression "..utils.table_to_string(printable))
    -- assume we only care about first arg of expression
    local result = lisp.exec(printable, message_type, message, now)
    print(result)
end

core.eq = function (args, message_type, message, now)
    print("checking equality")
    local first = lisp.exec(args[1], message_type, message, now)
    local second = lisp.exec(args[2], message_type, message, now)
    print("first value = "..utils.table_to_string(first))
    print("second value = "..utils.table_to_string(second))
    local equals = first == second
    print("equality test "..(equals and "passed" or "failed"))
    return equals
end

core.cond = function (args, message_type, message, now)
    print("executing IF")
    local result = lisp.exec(args[1], message_type, message, now)
    if result then
        return lisp.exec(args[2], message_type, message, now)
    else
        return lisp.exec(args[3], message_type, message, now)
    end
end

core.smush = function (args, message_type, message, now)
    print("exectuing SMUUUSH")
    local str = ""
    for i=1,#args do
        str = str..(lisp.exec(args[i], message_type, message, now) or "(nil)")
    end
    return str
end

core.message_prop = function (args, message_type, message, now)
    local prop = args[1]

    -- return fn(args, message_type, message, now)
    print("checking message prop "..utils.table_to_string(prop)
        .." on "..utils.table_to_string(message))
    -- TODO: validate / handle errors
    local value = message[prop]
    print("found value "..utils.table_to_string(value))
    return message[prop]
end

-- I got a feeling this one's gonna be short-lived
core.warn_bogus = function (_, message_type, message, now)
    utils.warn(math.floor(now * 1000)..' - message of type '
        .. message_type .. ' has some bogus stuff!')
end

return core
