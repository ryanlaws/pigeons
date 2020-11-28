-- globals are kinda gross.
-- but probably fine.
-- if not, there's always DI. heh.
_ui = include('lib/_ui')
_midi = include('lib/_midi')
utils = include('lib/utils')
lisp = include('lib/lisp')
core = include('lib/core')
message = include('lib/message')

-- lenses
octatrack = include('midi-lens/octatrack')

-- TODO: add debug mode to toggle logging. it's noisy

-- TODO: change this to env creation + reset
--       don't wanna wipe everything, keep e.g. core

function init()
    setup_messages()
    _midi.init()
    _midi.add_lens(2, octatrack) -- must happen AFTER midi init
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
    lisp.defglobal('out-channel', 9) -- OT current track
    -- menus make clear the need to switch envs
    message.attach('btn', {'?',{'&',{'=',1,{'n'}},{'=',1,{'v'}}},
            {'gdef','menu-open',{'!',{'menu-open'}}}})
    message.attach('midi', 
        {'?',{'=',{'ch'},16},
            {'do',
                {'defk','raw',1, 
                    {'-', 
                        {'at',{'raw'},1},
                        {'-',16,{'out-channel'}}}},
                {'midi',6,{'raw'}}}}
    )
    
    -- all this MIDI stuff can proooobably get moved to the lib.

    -- this doesn't actually do anything... unless you plug/unplug stuff
    message.attach('midi-add-device', {'print-table', {'env'}})

end

-- can enc/key be defined in a lib? I don't see why not...

-- is it arrogant to change these names?
-- 'enc' is terse but maybe confusing
-- 'key' is definitely confusing alongside HID (keyboard)
function enc(n, v)
    message.transmit('enc', { n=n, v=v }, 'panel')
end

function key(n, v)
    message.transmit('btn', { n=n, v=v }, 'panel')
end

function redraw()
    _ui.draw()
end
