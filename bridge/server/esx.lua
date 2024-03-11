if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

function GetPlayer(id)
    return ESX.GetPlayerFromId(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('esx:showNotification', src, text, nType)
end

function GetPlyIdentifier(xPlayer)
    return xPlayer.identifier
end

function GetByIdentifier(cid)
    return ESX.GetPlayerFromIdentifier(cid)
end

function GetSourceFromIdentifier(cid)
    local xPlayer = ESX.GetPlayerFromIdentifier(cid)
    return xPlayer and xPlayer.source or false
end

function GetCharacterName(xPlayer)
    return xPlayer.getName()
end

function AddMoney(xPlayer, account, amount)
    if account == 'cash' then account = 'money' end
    xPlayer.addAccountMoney(account, amount, "paycheck-withdraw")
end