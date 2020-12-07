local global_env = {}
local lisp = {}


local base_lisp_path = '/home/we/dust/code/pigeons/'

lisp.tail = function (t, start)
    start = start or 2
    if type(t) ~= 'table' or #t == 0 then return {} end

    local result = {}
    for i=2,#t do
        table.insert(result, t[i])
    end
    return result
end

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
lisp.make_env = function (new_env, parent_env)
    if new_env == nil then
        new_env = {}
    elseif type(new_env) ~= 'table' then 
        error("bad env (type "..type(new_env).." - should be table)") 
        return nil -- reachable?
    end

    parent_env = parent_env or global_env

    -- dummy vars everywhere. 
    -- probably not the right way to use metatables.
    local env = setmetatable({}, {
        __index = function(_, k)
            return (new_env[k] ~= nil and new_env[k]) or parent_env[k]
        end,
        __newindex = function(_, k, v)
            new_env[k] = v
        end,
        __parent = parent_env
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
    elseif type(expr) == 'boolean' then
        return expr
    elseif expr == nil then
        return expr
    elseif #expr == 0 then
        -- Utils.warn("empty or non-sequential expr. BYE!")
        return expr
    end

    local head = expr[1]
    if not head then
        Utils.warn("bogus head")
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
        -- Utils.warn("env does not have '"..head.."'") -- very chatty - bad.
        return nil -- uhhh, what else?
    elseif type(item) ~= 'function' then -- assuming string/number. what else...?
        -- for functions I think it's the same... but lazy.
        return item
    end

    local args = lisp.tail(expr)

    return item(args, env)
end

-- file stuff
lisp.load_file = function(filename)
    return lisp.load_lisp_file(filename)
end

lisp.exec_file = function(filename, env)
    return lisp.exec(lisp.load_file(filename), env)
end

lisp.lisp_to_table = function (sexpr)
    -- remove line comments
    sexpr = string.gsub(sexpr, ';;[^\r\n]*(\r?\n)', "%1")

    -- remove starting/trailing whitespace
    sexpr = string.gsub(sexpr, '^%s+', '')
    sexpr = string.gsub(sexpr, '%s+$', '')

    -- wrap words in single quotes (end w/ digit(s) is OK)
    sexpr = string.gsub(sexpr, '[^-%(%)0-9%s][^%(%)%s]*', "'%0'")
    -- wrap minus + non-space/number/paren(s) in single quote
    sexpr = string.gsub(sexpr, '([%(%)%s]+)(-[^%(%)0-9%s]+)', "%1'%2'")
    -- wrap lone minus within paren/space in single quote
    sexpr = string.gsub(sexpr, '([%(%)%s]+)-([%(%)%s]+)', "%1'-'%2")

    -- so hacky.
    sexpr = string.gsub(sexpr, "'false'", 'false')
    sexpr = string.gsub(sexpr, "'true'", 'true')
    sexpr = string.gsub(sexpr, "'nil'", 'nil')

    -- parens to curlies
    sexpr = string.gsub(sexpr, '%(', '{')
    sexpr = string.gsub(sexpr, '%)', '}')

    -- contiguous whitespace to single comma
    sexpr = string.gsub(sexpr, '%s+', ',')
    
    local fn, err = load('return '..sexpr)
    if err then
        error("error parsing sexpr:\n"..err
            .."\nbad sexpr:\n"..sexpr)
    end

    return fn()
end

lisp.load_lisp_file = function (filename)
    local file = io.open(base_lisp_path..filename..'.plisp', 'r')
    io.input(file)
    local contents = io.read('*all')
    -- io.close() -- this keeps complaining, I'm just gonna ignore it for now lol

    return lisp.lisp_to_table(contents)
end
-- end file stuff

return lisp
