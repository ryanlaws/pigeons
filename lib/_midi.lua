local _midi = {}

_midi.init = function ()
    midi.add = function (id, name, dev)
        message.transmit('midi-add-device', { id=id, name=name, dev=dev })
    end

    midi.update_devices()

    for i, dev in pairs(midi.devices) do
        midi.devices[dev.id].event = function (event)
            local msg = midi.to_msg(event)
            local long_type = 'midi-'..msg.type:gsub("_", "-")
            msg['dev-id'] = dev.id
            msg['dev-name'] = dev.name
            msg['long-type'] = long_type
            msg['raw'] = event
            message.transmit('midi', msg)
        end
    end
end

return _midi