local _midi = {}

local dev_names = {}
local lenses = {}

-- TODO: split lens code out... probably

_midi.add_lens = function(id, lens_def)
    -- use config to set defaults, etc.
    -- for each message type:
        -- attach MIDI rx to tx lens message
        -- attach lens message rx to tx MIDI

    --[[
        how to compensate for feedback?
        - add & check e.g. "origin" to message?
        - use special handlers to avoid midi tx?
        - "from"/"to" message prefixes?
        I think "origin" is the one, could be:
        - midi
        - lisp
        - lua
    --]]

    -- this is so cheesy it hurts but yagni, etc.
    local channel = lens_def.config['default-channel']
    local short_name = lens_def['short-name']

    -- prep a table for easy lookup
    local lens = {}
    for msg_type, spec in pairs(lens_def.messages) do
        if not lens[spec.type] then lens[spec.type] = {} end

        -- kinda tacky, mutates the source
        -- probably better to copy
        spec.message_type = msg_type

        if type(spec.n) == 'number' then
            if lens[spec.type][spec.n] then
                error("already got lens["..spec.type
                    .."]["..spec.n.."], yikes!")
            end
            lens[spec.type][spec.n] = spec
        elseif type(spec.n) == 'table' then
            local offset = spec.n.offset or 0
            for i=spec.n.range[1],spec.n.range[2] do
                if lens[spec.type][i + offset] then
                    error("already got lens["..spec.type
                        .."]["..(i + offset).."], yikes!")
                end
                lens[spec.type][i + offset] = spec
            end
        else
            error("your spec doesn't have an .n, bud")
        end
    end

    -- attach handler
    local fallback = _midi.make_tx_basic(id, dev_names[id])
    print('attaching midi device '..id..' to lens '..lens_def['long-name'])

    midi.devices[id].event = function (raw)
        local msg = midi.to_msg(raw)

        if msg.type == 'clock' then return end -- no thanks, not right now.

        local lookup_type = msg.type
        if (lookup_type == 'note_off') or (lookup_type == 'note_on') then
            lookup_type = 'note'
        end

        local spec = (lens[lookup_type] or {})[raw[2]] or nil
        if spec == nil then 
            print('nil spec!')
            return fallback(raw) 
        end

        local n_offset = spec.n.offset or 0
        local n = raw[2] - n_offset

        local v_offset = (spec.v and spec.v.offset) or 0
        local v = math.min(math.max(raw[3] - v_offset, 0), 127)

        message.transmit(spec.message_type, { n=n, v=v }, 'midi')
    end
    print('attached midi device '..id..' to lens '
        ..lens_def['long-name']..' ...maybe?')
    -- ...I'll clean it up later. maybe.
end

local function is_lensed (id)
    return lenses[id] ~= nil
end

local function tx_lens_event (event)
    return false -- fall back to regular MIDI event
end

_midi.make_tx_basic = function (dev_id, dev_name)
    return function (event)
        local msg = midi.to_msg(event)
        local long_type = 'midi-'..msg.type:gsub("_", "-")
        msg['dev-id'] = dev_id
        msg['dev-name'] = dev_name
        msg['long-type'] = long_type
        msg['raw'] = event
        message.transmit('midi', msg, 'midi')
    end
end

local function connect_device(id, name) 
    -- may want to use name instead of ID for lens.
    -- ID seems to be new on every connect
    if dev_names[id] then
        return
    end

    -- TODO: check condition outside, not on each event.
    -- can have one handler for the whole lens, so nbd.
    -- this is "default" - can reassign as needed
    print('attaching midi device '..id..' to default handler')
    midi.devices[id].event = _midi.make_tx_basic(id, name)
    dev_names[id] = name
end

_midi.init = function ()
    midi.add = function (dev)
        message.transmit('midi-add-device', dev, 'usb') -- usb origin seems weird
        connect_device(dev.id, dev.name)
    end

    midi.remove = function (...)
        local args = table.pack(...)
        print("removing midi device - #args="..#args)
        dev_names[dev.id] = nil
        message.transmit('midi-remove-device', dev, 'usb') -- usb origin seems weird
    end

    midi.cleanup()
    midi.update_devices()

    print("MIDI device IDs:")
    for i, dev in pairs(midi.devices) do
        print("ID #"..dev.id..".) "..dev.name
            ..(midi.devices[dev.id] and " OK!" or " BROKEN!"))
        connect_device(dev.id, dev.name)
    end
end

return _midi