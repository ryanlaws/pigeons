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

-- lenses
octatrack = lisp.exec_file('midi-lens/octatrack')

-- TODO: add debug mode to toggle logging. it's noisy

-- TODO: change this to env creation + reset
--       don't wanna wipe everything, keep e.g. core

function init()
    setup_messages()
    _midi.init()
    -- TODO: attach by NAME which is more stable
    -- TODO: do all this in CONFIG. this whole file is really CONFIG
    _midi.add_lens(2, octatrack, {1,2,3,4,5,6,7,8,9}) -- must happen AFTER midi init
    redraw_clock_id = clock.run(_ui.redraw_clock)
end

function cleanup()
    clock.cancel(redraw_clock_id)
end

function setup_messages()
    lisp.defglobal('menu-open', false)
    lisp.defglobal('out-channel', 9) -- OT current track
    -- menus make clear the need to switch envs
    message.attach('btn', {'?',{'&',{'=',1,{'n'}},{'=',1,{'v'}}},
            {'gdef','menu-open',{'!',{'menu-open'}}}})

    local midi_script = utils.load_lisp_file('scripts/ot-beat-repeat')
    message.attach('midi', midi_script)
    
    -- all this MIDI stuff can proooobably get moved to the lib.

    -- this doesn't actually do anything... unless you plug/unplug stuff
    message.attach('midi-add-device', {'print-table', {'env'}})
end

function redraw()
    _ui.draw()
end
