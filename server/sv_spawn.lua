local Spawned = {
    props = {},
    animals = {},
    shops = {}
}

-- Safe model loader
local function ensureModel(model)
    local m = type(model) == "string" and joaat(model) or model

    if not IsModelInCdimage(m) then
        print(("^1[AQ-FARMING] Invalid model requested: %s^0"):format(model))
        return nil
    end

    RequestModel(m)
    local timeout = 0

    while not HasModelLoaded(m) do
        Wait(25)
        timeout += 1
        if timeout > 200 then
            print("^1[AQ-FARMING] Model failed to load: " .. tostring(model))
            return nil
        end
    end

    return m
end

-- Create a networked prop (server owned)
local function createProp(model, coords)
    local m = ensureModel(model)
    if not m then return nil end

    local obj = CreateObject(m, coords.x, coords.y, coords.z, true, true, true)
    SetEntityHeading(obj, coords.w or 0.0)

    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)

    local net = NetworkGetNetworkIdFromEntity(obj)
    SetNetworkIdExistsOnAllMachines(net, true)

    SetEntityAsMissionEntity(obj, true, true)
    SetModelAsNoLongerNeeded(m)

    return net
end

-- Create a networked ped (server owned)
local function createPed(model, coords, heading)
    local m = ensureModel(model)
    if not m then return nil end

    local ped = CreatePed(4, m, coords.x, coords.y, coords.z, heading or 0.0, true, true)

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    local net = NetworkGetNetworkIdFromEntity(ped)
    SetNetworkIdExistsOnAllMachines(net, true)

    SetEntityAsMissionEntity(ped, true, true)
    SetModelAsNoLongerNeeded(m)

    return net
end

----------------------------------------------------------------
-- PROP ZONES
----------------------------------------------------------------
RegisterNetEvent("aq_farming:server:spawnZoneProps", function(zoneId)
    local z = Farming.zones[zoneId]
    if not z or not z.coords or not z.propModels then return end

    Spawned.props[zoneId] = {}

    for i, coords in ipairs(z.coords) do
        local model = z.propModels[((i - 1) % #z.propModels) + 1]
        local netId = createProp(model, coords)
        if netId then
            table.insert(Spawned.props[zoneId], netId)
        end
    end

    TriggerClientEvent("aq_farming:client:registerProps", -1, zoneId, Spawned.props[zoneId])
end)

----------------------------------------------------------------
-- ANIMALS
----------------------------------------------------------------
RegisterNetEvent("aq_farming:server:spawnAnimals", function(zoneId)
    local a = Farming.animals[zoneId]
    if not a or not a.cfg or not a.cfg.coords then return end

    Spawned.animals[zoneId] = {}

    for _, coords in ipairs(a.cfg.coords) do
        local netId = createPed(a.cfg.spawnModel or `a_c_cow`, coords)
        if netId then
            table.insert(Spawned.animals[zoneId], netId)
        end
    end

    TriggerClientEvent("aq_farming:client:registerAnimals", -1, zoneId, Spawned.animals[zoneId])
end)

----------------------------------------------------------------
-- SHOP PEDS
----------------------------------------------------------------
RegisterNetEvent("aq_farming:server:spawnShopPed", function(shopId)
    local s = Farming.shops[shopId]
    if not s or not s.coords then return end

    local netId = createPed(s.pedModel or `s_m_m_farmer_01`, s.coords, s.heading or 0.0)
    Spawned.shops[shopId] = netId

    TriggerClientEvent("aq_farming:client:registerShopPed", -1, shopId, netId)
end)

----------------------------------------------------------------
-- CLEANUP
----------------------------------------------------------------
RegisterNetEvent("aq_farming:server:cleanup", function()
    for group, entries in pairs(Spawned) do
        for k, v in pairs(entries) do
            if type(v) == "table" then
                for _, netId in ipairs(v) do
                    local ent = NetworkGetEntityFromNetworkId(netId)
                    if DoesEntityExist(ent) then DeleteEntity(ent) end
                end
            else
                local ent = NetworkGetEntityFromNetworkId(v)
                if DoesEntityExist(ent) then DeleteEntity(ent) end
            end
        end
    end

    Spawned = { props={}, animals={}, shops={} }
end)
