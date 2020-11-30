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
    -- TODO: attach by NAME which is more stable
    -- TODO: do all this in CONFIG. this whole file is really CONFIG
    _midi.add_lens(2, octatrack, {1,2,3,4,5,6,7,8,9}) -- must happen AFTER midi init
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
    lisp.defglobal('robin-counter', 0)
    lisp.defglobal('robin-counter-mod', 6)
    lisp.defglobal('robin-offset', 3)
    lisp.defglobal('out-channel', 9) -- OT current track
    -- menus make clear the need to switch envs
    message.attach('btn', {'?',{'&',{'=',1,{'n'}},{'=',1,{'v'}}},
            {'gdef','menu-open',{'!',{'menu-open'}}}})
    --[[ message.attach('midi', 
        {'?',{'=',{'ch'},16},
            {'do',
                {'def@','raw',1, 
                    {'-', 
                        {'at',{'raw'},1},
                        {'-',16,{'out-channel'}}}},
                {'midi',2,{'raw'}},
                -- {'print-expr', {'+', {'robin-counter'}, {'robin-offset'}}},
                {'midi',{'+', {'robin-counter'}, {'robin-offset'}},{'raw'}},
                {'gdef', 
                    'robin-counter', 
                    {'%', 
                        {'+', {'robin-counter'}, 1}, 
                        {'robin-counter-mod'}}}
            }}
    ) ]]

    -- 
    message.attach('midi', {'do', 
        {'?', {'&', 
                {'=',{'ch'},16},
                {'=',{'type'},'note_on'},
                {'>=',{'@',{'raw'},2},8},
                {'<=',{'@',{'raw'},2},15},
            },
            {'do',
                {'def', 'delay-value', {'@', 
                    {'lit', {7, 15, 23, 31, 47, 63, 95, 127}},
                    {'-', {'@', {'raw'}, 2}, 7}, 
                }},
                -- {'print-expr', {'smush', 'delay value:', {'delay-value'}}},
                {'tx', 'track-fx2', {'pairs', 'n', 1, 'v', {'delay-value'}}}
        -- ['track-fx2']=
        --     {['type']='cc', ['n']={['range']={1,6}, ['offset']=39}},
                -- {'tx', }
            }},
        -- {'print-expr', {'smush', 'channel: ', {'type'}}}
    })
    
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
