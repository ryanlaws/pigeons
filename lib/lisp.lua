local global_env = {}
local lisp = {}

-- TODO: find a more elegant way to do this.
-- keep in mind we don't want to mutate tables
-- (is that really true? I'm mutating them now lol)
-- something something metatables
lisp.defglobal = function (name, item)
    -- print((util.time() % 1000) .. " adding "..name.." to global env")
    global_env[name] = item
end

-- copying envs could be useful
lisp.make_env = function (new_env)
    if new_env == nil then
        -- print("new env is empty, making a fresh table")
        new_env = {}
    elseif type(new_env) ~= 'table' then 
        error("bad env (type "..type(env).." - should be table)") 
        return nil -- reachable?
    else
        -- print("new env looks good to me:"..utils.table_to_string(new_env))
    end
    -- print("old env:"..utils.table_to_string(global_env))

    -- dummy vars everywhere. 
    -- probably not the right way to use metatables.
    local env = setmetatable({}, {
        __index = function(_, k)
            -- print("looking in env for "..k)
            return (new_env[k] ~= nil and new_env[k]) or global_env[k]
        end,
        __newindex = function(_, k, v)
            -- print("trying to set "..k.." in env")
            new_env[k] = v
        end
    })

    -- print("here's your new table:"..utils.table_to_string(env))

    return env
end

-- should creating an environment give us an exec() as well?
lisp.exec = function (expr, env) 
    if type(expr) == 'string' then
        -- print("expr " .. expr .. " is string. returning as-is.")
        return expr
    elseif type(expr) == 'number' then
        -- print("expr " .. expr .. " is number. returning as-is.")
        return expr
    elseif expr == nil then
        utils.warn("nil expr. BYE!")
        return expr
    elseif #expr == 0 then
        utils.warn("empty or non-sequential expr. BYE!")
        return expr
    end

    local head = expr[1]
    if not head then
        utils.warn("bogus head")
        -- should we error() here? 
        return
    end

    -- print("checking whether env has " .. head)
    local item = env[head]
    if item == nil then
        error("env does not have '"..head.."'")
        return nil -- uhhh, what else?
    elseif type(item) ~= 'function' then -- assuming string/number. what else...?
        -- print("env '"..head.."' is not a function - returning as-is")
        --return lisp.exec(item, env) -- lol. no. this is why you have separate def and defn
        -- for functions I think it's the same... but lazy.
        return item
    end

    local args = utils.tail(expr)
    -- print("expression: "..utils.table_to_string(expr))
    -- print("args: "..utils.table_to_string(args))
    -- print("executing fn "..head.." on env")

    return item(args, env)
    -- message_type, msg, now)
end

lisp.eval = function ()
end

return lisp
