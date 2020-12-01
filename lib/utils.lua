local utils = {}

local base_script_path = '/home/we/dust/code/pigeons/scripts/'

utils.tail = function (t, start)
    start = start or 2
    if type(t) ~= 'table' or #t == 0 then return {} end

    local result = {}
    for i=2,#t do
        table.insert(result, t[i])
    end
    return result
end

utils.warn = function (...)
    print("warn:", ...)
end

utils.table_to_string = function (table, depth)
    depth = depth or 0

    if type(table) == 'string' or type(table) == 'number' then
        return table
    elseif table == nil then
        return "(nil)"
    elseif type(table) == 'string' then
        return "("..type(table)..")"
    end

    local str = '{\n'
    local indent = ''
    -- TODO: find a string function that does this for me
    for i = 1, depth do
        indent = indent.."  "
    end

    if #table > 0 then
        -- array
        for i=1, #table do
            str = str..'\n'..indent.."  "
            str = str..utils.table_to_string(table[i], depth + 1)..'\n'
        end
    else
        -- dict
        for k, v in pairs(table) do
            str = str..'\n'..indent.."  "
            if type(k) ~= 'number' then
                str = str..k..' = '
            end
            str = str..utils.table_to_string(v, depth + 1)..'\n'
        end
    end
    return str..indent..'}'
end

utils.load_lisp_file = function (filename)
    local file = io.open(base_script_path..filename, 'r')
    io.input(file)
    local contents = io.read('*all')
    
    -- wrap words in single quotes (end w/ digit(s) is OK)
    contents = string.gsub(contents, '([^%(%)0-9%s][^%(%)%s]*)', "'%0'")
    -- parens to curlies
    contents = string.gsub(contents, '%(', '{')
    contents = string.gsub(contents, '%)', '}')
    -- contiguous whitespace to single comma
    contents = string.gsub(contents, '%s+', ',')
    
    local fn, err = load('return '..contents)
    if err then
        io.close()
        error("error loading "..filename..":\n"..err)
    end

    local table = fn()
    io.close()
    return table
end

return utils
