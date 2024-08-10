local PC_PED, initZone

local function InputWithdraw(amount)
    local response = lib.inputDialog('Withdrawal', {
        { type = 'number', label = 'How much?', icon = 'fa-solid fa-hand-pointer', description = ('Input an amount to withdraw. Balance: $%s'):format(amount), required = true   },
        { type = 'select', label = 'Account', required = true, icon = 'fa-solid fa-wallet', options = {
            { value = 'cash', label = 'Cash' },
            { value = 'bank', label = 'Bank' },
        }}
    })
    if not response then return end
    local inputAmt = response[1]
    local accountType = response[2]
    if inputAmt < 1 then 
        return DoNotification('Amount needs to be more than 0.', 'error') 
    end
    if inputAmt > amount then 
        return DoNotification('You don\'t have this much in your paycheck..', 'error')
    end
    TriggerServerEvent('randol_paycheck:server:withdraw', inputAmt, accountType)
end

local function viewPaycheck()
    local paycheckAmount = lib.callback.await('randol_paycheck:server:checkPaycheck', true)
    lib.registerContext({
        id = 'view_pc',
        title = ('Paycheck: $%s'):format(paycheckAmount),
        options = {
            {
                title = 'Withdraw',
                description = 'Withdraw money from your paycheck.',
                icon = 'fa-solid fa-money-check-dollar', 
                onSelect = function()
                    InputWithdraw(tonumber(paycheckAmount))
                end,
            },
        }
    })
    lib.showContext('view_pc')
end

local function removePed()
    if not DoesEntityExist(PC_PED) then return end
    DeleteEntity(PC_PED)
    exports['qb-target']:RemoveTargetEntity(PC_PED, 'View Paycheck')
    PC_PED = nil
end

local function spawnPed()
    for k in pairs(Config.locations) do 
        lib.requestModel(Config.model)
        PC_PED = CreatePed(0, Config.model, Config.locations[k].coords, false, false)
        SetEntityAsMissionEntity(PC_PED)
        SetPedFleeAttributes(PC_PED, 0, 0)
        SetBlockingOfNonTemporaryEvents(PC_PED, true)
        SetEntityInvincible(PC_PED, true)
        FreezeEntityPosition(PC_PED, true)
        SetPedDefaultComponentVariation(PC_PED)
        SetModelAsNoLongerNeeded(Config.model)
        lib.requestAnimDict('mp_prison_break')
        TaskPlayAnim(PC_PED, 'mp_prison_break', 'hack_loop', 8.0, -8.0, -1, 1, 0.0, 0, 0, 0)
        RemoveAnimDict('mp_prison_break')
        exports['qb-target']:AddTargetEntity(PC_PED, {
            options = {
                {
                    icon = 'fa-solid fa-money-check-dollar', 
                    label = 'View Paycheck',
                    action = function()
                        lib.requestAnimDict('friends@laf@ig_5')
                        TaskPlayAnim(cache.ped, 'friends@laf@ig_5', 'nephew', 8.0, -8.0, -1, 49, 0, false, false, false)
                        RemoveAnimDict('friends@laf@ig_5')
                        if lib.progressCircle({
                            duration = 2500,
                            position = 'bottom',
                            label = 'Viewing paycheck..',
                            useWhileDead = true,
                            canCancel = false,
                            disable = { move = true, car = true, mouse = false, combat = true, },
                        }) then
                            ClearPedTasks(cache.ped)
                            viewPaycheck()
                        end
                    end,
                },
            },
            distance = 4.5,
        })
    end
end

local function paycheckZone()
    for k in pairs(Config.locations) do 
        initZone = lib.points.new({
            coords = Config.locations[k].coords.xyz,
            distance = 50,
            onEnter = spawnPed,
            onExit = removePed,
        })
    end
end

function OnPlayerLoaded()
    paycheckZone()
end

function OnPlayerUnload()
    if initZone then initZone:remove() end
    removePed()
end

AddEventHandler('onResourceStop', function(resourceName) 
    if GetCurrentResourceName() == resourceName then
        if initZone then initZone:remove() end
        removePed()
    end 
end)