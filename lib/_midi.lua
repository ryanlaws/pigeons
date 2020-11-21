local _midi = {}

local dev_ids = {}

local function connect_device(id, name) 
    if dev_ids[id] then
        return
    end

    local function handler(event)
        local msg = midi.to_msg(event)
        local long_type = 'midi-'..msg.type:gsub("_", "-")
        msg['dev-id'] = id
        msg['dev-name'] = name
        msg['long-type'] = long_type
        msg['raw'] = event
        message.transmit('midi', msg)
    end

    -- print("oh hi")
    -- print(id == nil and "NIL!!" or id)
    dev_ids[id] = handler
    midi.devices[id].event = handler
end

_midi.init = function ()
    midi.add = function (dev)
        message.transmit('midi-add-device', dev)
        connect_device(dev.id, dev.name)
    end

    midi.remove = function (...)
        local args = table.pack(...)
        print("removing midi device - #args="..#args)
        dev_ids[dev.id] = nil
        message.transmit('midi-remove-device', dev)
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