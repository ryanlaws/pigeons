-- is it arrogant to change these names?
-- 'enc' is terse but maybe confusing
-- 'key' is definitely confusing alongside HID (keyboard)
function enc(n, v)
    Message.transmit('enc', { n=n, v=v }, 'panel')
end

function key(n, v)
    Message.transmit('btn', { n=n, v=v }, 'panel')
end