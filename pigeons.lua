-- globals are kinda gross.
-- but probably fine.
-- if not, there's always DI. heh.
_Ui = include('lib/_ui')
_Midi = include('lib/_midi')
Utils = include('lib/utils')
Lisp = include('lib/lisp')
Core = include('lib/core')
Message = include('lib/message')

-- global definitions (for attaching events)
include('lib/norns-pigeons-messages')

-- TODO: add debug mode to toggle logging. it's noisy

-- TODO: change this to env creation + reset
--       don't wanna wipe everything, keep e.g. core

local redraw_clock_id

function init()
    _Midi.init()
    -- where the magic happens
    Lisp.exec_file('app/main')
    Lisp.exec_file('config')

    redraw_clock_id = clock.run(_Ui.redraw_clock)
end

function cleanup()
    clock.cancel(redraw_clock_id)
end

function redraw()
    _Ui.draw()
end
