local ox_target = GetResourceState('ox_target'):match('start') and exports.ox_target or nil
local qb_target = GetResourceState('qb-target'):match('start') and exports['qb-target'] or nil

local function InputWithdraw(paycheckAmount)
    local response = lib.inputDialog("Withdrawal", {
        { type = "number", label = "How much?", icon = 'fa-solid fa-hand-pointer', description = "Input an amount to withdraw. Balance: $"..paycheckAmount, required = true   },
        { type = 'select', label = 'Account', required = true, icon = 'fa-solid fa-wallet', options = {
            { value = 'cash', label = 'Cash' },
            { value = 'bank', label = 'Bank' },
        }}
    })
    if not response then return end
    local inputAmt = response[1]
    local accountType = response[2]
    if inputAmt < 1 then QBCore.Functions.Notify('Amount needs to be more than 0.', 'error') return end
    if inputAmt > paycheckAmount then QBCore.Functions.Notify("You don't have this much in your paycheck..", "error") return end
    TriggerServerEvent('randol_paycheck:server:withdraw', inputAmt, accountType)
end

local function ViewPaycheck()
    lib.callback('randol_paycheck:server:checkPaycheck', true, function(paycheckAmount)
        lib.registerContext({
            id = 'view_pc',
            title = 'Paycheck: $'..paycheckAmount,
            options = {
                {
                    title = 'Withdraw',
                    description = 'Withdraw money from your paycheck.',
                    icon = "fa-solid fa-money-check-dollar", 
                    onSelect = function()
                        lib.hideContext()
                        InputWithdraw(tonumber(paycheckAmount))
                    end,
                },
            }
        })
        lib.showContext('view_pc')
    end)
end

local function PaycheckZone()
    if DoesEntityExist(PaycheckMommy) then return end
    lib.requestModel(Config.Ped.model)
    PaycheckMommy = CreatePed(0, Config.Ped.model, Config.Ped.coords, false, false)
    SetEntityAsMissionEntity(PaycheckMommy)
    SetPedFleeAttributes(PaycheckMommy, 0, 0)
    SetBlockingOfNonTemporaryEvents(PaycheckMommy, true)
    SetEntityInvincible(PaycheckMommy, true)
    FreezeEntityPosition(PaycheckMommy, true)
    SetPedDefaultComponentVariation(PaycheckMommy)
    lib.requestAnimDict("mp_prison_break")
	TaskPlayAnim(PaycheckMommy, 'mp_prison_break', 'hack_loop', 8.0, -8.0, -1, 1, 0.0, false, false, false)
    if Config.Target == 'ox' and ox_target then
        exports.ox_target:addLocalEntity(PaycheckMommy, {
            {
                icon = "fa-solid fa-money-check-dollar", 
                label = "Collect Paycheck",
                onSelect = function()
                    lib.requestAnimDict('friends@laf@ig_5')
                    TaskPlayAnim(PlayerPedId(), 'friends@laf@ig_5', 'nephew', 8.0, -8.0, -1, 49, 0, false, false, false)
                    QBCore.Functions.Progressbar("cash_check", "Viewing paycheck..", 2500, false, false, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {}, {}, {}, function()
                        ViewPaycheck()
                    end)
                end,
                distance = 4.5,
            },
            {
                icon = 'fas fa-money-bill-wave',
                label = 'Trade In Receipts',
                onSelect = function()
                    TriggerServerEvent('randol_paycheck:CheckReceipts') -- Future Idea
                end,
                distance = 4.5
            }
        })
    elseif Config.Target == 'qb' and qb_target then
        exports['qb-target']:AddTargetEntity(PaycheckMommy, {
            options = {
                {
                    icon = "fa-solid fa-money-check-dollar", 
                    label = "Collect Paycheck",
                    action = function()
                        lib.requestAnimDict('friends@laf@ig_5')
                        TaskPlayAnim(PlayerPedId(), 'friends@laf@ig_5', 'nephew', 8.0, -8.0, -1, 49, 0, false, false, false)
                        QBCore.Functions.Progressbar("cash_check", "Viewing paycheck..", 2500, false, false, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {}, {}, {}, function()
                            ViewPaycheck()
                        end)
                    end,
                },
                {
                    icon = 'fas fa-money-bill-wave',
                    label = 'Trade In Receipts',
                    onSelect = function()
                        TriggerServerEvent('randol_paycheck:CheckReceipts') -- Future Idea
                    end,
                },
                distance = 4.5,
            }
        })
    end
end

AddEventHandler('onResourceStop', function(resourceName) 
	if GetCurrentResourceName() == resourceName then
        DeleteEntity(PaycheckMommy)
	end 
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PaycheckZone()
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        PaycheckZone()
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    DeleteEntity(PaycheckMommy)
end)