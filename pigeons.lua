local utils = include('lib/utils')
local core = include('lib/core')
local message = include('lib/message')
local lisp = include('lib/lisp')

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

    lisp.defn('print_message', core.print_message)
    lisp.defn('print_expr', core.print_expr)
    lisp.defn('smush', core.smush)
    lisp.defn('if', core.cond)
    lisp.defn('=', core.eq)
    lisp.defn('message_prop', core.message_prop)

    message.identify('encoder')
    message.identify('button')

    message.attach('encoder', 'print_message')
    message.attach('encoder',
        { 'if',
            { '=', 3,  { 'message_prop', 'number' } },
            { 'print_expr', 'we got a THREE!'},
            { 'print_expr',
                { 'smush', "what's '", { 'message_prop', 'number' }, "' ?" }}})
    message.attach('button', 'print_message')
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
