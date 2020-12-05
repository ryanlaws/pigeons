-- globals are kinda gross.
-- but probably fine.
-- if not, there's always DI. heh.
_ui = include('lib/_ui')
_midi = include('lib/_midi')
utils = include('lib/utils')
lisp = include('lib/lisp')
core = include('lib/core')
message = include('lib/message')

-- global definitions (for attaching events)
include('lib/norns-pigeons-messages')

-- TODO: add debug mode to toggle logging. it's noisy

-- TODO: change this to env creation + reset
--       don't wanna wipe everything, keep e.g. core

function init()
    _midi.init()
    -- where the magic happens
    lisp.exec_file('app/main')
    lisp.exec_file('config')

    redraw_clock_id = clock.run(_ui.redraw_clock)
end

function cleanup()
    clock.cancel(redraw_clock_id)
end

function redraw()
    _ui.draw()
end
