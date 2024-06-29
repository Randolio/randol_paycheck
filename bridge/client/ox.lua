if GetResourceState('ox_core') ~= 'started' then return end

local Ox = require '@ox_core.lib.init'

function DoNotification(text, nType)
    lib.notify({title = text, type = nType})
end
