-- globals are kinda gross.
-- but probably fine.
-- if not, there's always DI. heh.
utils = include('lib/utils')
lisp = include('lib/lisp')
core = include('lib/core')
message = include('lib/message')

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

function init()
    clear_all()

    message.identify('encoder')
    message.identify('button')

    -- message.attach('button', 'print_message')
    -- message.attach('encoder', 'print_message')
    lisp.defglobal('last-num', '(nil)')
    message.attach('encoder', {'print_expr', {'smush', "last number: ", {'last-num'}}})
    message.attach('encoder', {'defglobal', 'last-num', {'message_prop', 'value'}})
    message.attach('encoder',
        {'if',
            {'=', 3, {'message_prop', 'number' }},
            {'print_expr', 'we got a THREE!'},
            {'print_expr',
                {'smush', "what's '", {'message_prop', 'number'}, "' ?" }}})
end

-- is it arrogant to change these names?
-- 'enc' is terse but maybe confusing
-- 'key' is definitely confusing alongside HID (keyboard)
function enc(i, x)
    message.transmit('encoder', { number=i, value=x })
end

function key(i, x)
    message.transmit('button', { number=i, value=x })
end

function set(name, value)
    env[name] = value
end
