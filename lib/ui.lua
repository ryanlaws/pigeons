local ui = {}

local font_size = 8
local spinner = {'-', '\\', '|', '/' }
local spinner_pixels = {
    '  CB  ',
    ' D  A ',
    'E    L',
    'F    K',
    ' G  J ',
    '  HI  '
}

ui.dirty = true
ui.fps = 30

ui.draw_spinner = function(x, y, frame)
    local points = {}
    screen.line_width(1)
    frame = string.char(65 + frame)
    for row=1,#spinner_pixels do
        for col=1,6 do
            local value = spinner_pixels[row]:sub(col, col)
            if value == ' ' then
                screen.level(0)
            elseif value == frame then
                table.insert(points, { x=x+row, y=y+col })
                screen.level(15)
            else
                screen.level(0)
            end
            screen.pixel(x + row, y + col)
            screen.fill()
        end
    end
end

ui.draw_checkers = function()
    screen.line_width(1)
    screen.level(0)
    for x=1,128 do
        for y=1,64 do
            local drawable = ((x % 2) ~ (y % 2))
            if drawable == 1 then
                screen.pixel(x, y)
                screen.fill()
            end
        end
    end
end

ui.draw = function ()
    screen:ping()
    screen.clear()
    screen.font_size(font_size)
    screen.font_face(1)
    screen.level(15)

    if #message.logs == 0 then
        screen.move(0, font_size)
        screen.text("Hello,")
        screen.stroke()
        screen.update()
        return
    end

    for i=1,#message.logs do
        local msg = message.logs[i].message
        local spinner_index = message.logs[i].spinner_index
        ui.draw_spinner(0, (font_size - 1) * (i - 1) + 1, spinner_index)

        screen.level(15)
        screen.move(11, (font_size - 1) * i)
        screen.text(ui.message_to_string(msg))
    end

    if lisp.exec({ 'menu-open' }) then
        ui.draw_menu()
    end

    screen.stroke()
    screen.update()
end

ui.draw_menu = function ()
    local gutter = 3
    local bevel = 2
    ui.draw_checkers()
    screen.level(0)
    screen.rect(gutter + 1, 
        gutter + 1, 
        128 - 2 * gutter, 
        64 - 2 * gutter
    )
    screen.fill()

    local flex = gutter + bevel + 1
    screen.level(2)
    screen.rect(
        flex,
        flex, 
        128 - 2 * (gutter + bevel), 
        64 - 2 * (gutter + bevel)
    )
    screen.stroke()

    screen.level(15)
    screen.move(flex + 5, flex + font_size + 1)
    screen.text("pigeons.")
    screen.move(flex + 5, flex + font_size * 2 + 2)
    screen.text("(insert useful menu here)")
    screen.stroke()

    print(core.join({ core['expr-to-s-list']({ message.listeners.btn[1] }) }))

    screen.clear()
    screen.font_face(2)
    screen.level(3)
    screen.move(0, font_size)
    screen.text("(if (and (= 1 (number)) (= 1 (value)))")
    screen.move(0, font_size * 2)
    screen.text("    (do (defglobal menu-open (not (menu-open)))")
    screen.move(0, font_size * 3)
    screen.text("        (print-expr (smush menu open: (menu-open)))))")
    screen.stroke()
    -- print(utils.table_to_string(message.listeners.btn[1]))
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
        return t..' #'..m.n..': '..m.v 
    end
end

local midi_to_str = function (m) 
    local s = ' '
    -- return m['long-type']
    return m['type']
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
    return fn(m)
end

--[[
    Idea for expression editor:

    - select the position (l-r)
    - left-hand of expr goes up top
    - right-hand of expr goes down low
    - editing thing is in the middle
        - with a scrolly menu to choose op
    - some shortcuts for:
        - switch btw. # or string or expr
        - select position
        - save
        - exit

    The core commands need to be shortened
    The screen only fits a small amount of text
    One immediate challenge there is auto-indenting
    Could probably use parens to inc/dec indent level
    Highlighting matching braces would be nice

    There will probably be at least 3 "modes" or screens:
    - monitor/log/recorder
    - property selector/sampler
    - script editor
    I'm not sure yet how these relate
]]

return ui