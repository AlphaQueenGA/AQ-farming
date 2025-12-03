local spawnedEntities = {}

local function loadModel(m)
    local model = type(m) == 'string' and joaat(m) or m
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    return model
end

RegisterNetEvent('aq_farming:client:spawnZoneProps', function(zoneId, zoneData)
    spawnedEntities[zoneId] = {}
    for i, coords in ipairs(zoneData.coords or {}) do
        local model = zoneData.propModels[((i - 1) % #zoneData.propModels) + 1]
        local m = loadModel(model)
        local obj = CreateObject(m, coords.x, coords.y, coords.z, true, true, false)
        PlaceObjectOnGroundProperly(obj)
        table.insert(spawnedEntities[zoneId], obj)
    end
end)

RegisterNetEvent('aq_farming:client:spawnAnimals', function(animalZoneId, cfg)
    spawnedEntities[animalZoneId] = {}
    local m = loadModel(cfg.spawnModel or `a_c_cow`)
    for _, coords in ipairs(cfg.coords or {}) do
        local ped = CreatePed(4, m, coords.x, coords.y, coords.z, 0.0, true, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        table.insert(spawnedEntities[animalZoneId], ped)
    end
end)

RegisterNetEvent('aq_farming:client:spawnShopPed', function(shopId, shopData)
    local m = loadModel(shopData.pedModel or `s_m_m_farmer_01`)
    local ped = CreatePed(4, m, shopData.coords.x, shopData.coords.y, shopData.coords.z, shopData.heading or 0.0, true, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    spawnedEntities[shopId] = { ped }
end)

RegisterNetEvent('aq_farming:client:cleanup', function()
    for _, list in pairs(spawnedEntities) do
        for _, ent in ipairs(list) do
            if DoesEntityExist(ent) then DeleteEntity(ent) end
        end
    end
    spawnedEntities = {}
end)