if GetResourceState('qb-core') ~= 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

function GetPlayer(id)
    return QBCore.Functions.GetPlayer(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('QBCore:Notify', src, text, nType)
end

function GetPlyIdentifier(Player)
    return Player.PlayerData.citizenid
end

function GetByIdentifier(cid)
    return QBCore.Functions.GetPlayerByCitizenId(cid)
end

function GetSourceFromIdentifier(cid)
    local Player = QBCore.Functions.GetPlayerByCitizenId(cid)
    return Player and Player.PlayerData.source or false
end

function GetCharacterName(Player)
    return Player.PlayerData.charinfo.firstname.. ' ' ..Player.PlayerData.charinfo.lastname
end

function AddMoney(Player, account, amount)
    Player.Functions.AddMoney(account, amount, "paycheck-withdraw")
end