local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    for _, location in pairs(Locations or {}) do
        for _, z in ipairs(location.zones or {}) do
            Farming.zones[z.id] = z
        end
        for _, a in ipairs(location.animals or {}) do
            Farming.animals[a.id] = { cfg = a }
        end
        for _, s in ipairs(location.shops or {}) do
            Farming.shops[s.id] = s
        end
    end

    if Config.enablePropSpawning then
        for zoneId, z in pairs(Farming.zones) do
            TriggerClientEvent('aq_farming:client:spawnZoneProps', -1, zoneId, z)
        end
    end

    for aId, a in pairs(Farming.animals) do
        TriggerClientEvent('aq_farming:client:spawnAnimals', -1, aId, a.cfg)
    end

    for shopId, s in pairs(Farming.shops) do
        TriggerClientEvent('aq_farming:client:spawnShopPed', -1, shopId, s)
    end
end)

AddEventHandler('onResourceStop', function(resName)
    if resName ~= GetCurrentResourceName() then return end
    TriggerClientEvent('aq_farming:client:cleanup', -1)
end)