## Requirements

[ox_lib](https://github.com/overextended/ox_lib/releases)

## Install SQL

I made an sql which you will need to import into your database so yeah.. do that first.

## Editing QBCore's default paycheck system.

Go to qb-core/server/functions.lua and replace PaycheckInterval() code with mine below.

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
                                exports['randol_paycheck']:AddToPaycheck(Player.PlayerData.citizenid, payment)
                                exports['qb-management']:RemoveMoney(Player.PlayerData.job.name, payment)
                                TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                            end
                        else
                            exports['randol_paycheck']:AddToPaycheck(Player.PlayerData.citizenid, payment)
                            TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                        end
                    else
                        exports['randol_paycheck']:AddToPaycheck(Player.PlayerData.citizenid, payment)
                        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                    end
                end
            end
        end
    end
    SetTimeout(QBCore.Config.Money.PayCheckTimeOut * (60 * 1000), PaycheckInterval)
end
```
## Export

The export below you can use instead of doing: Player.Functions.AddMoney('bank', amount) when rewarding money from legal jobs etc.

```lua
exports['randol_paycheck']:AddToPaycheck(Player.PlayerData.citizenid, amount)
```

## Showcase

[showcase](https://streamable.com/t7czpi)
