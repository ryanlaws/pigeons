local utils = include('lib/utils')

local lisp = {}

-- TODO: find a more elegant way to do this.
-- keep in mind we don't want to mutate tables

lisp.defn = function (name, item)
    env[name] = item
end

--[[  
we REALLY need to find a way to return a *function*
that takes message_type and message. the number of things
that are getting passed through is gonna creep.

creating an environment for each message 
is probably the right way to do this.

should include core, so that needs to be copied.

also, since we only wanna copy the env once,
that should probably be a separate function,
whereas exec (eval) will be called recursively.
]]

-- TODO: create temp env
lisp.exec = function (expr, message_type, msg, now)
    if type(expr) == 'string' then
        print("expr " .. expr .. " is string. returning as-is.")
        return expr
    elseif type(expr) == 'number' then
        print("expr " .. expr .. " is number. returning as-is.")
        return expr
    elseif expr == nil then
        utils.warn("nil expr. BYE!")
        return expr
    elseif #expr == 0 then
        utils.warn("empty or non-sequential expr. BYE!")
        return expr
    end

    local fn_name = expr[1]
    if not fn_name then
        utils.warn("bogus function name ")
        -- should we error() here? 
        return
    end

    print ("checking whether fn " .. fn_name .. " exists")

    local fn = env[fn_name]
    if not fn or type(fn) ~= 'function' then
        utils.warn("no function '"..fn_name)
        return
    end

    local args = utils.tail(expr)
    print("expression: "..utils.table_to_string(expr))
    print("args: "..utils.table_to_string(args))
    print("message: "..utils.table_to_string(msg))
    print("executing fn "..fn_name.." on env")

    return fn(args, message_type, msg, now)
end

return lisp
