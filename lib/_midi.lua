local _midi = {}

local dev_names = {}
local lenses = {}
local lensed_ports = {}

local lens_to_midi_defined = false

-- TODO: split lens code out... probably
_midi.add_lens = function(port_id, lens_def, lens_channels)
    -- use config to set defaults, etc.
    -- for each message type:
        -- attach MIDI rx to tx lens message
        -- attach lens message rx to tx MIDI

    -- ugly ugly ugly. pull these apart, use DI, whatever.

    if not lens_to_midi_defined then
        print('defining lens-to-midi')
        lisp.defglobal('lens-to-midi', _midi['lens_to_midi'])
        lens_to_midi_defined = true
    end

    -- there's gotta be a less gross way of doing this, heh
    local lens_channels = lens_channels or {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
    local channels = {}
    for i=1,#lens_channels do
        channels[lens_channels[i]] = true
    end

    -- this is so cheesy it hurts but yagni, etc.
    local channel = lens_def.config['default-channel']
    local short_name = lens_def['short-name']

    -- prep a table for easy lookup
    local lens = {}

    local modes = {}
    local mode = 'default'

    -- iterate over all messages
    for msg_type, spec in pairs(lens_def.messages) do
        if not lens[spec.type] then lens[spec.type] = {} end

        -- kinda tacky, mutates the source
        -- probably better to copy
        spec.message_type = msg_type

        -- add the spec to the table under the key
        local spec_mode = spec.mode or 'default'
        if type(spec.n) == 'number' then
            if not lens[spec.type][spec.n] then
                lens[spec.type][spec.n] = {}
            end

            if lens[spec.type][spec.n][spec_mode] then
                error("already got lens["..spec.type
                    .."]["..spec.n.."], yikes!")
            end
            --print("associating "..spec.type.." #"..spec.n.." for mode "
            --    ..(spec.mode or "(default)").." with "..msg_type)
            lens[spec.type][spec.n][spec_mode] = spec
        elseif type(spec.n) == 'table' then
            local offset = spec.n.offset or 0
            for i=spec.n.range[1],spec.n.range[2] do
                if not lens[spec.type][i + offset] then
                    lens[spec.type][i + offset] = {}
                end

                if lens[spec.type][i + offset][spec_mode] then
                    print("ABOUT TO BREAK trying to associate "
                        ..spec.type.." #"..(i + offset).." with "..msg_type)
                    error("already got lens["..spec.type
                        .."]["..(i + offset).."], yikes!")
                end
                lens[spec.type][i + offset][spec_mode] = spec
                --print("associating "..spec.type.." #"..(i + offset).." with "
                --    ..msg_type.." for mode "..(spec.mode or "(default)"))
            end
        else
            error("your spec doesn't have an .n, bud")
        end

        modes[spec_mode] = true

        -- attach a message listener for that type
        -- TODO: make lenses work w/ multiple devices
        -- I really wanna implement this in lisp but it's not time yet :(
        -- also... how does this get the port? heh
        message.attach(msg_type, {'lens-to-midi', port_id, short_name })
    end

    -- seems to be the point where all the errors would've been thrown
    lenses[short_name] = {
        ['def']=lens_def,
        ['mode']=mode,
        ['modes']=modes
    }

    -- attach handler to MIDI event
    local fallback = _midi.make_tx_basic(port_id, dev_names[port_id])
    print('preparing to attach midi device '..port_id
        ..' to lens '..lens_def['long-name'])

    if not midi.devices[port_id] then
        utils.warn('device port_id '..(port_id or nil).." nonexistent; won't lens.")
        return
    end

    -- kind of a beast! pull it out and put it somewhere better...
    midi.devices[port_id].event = function (raw)
        local msg = midi.to_msg(raw)

        if msg.type == 'clock' then return end -- no thanks, not right now.

        -- pretty tacky. can't toggle lensing of non-channeled messages. 
        if msg.ch and (not channels[msg.ch]) then
            -- print('channel '..msg.ch..' is not lensed')
            return fallback(raw)
        end

        local lookup_type = msg.type
        if (lookup_type == 'note_off') or (lookup_type == 'note_on') then
            lookup_type = 'note'
        end

        local lens_mode = lenses[short_name].mode or 'default'

        local spec = (lens[lookup_type] or {})[raw[2]] or nil
        if spec == nil then 
            -- print('nil spec!') -- real noisy
            return fallback(raw) 
        end

        print('looking up mode '..lens_mode..' in:')
        print(utils.table_to_string(spec))
        if not spec[lens_mode] then
            print('it was not found! reverting to default')
        end
        local mode_spec = spec[lens_mode] or spec.default
        if mode_spec == nil then 
            print('no lens message found. falling back to regular MIDI')
            -- print('nil spec!') -- real noisy
            return fallback(raw) 
        end
        --print('lens short name')
        print(short_name)
        print('lens mode')
        print(lens_mode)
        print('spec:')
        --local mode_spec = spec[lenses[short_name].mode or 'default']
        --print('mode_spec type '..type(mode_spec))
        --print('mode_spec n type '..type(mode_spec.n))
        print(utils.table_to_string(mode_spec))
        print('mode_spec message_type '..((mode_spec and mode_spec.message_type) or '(nil)'))

        local n_offset = 0
        if type(mode_spec.n) == 'number' then
            n_offset = 0
        elseif mode_spec.n.offset then
            n_offset = mode_spec.n.offset
        end

        local n = raw[2] - n_offset

        local v_offset = (mode_spec.v and mode_spec.v.offset) or 0
        local v = math.min(math.max(raw[3] - v_offset, 0), 127)

        message.transmit(mode_spec.message_type, { n=n, v=v }, 'midi')
    end
    print('attached midi device '..(port_id or '(nil)')..' to lens '
        ..((lens_def and lens_def['long-name']) or '(nil)')..' ...maybe?')
    -- ...I'll clean it up later. maybe.
end

_midi.lens_to_midi = function (args, env)
    -- print("message_type = "..env.message_type)
    -- print("origin = "..env.origin)
    -- print("n = "..env.n)
    -- print("v = "..env.v)

    -- it's pretty tacky to assume "n" or "v" I guess
    -- it should really depend on the MIDI msg type being lensed
    if (not env.n) or (not env.v) or (type(env.message_type) ~= 'string') then
        error('malformed lens message')
    end

    local msg_type = env.message_type
    local msg_n = env.n
    local msg_v = env.v

    local port_id = args[1]
    local lens_name = args[2]
    if type(port_id) ~= 'number' then
        error('port_id aint a number')
    end

    if type(lens_name) ~= 'string' then
        error('lens_name aint a string')
    end

    if not lenses[lens_name] then
        error('no lens called '..lens_name)
    end

    lens = lenses[lens_name].def

    if not lens.messages then
        error('\nsomething wrong with yr lens')
    end

    local msg = lens.messages[msg_type]
    if not msg then
        error('\nlens doesnt have a message '..msg_type)
    end

    local midi_type = msg.type
    if not midi_type then
        error('\nlens '..lens_name..' message def '..msg_type
            ..' is missing MIDI message type')
    elseif midi_type == 'note' then
        midi_type = v == 0 and 'note_off' or 'note_on'
    end

    local midi_n = msg.n
    if type(midi_n) == 'table' then
        if (type(msg.n.range[1]) ~= 'number') 
            or (type(msg.n.range[2]) ~= 'number') 
            or (msg.n.range[1] >= msg.n.range[2]) 
        then
            error('bad n range')
        end

        midi_n = util.clamp(env.n, msg.n.range[1], msg.n.range[2])

        local offset = ((type(msg.n.offset) == 'number') and msg.n.offset) or 0

        --if type(msg.n.offset) ~= 'number' then
        --    error('bad n offset (type '..type(msg.offset)..')')
        --end
        midi_n = midi_n + offset
    elseif midi_n == nil then
        midi_n = env.n
    end

    if type(midi_n) ~= 'number' then
        error('could not get a decent n value')
    end

    midi_n = util.clamp(math.ceil(midi_n), 0, 127)

    local midi_v = msg.v

    if type(midi_v) == 'table' then
        if (type(msg.v.range[1]) ~= 'number') 
            or (type(msg.v.range[2]) ~= 'number') 
            or (msg.v.range[1] >= msg.v.range[2]) 
        then
            error('bad v range')
        end
        midi_v = util.clamp(env.v, msg.v.range[1], msg.v.range[2])

        if type(msg.v.offset) ~= 'number' then
            error('bad v offset (type '..type(msg.v.offset)..')')
        end
        midi_v = midi_v + msg.v.offset
    elseif midi_v == nil then
        midi_v = env.v
    end

    if type(midi_v) ~= 'number' then
        error('could not get a decent n value')
    end

    midi_v = util.clamp(math.ceil(midi_v), 0, 127)

    local device = type(port_id) == 'number' and midi.devices[port_id] or nil
    if device == nil then 
        error("bogus MIDI device ID!")
    end

    if type(device[midi_type]) ~= 'function' then
        error(midi_type..' does not appear to be a valid MIDI message type')
    end

    -- TODO: allow assigning other channels, either by spec or env
    local channel = lens.config['default-channel']

    device[midi_type](device, midi_n, midi_v, channel)

    -- TODO: implement non-channeled message types


    -- device:send(lisp.exec(args[2], env))

    -- and now we get to work
end

local function is_lensed (id)
    return lensed_ports[id] ~= nil
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
    -- print('attaching midi device '..id..' to default handler')
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

_midi.set_lens_mode = function(lens_name, mode_name)
    if not lenses[lens_name] then
        error('no such lens: '..lens_name)
    end

    if not lenses[lens_name].modes[mode_name] then
        error('no such mode '..mode_name..' for lens: '..lens_name)
    end

    lenses[lens_name].mode = mode_name
end

return _midi