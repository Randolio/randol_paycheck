local function AddToPaycheck(cid, amount)
    if not cid and not amount then return end
    local Player = GetByIdentifier(cid)
    local src = GetSourceFromIdentifier(cid)
    local result = MySQL.query.await('SELECT * FROM paychecks WHERE citizenid = ?', {cid})
    if result[1] then
        result[1].amount += amount
        MySQL.update.await('UPDATE paychecks SET amount = ? WHERE citizenid = ?', {result[1].amount, cid})
        if src then
            DoNotification(src, ('$%s was added to your paycheck. New Total: $%s'):format(amount, result[1].amount), 'success')
        end
    else
        MySQL.insert.await('INSERT INTO paychecks (citizenid, amount) VALUE (?, ?)', {cid, amount})
        if src then
            DoNotification(src, ('$%s was added to your paycheck. New Total: $%s'):format(amount, amount), 'success')
        end
    end
end
exports("AddToPaycheck", AddToPaycheck)

RegisterNetEvent('randol_paycheck:server:withdraw', function(amount, accountType)
    local src = source
    local Player = GetPlayer(src)
    local cid = GetPlyIdentifier(Player)
    local result = MySQL.query.await('SELECT * FROM paychecks WHERE citizenid = ?', {cid})

    if not result[1] or tonumber(result[1].amount) < amount then 
        return DoNotification(src, 'You do not have this much in your paycheck.', 'error') 
    end

    result[1].amount -= amount
    MySQL.update.await('UPDATE paychecks SET amount = ? WHERE citizenid = ?', {result[1].amount, cid})

    if accountType == 'cash' then
        AddMoney(Player, 'cash', amount)
        DoNotification(src, ('You withdrew $%s from your paycheck into your wallet.'):format(amount), 'success')
    else
        AddMoney(Player, 'bank', amount)
        DoNotification(src, ('You withdrew $%s from your paycheck into your bank account.'):format(amount), 'success')
    end

    TaskPlayAnim(GetPlayerPed(src), 'friends@laf@ig_5', 'nephew', 8.0, -8.0, -1, 49, 0, false, false, false)
    Wait(2000)
    ClearPedTasks(GetPlayerPed(src))
end)

lib.callback.register('randol_paycheck:server:checkPaycheck', function(source)
    local src = source
    local Player = GetPlayer(src)
    local cid = GetPlyIdentifier(Player)
    local result = MySQL.query.await('SELECT * FROM paychecks WHERE citizenid = ?', {cid})
    local paycheckAmount = 0
    if result[1] then
        paycheckAmount = result[1].amount
    else
        MySQL.insert.await('INSERT INTO paychecks (citizenid, amount) VALUE (?, ?)', {cid, 0})
    end
    return paycheckAmount
end)

AddEventHandler('onServerResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        MySQL.query([=[
            CREATE TABLE IF NOT EXISTS paychecks (
            citizenid varchar(100) NOT NULL,
            amount varchar(50) DEFAULT NULL,
            PRIMARY KEY (citizenid));
        ]=])
    end
end)