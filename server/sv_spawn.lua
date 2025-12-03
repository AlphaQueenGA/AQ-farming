local function createNetworkedProp(model, coords)
    local m = type(model) == 'string' and joaat(model) or model
    RequestModel(m)
    while not HasModelLoaded(m) do Wait(10) end
    local obj = CreateObject(m, coords.x, coords.y, coords.z, true, true, false)
    local netId = NetworkGetNetworkIdFromEntity(obj)
    SetNetworkIdExistsOnAllMachines(netId, true)
    SetEntityAsMissionEntity(obj, true, false)
    return netId
end

local function createNetworkedPed(model, coords, heading)
    local m = type(model) == 'string' and joaat(model) or model
    RequestModel(m)
    while not HasModelLoaded(m) do Wait(10) end
    local ped = CreatePed(4, m, coords.x, coords.y, coords.z, heading or 0.0, true, true)
    local netId = NetworkGetNetworkIdFromEntity(ped)
    SetNetworkIdExistsOnAllMachines(netId, true)
    SetEntityAsMissionEntity(ped, true, false)
    return netId
end

RegisterNetEvent('aq_farming:server:spawnZoneProps', function(zoneId)
    local z = Farming.zones[zoneId]
    if not z or not z.props then return end

    -- tell all clients to spawn props for this zone
    TriggerClientEvent('aq_farming:client:spawnZoneProps', -1, zoneId, z)
end)

RegisterNetEvent('aq_farming:server:spawnAnimals', function(animalZoneId)
    local a = Farming.animals[animalZoneId]
    if not a or not a.cfg then return end

    TriggerClientEvent('aq_farming:client:spawnAnimals', -1, animalZoneId, a.cfg)
end)

RegisterNetEvent('aq_farming:server:spawnShopPed', function(shopId)
    local s = Farming.shops[shopId]
    if not s then return end

    TriggerClientEvent('aq_farming:client:spawnShopPed', -1, shopId, s)
end)
