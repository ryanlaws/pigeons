local global_env = {}

local base_lisp_path = '/home/we/dust/code/pigeons/'

local tail = function (t, start)
    start = start or 2
    if type(t) ~= 'table' or #t == 0 then return {} end

    local result = {}
    for i=2,#t do
        table.insert(result, t[i])
    end
    return result
end

local function defglobal (name, item)
    print('globally [re]defining '..name..' as:'..Utils.table_to_string(item))
    global_env[name] = item
end

local function expr_to_table (sexpr)
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

local function load_file(filename)
    print('loading '..filename)
    local file = io.open(base_lisp_path..filename..'.plisp', 'r')
    io.input(file)
    local contents = io.read('*all')
    -- io.close() -- this keeps complaining, I'm just gonna ignore it for now lol

    print('loaded '..filename)
    return expr_to_table(contents)
end

local function make_env(env_value_table, parent_env)
    if env_value_table == nil then
        env_value_table = {}
    elseif type(env_value_table) ~= 'table' then 
        error("bad env (type "..type(env_value_table).." - should be table)") 
        return nil -- reachable?
    end

    parent_env = parent_env or global_env

    -- probably not the right way to use metatables.
    -- would be nice to support e.g. pairs() if available.
    local env = setmetatable({}, {
        __index = function(_, k)
            return (env_value_table[k] ~= nil and env_value_table[k]) or parent_env[k]
        end,
        __newindex = function(_, k, v)
            env_value_table[k] = v
        end,
        __parent = parent_env
    })

    return env
end

local function make_exec(lisp)
    -- print('making exec')
    return function (expr)
        if type(expr) ~= 'table' or #expr == 0 then
            return expr
        end

        local head = expr[1]
        if not head then
            error("bogus head")
        end

        local item = lisp.env[head]
        if item == nil then
            return nil -- uhhh, what else?
        elseif type(item) ~= 'function' then -- assuming string/number. what else...?
            -- for functions I think it's the same... but lazy.
            return item
        end

        local args = tail(expr)

        -- be very careful to get your references right... heh
        return item(args, lisp)
    end
end

-- take an environment and return a full lisp out of it.
local function make_lisp(env)
    local function fork(env_value_table)
        -- print('forking')
        return make_lisp(make_env(env_value_table, env))
    end

    local lisp = {
        env=env,
        load_file=load_file,
        expr_to_table=expr_to_table,
        defglobal=defglobal,
        fork=fork,
    }

    lisp.exec = make_exec(lisp)

    lisp.exec_file = function (filename)
        local contents = load_file(filename)
        print('executing '..filename)
        return lisp.exec(contents)
    end

    return lisp
end

return make_lisp(global_env)