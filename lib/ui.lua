local ui = {}

local font_size = 8
local spinner = {'-', '\\', '|', '/' }
local spinner_pixels = {
    '543210',
    '6    9',
    '7    8',
    '8    7',
    '9    6',
    '012345'
}

ui.dirty = true
ui.fps = 30

ui.draw_spinner = function(x, y, frame)
    screen.line_width(1)
    frame = (''..frame)
    for row=1,#spinner_pixels do
        for col=1,6 do
            local value = spinner_pixels[row]:sub(col, col)
            if value == ' ' then
                screen.level(0)
            elseif value == frame then
                screen.level(15)
            else
                screen.level(1)
            end
            screen.pixel(x + row, y + col)

            screen.fill()
        end
    end
end

ui.draw = function ()
    screen:ping()
    screen.clear()
    screen.font_size(font_size)
    screen.level(15)

    if #message.logs == 0 then
        screen.move(0, font_size)
        screen.text("Hello,")
        return
    end

    for i=1,#message.logs do
        local msg = message.logs[i].message
        local spinner_index = message.logs[i].spinner_index
        ui.draw_spinner(0, font_size * (i - 1) + 1, spinner_index)

        -- screen.move(0, font_size * i)
        -- screen.text(spinner[spinner_index])

        screen.level(15)
        screen.move(8, font_size * i - 1)
        screen.text(ui.message_to_string(msg))
    end

    screen.stroke()
    screen.update()
end

ui.redraw_clock = function ()
    while true do
        if ui.dirty then 
            redraw() 
            ui.dirty = false
        end
        clock.sleep(1 / ui.fps)
    end
end

-- dumb. TODO: please use lisp for this. ugh
local norns_to_str = function (t) 
    return function (m)
        return t..' #'..m.number..': '..m.value 
    end
end

local midi_to_str = function (m) 
    local s = ' '
    return m['long-type']
        ..s..(m.raw[1] or s)
        ..s..(m.raw[2] or s)
        ..s..(m.raw[3] or s)
end

local empty = function () return '' end

ui.message_to_string = function (m)
    local fn = ({
        enc=norns_to_str('enc'),
        btn=norns_to_str('btn'),
        midi=midi_to_str,
        unknown=function() return m.message_type end
    })[m.message_type or 'unknown']
    -- print(type(fn))
    return fn(m.message)
end

return ui