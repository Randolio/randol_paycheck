local function AddToPaycheck(cid, amount)
    if not cid and not amount then return end
    local Player = QBCore.Functions.GetPlayerByCitizenId(cid)
    local result = MySQL.query.await('SELECT * FROM paychecks WHERE citizenid = ?', {cid})
    if result[1] then
        result[1].amount += amount
        MySQL.Async.execute('UPDATE paychecks SET amount = ? WHERE citizenid = ?', {result[1].amount, cid})
        if Player then
            QBCore.Functions.Notify(Player.PlayerData.source, '$'..amount..' was added to your paycheck. New Total: $'..result[1].amount, 'success')
        end
    else
        MySQL.insert.await('INSERT INTO paychecks (citizenid, amount) VALUE (?, ?)', {cid, amount})
        if Player then
            QBCore.Functions.Notify(Player.PlayerData.source, '$'..amount..' was added to your paycheck. New Total: $'..amount, 'success')
        end
    end
end
exports("AddToPaycheck", AddToPaycheck)

RegisterNetEvent('randol_paycheck:server:withdraw', function(amount, accountType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT * FROM paychecks WHERE citizenid = ?', {cid})
    if not result[1] then return end
    if tonumber(result[1].amount) < amount then
        QBCore.Functions.Notify(src, "You don't have this much in your paycheck.", "error")
        return
    end

    local taxRate = Config.TaxRate -- Assuming a flat tax rate of 10%
    local taxAmount = amount * taxRate
    local finalAmount = amount - taxAmount

    result[1].amount = result[1].amount - math.floor(finalAmount)
    MySQL.Async.execute('UPDATE paychecks SET amount = ? WHERE citizenid = ?', {result[1].amount, cid})

    if accountType == 'cash' then
        Player.Functions.AddMoney('cash', math.floor(finalAmount), 'Paycheck Withdrawal')
        QBCore.Functions.Notify(src, 'You withdrew $' .. math.floor(finalAmount) .. ' from your paycheck into your wallet. (Tax: $' .. taxAmount .. ')', 'success')
        MySQL.Async.execute('UPDATE paychecks SET amount = ? WHERE citizenid = ?', {0, cid})
    else
        Player.Functions.AddMoney('bank', math.floor(finalAmount), 'Paycheck Withdrawal')
        QBCore.Functions.Notify(src, 'You withdrew $' .. math.floor(finalAmount) .. ' from your paycheck into your bank account. (Tax: $' .. taxAmount .. ')', 'success')
        MySQL.Async.execute('UPDATE paychecks SET amount = ? WHERE citizenid = ?', {0, cid})
    end
    TaskPlayAnim(GetPlayerPed(src), 'friends@laf@ig_5', 'nephew', 8.0, -8.0, -1, 49, 0, false, false, false)
    Wait(2000)
    ClearPedTasks(GetPlayerPed(src))
end)

lib.callback.register('randol_paycheck:server:checkPaycheck', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT * FROM paychecks WHERE citizenid = ?', {cid})
    local paycheckAmount = 0
    if result[1] then
        paycheckAmount = result[1].amount
    else
        MySQL.insert.await('INSERT INTO paychecks (citizenid, amount) VALUE (?, ?)', {cid, 0})
    end
    return paycheckAmount
end)

--[[
    The export below you can use instead of doing: Player.Functions.AddMoney('bank', amount) when adding money rewards from legal jobs etc.

    exports['randol_paycheck']:AddToPaycheck(Player.PlayerData.citizenid, amount)
]]