local utils = {}

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

return utils
