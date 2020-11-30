local global_env = {}
local lisp = {}

-- TODO: find a more elegant way to do this.
-- keep in mind we don't want to mutate tables
-- (is that really true? I'm mutating them now lol)
-- something something metatables
lisp.defglobal = function (name, item)
    global_env[name] = item
end

-- also need outputs for:
    -- MIDI
    -- synth
    -- softcut
    -- crow
    -- UI

-- copying envs could be useful
lisp.make_env = function (new_env)
    if new_env == nil then
        new_env = {}
    elseif type(new_env) ~= 'table' then 
        error("bad env (type "..type(env).." - should be table)") 
        return nil -- reachable?
    end

    -- dummy vars everywhere. 
    -- probably not the right way to use metatables.
    local env = setmetatable({}, {
        __index = function(_, k)
            return (new_env[k] ~= nil and new_env[k]) or global_env[k]
        end,
        __newindex = function(_, k, v)
            new_env[k] = v
        end
    })

    return env
end

-- TODO: return exec() w/o needing env arg
--   it's getting tedious to pass it around EVERYWHERE
--   also, a metatable parental chain of env would make mode/event envs easier
-- should creating an environment give us an exec() as well?
lisp.exec = function (expr, env) 
    if type(expr) == 'string' then
        return expr
    elseif type(expr) == 'number' then
        return expr
    elseif expr == nil then
        -- utils.warn("nil expr. BYE!")
        return expr
    elseif #expr == 0 then
        -- utils.warn("empty or non-sequential expr. BYE!")
        return expr
    end

    local head = expr[1]
    if not head then
        utils.warn("bogus head")
        -- should we error() here? 
        return
    end

    if not env then 
        env = lisp.make_env()
    end

    local item = env[head]
    if item == nil then
        -- no. erroring is a bad idea. for example, clock doesn't have .ch. heh
        -- error("env does not have '"..head.."'") -- just no.
        -- utils.warn("env does not have '"..head.."'") -- very chatty - bad.
        return nil -- uhhh, what else?
    elseif type(item) ~= 'function' then -- assuming string/number. what else...?
        -- for functions I think it's the same... but lazy.
        return item
    end

    local args = utils.tail(expr)

    return item(args, env)
end

lisp.eval = function ()
end

return lisp
