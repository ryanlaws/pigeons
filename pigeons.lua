-- globals are kinda gross.
-- but probably fine.
-- if not, there's always DI. heh.
utils = include('lib/utils')
lisp = include('lib/lisp')
core = include('lib/core')
message = include('lib/message')
ui = include('lib/ui')

-- TODO: add debug mode to toggle logging. it's noisy

-- TODO: change this to env creation + reset
--       don't wanna wipe everything, keep e.g. core
function clear_all()
    -- TODO: rename to handlers
    listeners = {}
        -- knob/enc
        -- UI?
        -- app-level (load, save, init, etc.)?
        -- MIDI
        -- HID
        -- crow?

    env = {}
        -- MIDI
        -- synth
        -- softcut
        -- crow
        -- UI
end

-- function transmit(...)
--     message.transmit(...)
--     redraw()
-- end

function init()
    clear_all()
    setup_messages()
    setup_midi()
    redraw_clock_id = clock.run(ui.redraw_clock)
end

function cleanup()
    clock.cancel(redraw_clock_id)
end

function setup_midi()
    midi.add = function (id, name, dev)
        message.transmit('midi-add-device', { id=id, name=name, dev=dev })
    end
    midi.update_devices()

    -- message.attach('midi', {'print_expr', {'message'}})
    for i, dev in pairs(midi.devices) do
        midi.devices[dev.id].event = function (event)
            local msg = midi.to_msg(event)
            local long_type = 'midi-'..msg.type:gsub("_", "-")
            msg['dev-id'] = dev.id
            msg['dev-name'] = dev.name
            msg['long-type'] = long_type
            msg['raw'] = event
            message.transmit('midi', msg)
            -- message.transmit(long_type, msg) -- have to attach to each :|
        end
    end
end

function setup_messages()
    message.identify('enc')
    message.identify('btn')
    message.identify('midi')

    lisp.defglobal('menu-open', false)
    -- menus make clear the need to switch envs
    message.attach('btn', {'if', {'and',
                {'=', 1, {'number'}},
                {'=', 1, {'value'}}},
            {'do', 
                {'defglobal', 'menu-open', {'not', {'menu-open'}}},
                {'print-expr', {'smush', 'menu open: ', {'menu-open'}}}
            }})
    -- message.attach('btn', 'print-message')
    -- message.attach('enc', 'print-message')

    -- lisp.defglobal('last-num', '(nil)')
    -- message.attach('enc', { 'do', 
    --         {'print-expr', {'smush', "last number: ", {'last-num'}}},
    --         {'defglobal', 'last-num', {'value'}}})

    -- message.attach('enc',
    --     {'if',
    --         {'=', 3, {'number'}},
    --         {'print-expr', 'we got a THREE!'},
    --         {'print-expr',
    --             {'smush', "what's '", {'number'}, "' ?" }}})
    
    -- all this MIDI stuff can proooobably get moved to the lib.

    -- this doesn't actually do anything... unless you plug/unplug stuff
    message.attach('midi-add-device', {'print-expr', {'message'}})
end

-- can enc/key be defined in a lib? I don't see why not...

-- is it arrogant to change these names?
-- 'enc' is terse but maybe confusing
-- 'key' is definitely confusing alongside HID (keyboard)
function enc(i, x)
    message.transmit('enc', { number=i, value=x })
end

function key(i, x)
    message.transmit('btn', { number=i, value=x })
end

function set(name, value)
    env[name] = value
end

function redraw()
    ui.draw()
end
