## Requirements

[ox_lib](https://github.com/overextended/ox_lib/releases)

## Showcase

[showcase](https://streamable.com/t7czpi)

# QBCore Install.

**IF USING THE LATEST QBCORE UPDATE THAT MOVED SOCIETY FUNDS TO QB-BANKING, Go to qb-core/server/functions.lua and replace PaycheckInterval() code with mine below.**

```lua
function PaycheckInterval()
    if next(QBCore.Players) then
        for _, Player in pairs(QBCore.Players) do
            if Player then
                local payment = QBShared.Jobs[Player.PlayerData.job.name]['grades'][tostring(Player.PlayerData.job.grade.level)].payment
                if not payment then payment = Player.PlayerData.job.payment end
                if Player.PlayerData.job and payment > 0 and (QBShared.Jobs[Player.PlayerData.job.name].offDutyPay or Player.PlayerData.job.onduty) then
                    if QBCore.Config.Money.PayCheckSociety then
                        local account = exports['qb-banking']:GetAccountBalance(Player.PlayerData.job.name)
                        if account ~= 0 then -- Checks if player is employed by a society
                            if account < payment then -- Checks if company has enough money to pay society
                                TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('error.company_too_poor'), 'error')
                            else
                                exports.randol_paycheck:AddToPaycheck(Player.PlayerData.citizenid, payment)
                                exports['qb-banking']:RemoveMoney(Player.PlayerData.job.name, payment, 'Employee Paycheck')
                                TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                            end
                        else
                            exports.randol_paycheck:AddToPaycheck(Player.PlayerData.citizenid, payment)
                            TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                        end
                    else
                        exports.randol_paycheck:AddToPaycheck(Player.PlayerData.citizenid, payment)
                        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                    end
                end
            end
        end
    end
    SetTimeout(QBCore.Config.Money.PayCheckTimeOut * (60 * 1000), PaycheckInterval)
end
```

**IF STILL USING QB-MANAGEMENT TO HANDLE SOCIETY FUNDS, Go to qb-core/server/functions.lua and replace PaycheckInterval() code with mine below.**

```lua
function PaycheckInterval()
    if next(QBCore.Players) then
        for _, Player in pairs(QBCore.Players) do
            if Player then
                local payment = QBShared.Jobs[Player.PlayerData.job.name]['grades'][tostring(Player.PlayerData.job.grade.level)].payment
                if not payment then payment = Player.PlayerData.job.payment end
                if Player.PlayerData.job and payment > 0 and (QBShared.Jobs[Player.PlayerData.job.name].offDutyPay or Player.PlayerData.job.onduty) then
                    if QBCore.Config.Money.PayCheckSociety then
                        local account = exports['qb-management']:GetAccount(Player.PlayerData.job.name)
                        if account ~= 0 then -- Checks if player is employed by a society
                            if account < payment then -- Checks if company has enough money to pay society
                                TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('error.company_too_poor'), 'error')
                            else
                                exports.randol_paycheck:AddToPaycheck(Player.PlayerData.citizenid, payment)
                                exports['qb-management']:RemoveMoney(Player.PlayerData.job.name, payment)
                                TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                            end
                        else
                            exports.randol_paycheck:AddToPaycheck(Player.PlayerData.citizenid, payment)
                            TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                        end
                    else
                        exports.randol_paycheck:AddToPaycheck(Player.PlayerData.citizenid, payment)
                        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                    end
                end
            end
        end
    end
    SetTimeout(QBCore.Config.Money.PayCheckTimeOut * (60 * 1000), PaycheckInterval)
end
```

# ESX Install.

**Go to es_extended/server/paycheck.lua and replace the StartPayCheck() function with mine below.**

```lua
function StartPayCheck()
  CreateThread(function()
    while true do
      Wait(Config.PaycheckInterval)

      for player, xPlayer in pairs(ESX.Players) do
        local job = xPlayer.job.grade_name
        local salary = xPlayer.job.grade_salary
        
        if salary > 0 then
          if job == 'unemployed' then -- unemployed
            exports.randol_paycheck:AddToPaycheck(xPlayer.identifier, salary)
            TriggerClientEvent('esx:showAdvancedNotification', player, TranslateCap('bank'), TranslateCap('received_paycheck'), TranslateCap('received_help', salary),
              'CHAR_BANK_MAZE', 9)
          elseif Config.EnableSocietyPayouts then -- possibly a society
            TriggerEvent('esx_society:getSociety', xPlayer.job.name, function(society)
              if society ~= nil then -- verified society
                TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function(account)
                  if account.money >= salary then -- does the society money to pay its employees?
                    exports.randol_paycheck:AddToPaycheck(xPlayer.identifier, salary)
                    account.removeMoney(salary)

                    TriggerClientEvent('esx:showAdvancedNotification', player, TranslateCap('bank'), TranslateCap('received_paycheck'),
                      TranslateCap('received_salary', salary), 'CHAR_BANK_MAZE', 9)
                  else
                    TriggerClientEvent('esx:showAdvancedNotification', player, TranslateCap('bank'), '', TranslateCap('company_nomoney'), 'CHAR_BANK_MAZE', 1)
                  end
                end)
              else -- not a society
                exports.randol_paycheck:AddToPaycheck(xPlayer.identifier, salary)
                TriggerClientEvent('esx:showAdvancedNotification', player, TranslateCap('bank'), TranslateCap('received_paycheck'), TranslateCap('received_salary', salary),
                  'CHAR_BANK_MAZE', 9)
              end
            end)
          else -- generic job
            exports.randol_paycheck:AddToPaycheck(xPlayer.identifier, salary)
            TriggerClientEvent('esx:showAdvancedNotification', player, TranslateCap('bank'), TranslateCap('received_paycheck'), TranslateCap('received_salary', salary),
              'CHAR_BANK_MAZE', 9)
          end
        end
      end
    end
  end)
end
```

QBOX Install - Navigate to this line: https://github.com/Qbox-project/qbx_core/blob/main/config/server.lua#L131 

```lua
sendPaycheck = function (player, payment)
    exports.randol_paycheck:AddToPaycheck(player.PlayerData.citizenid, payment)
    Notify(player.PlayerData.source, locale('info.received_paycheck', payment))
end,
```

# Export

The export below can be used to insert money into the paycheck rather than adding it into a player's bank/cash. You must implement these yourself.

Example: QBCore

```lua
local Player = QBCore.Functions.GetPlayer(source)
local amount = 450
exports.randol_paycheck:AddToPaycheck(Player.PlayerData.citizenid, amount)
```

Example: ESX

```lua
local xPlayer = ESX.GetPlayerFromId(source)
local amount = 450
exports.randol_paycheck:AddToPaycheck(xPlayer.identifier, amount)
```