-- globals are kinda gross.
-- but probably fine.
-- if not, there's always DI. heh.
_ui = include('lib/_ui')
_midi = include('lib/_midi')
utils = include('lib/utils')
lisp = include('lib/lisp')
core = include('lib/core')
message = include('lib/message')

-- TODO: add debug mode to toggle logging. it's noisy

-- TODO: change this to env creation + reset
--       don't wanna wipe everything, keep e.g. core

function init()
    setup_messages()
    _midi.init()
    redraw_clock_id = clock.run(_ui.redraw_clock)
end

function cleanup()
    clock.cancel(redraw_clock_id)
end

function setup_messages()
    message.identify('enc')
    message.identify('btn')
    message.identify('midi')
    message.identify('midi-add-device')
    message.identify('midi-remove-device')

    lisp.defglobal('menu-open', false)
    -- menus make clear the need to switch envs
    message.attach('btn', {'?',{'&',{'=',1,{'n'}},{'=',1,{'v'}}},
            {'gdef','menu-open',{'!',{'menu-open'}}}})
    message.attach('midi', {'do',
        -- {'print-expr',{'raw'}},
        {'midi',6,{'raw'}}
    })
    -- message.attach('btn', {'?', {'&', {'=', 1, {'n'}}, {'=', 1, {'v'}}},
    --         {'do', 
    --             {'gdef', 'menu-open', {'!', {'menu-open'}}},
    --             {'print-expr', {'smush', 'menu open: ', {'menu-open'}}}
    --         }})
    -- message.attach('btn', 'print-message')
    -- message.attach('enc', 'print-message')

    -- lisp.defglobal('last-num', '(nil)')
    -- message.attach('enc', { 'do', 
    --         {'print-expr', {'smush', "last number: ", {'last-num'}}},
    --         {'gdef', 'last-num', {'value'}}})

    -- message.attach('enc',
    --     {'if',
    --         {'=', 3, {'number'}},
    --         {'print-expr', 'we got a THREE!'},
    --         {'print-expr',
    --             {'smush', "what's '", {'number'}, "' ?" }}})
    
    -- all this MIDI stuff can proooobably get moved to the lib.

    -- this doesn't actually do anything... unless you plug/unplug stuff
    message.attach('midi-add-device', {'print-table', {'env'}})
end

-- can enc/key be defined in a lib? I don't see why not...

-- is it arrogant to change these names?
-- 'enc' is terse but maybe confusing
-- 'key' is definitely confusing alongside HID (keyboard)
function enc(n, v)
    message.transmit('enc', { n=n, v=v })
end

function key(n, v)
    message.transmit('btn', { n=n, v=v })
end

function redraw()
    _ui.draw()
end
