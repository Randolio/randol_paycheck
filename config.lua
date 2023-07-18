Config = {}

Config.Ped = {
    model = `a_f_y_business_02`,
    coords = vec4(241.54, 227.0, 105.29, 150.23), -- Default Pacific Bank.
}

Config.TaxRate = 0.10 -- 10% tax rate | If you dont want tax, set this to 0.

Config.Target = 'ox' -- Use 'ox' for Overextended Target
                     -- Use 'qb' for QBCore Target

QBCore = exports['qb-core']:GetCoreObject()