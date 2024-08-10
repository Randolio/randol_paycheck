local Config = lib.require('config')
local PC_PED, initZone
local oxtarget = GetResourceState('ox_target') == 'started'

local function targetLocalEntity(entity, options, distance)
    if oxtarget then
        for _, option in ipairs(options) do
            option.distance = distance
            option.onSelect = option.action
            option.action = nil
        end
        exports.ox_target:addLocalEntity(entity, options)
    else
        exports['qb-target']:AddTargetEntity(entity, { options = options, distance = distance })
    end
end

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
    
    if inputAmt < 1 then return DoNotification('Amount needs to be more than 0.', 'error') end
    if inputAmt > amount then return DoNotification('You don\'t have this much in your paycheck..', 'error') end

    local success = lib.callback.await('randol_paycheck:server:withdraw', false, inputAmt, accountType)
    if success then
        lib.playAnim(cache.ped, 'friends@laf@ig_5', 'nephew', 8.0, -8.0, -1, 49, 0, false, false, false)
        Wait(2000)
        ClearPedTasks(cache.ped)
    end
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
    if oxtarget then
        exports.ox_target:removeLocalEntity(PC_PED, 'View Paycheck')
    else
        exports['qb-target']:RemoveTargetEntity(PC_PED, 'View Paycheck')
    end
    DeleteEntity(PC_PED)
    PC_PED = nil
end

local function spawnPed()
    lib.requestModel(Config.model, 10000)
    PC_PED = CreatePed(0, Config.model, Config.coords, false, false)
    SetEntityAsMissionEntity(PC_PED)
    SetPedFleeAttributes(PC_PED, 0, 0)
    SetBlockingOfNonTemporaryEvents(PC_PED, true)
    SetEntityInvincible(PC_PED, true)
    FreezeEntityPosition(PC_PED, true)
    SetPedDefaultComponentVariation(PC_PED)
    SetModelAsNoLongerNeeded(Config.model)
    lib.playAnim(PC_PED, 'mp_prison_break', 'hack_loop', 8.0, -8.0, -1, 1, 0.0, 0, 0, 0)
    targetLocalEntity(PC_PED, {
        {
            icon = 'fa-solid fa-money-check-dollar', 
            label = 'View Paycheck',
            action = function()
                lib.playAnim(cache.ped, 'friends@laf@ig_5', 'nephew', 8.0, -8.0, -1, 49, 0, false, false, false)
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
    }, 4.5)
end

local function paycheckZone()
    initZone = lib.points.new({ coords = Config.coords.xyz, distance = 50, onEnter = spawnPed, onExit = removePed, })
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
