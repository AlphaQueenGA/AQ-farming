local Props = {}
local Animals = {}
local Shops = {}

local function getEntityFromNet(id)
    if not id then return nil end
    return NetworkGetEntityFromNetworkId(id)
end

-- Displays an ox_lib “Press [E]” style prompt
local function canInteract(msg)
    return lib.showTextUI(msg or "[E] Interact")
end

local function hideInteract()
    lib.hideTextUI()
end

----------------------------------------------------------------
-- REGISTERED ENTITIES FROM SERVER
----------------------------------------------------------------

RegisterNetEvent("aq_farming:client:registerProps", function(zoneId, netIds)
    Props[zoneId] = netIds or {}
end)

RegisterNetEvent("aq_farming:client:registerAnimals", function(zoneId, netIds)
    Animals[zoneId] = netIds or {}
end)

RegisterNetEvent("aq_farming:client:registerShopPed", function(shopId, netId)
    Shops[shopId] = netId
end)

RegisterNetEvent("aq_farming:client:cleanup", function()
    Props = {}
    Animals = {}
    Shops = {}
end)

----------------------------------------------------------------
-- INTERACTION LOOP
-- Only checks distance to server-spawned entities
----------------------------------------------------------------

CreateThread(function()
    local interacting = false

    while true do
        Wait(0)

        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        local nearest, dist, typeId, id = nil, 4.0, nil, nil

        ----------------------------------------------------------------
        -- FIND NEAREST PROP
        ----------------------------------------------------------------
        for zoneId, list in pairs(Props) do
            for _, netId in ipairs(list) do
                local ent = getEntityFromNet(netId)
                if ent and DoesEntityExist(ent) then
                    local coords = GetEntityCoords(ent)
                    local d = #(pCoords - coords)

                    if d < dist then
                        dist = d
                        nearest = ent
                        typeId = "prop"
                        id = zoneId
                    end
                end
            end
        end

        ----------------------------------------------------------------
        -- FIND NEAREST ANIMAL
        ----------------------------------------------------------------
        for zoneId, list in pairs(Animals) do
            for _, netId in ipairs(list) do
                local ent = getEntityFromNet(netId)
                if ent and DoesEntityExist(ent) then
                    local coords = GetEntityCoords(ent)
                    local d = #(pCoords - coords)

                    if d < dist then
                        dist = d
                        nearest = ent
                        typeId = "animal"
                        id = zoneId
                    end
                end
            end
        end

        ----------------------------------------------------------------
        -- FIND NEAREST SHOP PED
        ----------------------------------------------------------------
        for shopId, netId in pairs(Shops) do
            local ent = getEntityFromNet(netId)
            if ent and DoesEntityExist(ent) then
                local coords = GetEntityCoords(ent)
                local d = #(pCoords - coords)

                if d < dist then
                    dist = d
                    nearest = ent
                    typeId = "shop"
                    id = shopId
                end
            end
        end

        ----------------------------------------------------------------
        -- IF NOTHING NEARBY
        ----------------------------------------------------------------
        if not nearest then
            if interacting then
                hideInteract()
                interacting = false
            end
            goto continue
        end

        ----------------------------------------------------------------
        -- DISPLAY INTERACTION UI
        ----------------------------------------------------------------
        if not interacting then
            canInteract("[E] Interact")
            interacting = true
        end

        ----------------------------------------------------------------
        -- HANDLE KEY PRESS
        ----------------------------------------------------------------
        if IsControlJustPressed(0, 38) then
            if typeId == "prop" then
                TriggerServerEvent("aq_farming:server:harvestProp", id)
            elseif typeId == "animal" then
                TriggerServerEvent("aq_farming:server:interactAnimal", id)
            elseif typeId == "shop" then
                TriggerServerEvent("aq_farming:server:openShop", id)
            end
        end

        ::continue::
    end
end)
