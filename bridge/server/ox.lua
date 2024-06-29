if GetResourceState('ox_core') ~= 'started' then return end

local Ox = require '@ox_core.lib.init'

function GetPlayer(id)
    return Ox.GetPlayer(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('ox_lib:notify', src, {title = text, type = nType})
end

function CustomBanking(Player, amount)
-- Empty for now
end

function GetPlyIdentifier(Player)
    return Player.stateId
end

function GetByIdentifier(cid)
    return Ox.GetPlayer(cid)
end

function GetSourceFromIdentifier(cid)
    local Player = Ox.GetPlayer(cid)
    return Player and Player.source or false
end

function GetCharacterName(Player)
    return Player.firstName.. ' ' ..Player.lastName
end

function AddMoney(Player, account, amount)
    if account == "cash" then
        exports.ox_inventory:AddItem(Player, 'money', amount)
    elseif account == "bank" then
    -- CustomBanking() -- Uncomment this for custom banking (found at the top!)
    exports.pefcl:addBankBalance(Player, { amount = amount, message = 'Paycheck' })
    else return end
end