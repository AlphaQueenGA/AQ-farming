local QBCore = exports['qb-core']:GetCoreObject()

local shopZones = {}

-- Build shop zones
CreateThread(function()
    for _, loc in pairs(Locations or {}) do
        for _, s in ipairs(loc.shops or {}) do
            local sphere = lib.zones.sphere({
                coords = s.coords,
                radius = 2.5,
                debug = Config.debug
            })
            shopZones[s.id] = sphere
        end
    end
end)

-- Press E to open shop UI
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustReleased(0, Config.interactKey) then
            local pos = GetEntityCoords(PlayerPedId())
            for shopId, sphere in pairs(shopZones) do
                if sphere:contains(pos) then
                    TriggerEvent('aq_farming:client:openShop', shopId)
                    break
                end
            end
        end
    end
end)

-- Open shop UI
RegisterNetEvent('aq_farming:client:openShop', function(shopId)
    local shop
    for _, loc in pairs(Locations or {}) do
        for _, s in ipairs(loc.shops or {}) do
            if s.id == shopId then
                shop = s
                break
            end
        end
    end
    if not shop then return end

    local playerData = QBCore.Functions.GetPlayerData()
    local balance = playerData.money and playerData.money['cash'] or 0

    -- Build sell list with counts
    local items = {}
    for _, entry in ipairs(shop.inventory.sell or {}) do
        local count = 0
        if playerData.items then
            for _, invItem in pairs(playerData.items) do
                if invItem.name == entry.item then
                    count = invItem.amount or 0
                    break
                end
            end
        end
        items[#items+1] = {
            item = entry.item,
            name = entry.name or entry.item,
            price = entry.price,
            category = entry.category or 'misc',
            count = count
        }
    end

    SendNUIMessage({
        action = 'open',
        title = '🌾Straw Hat Ranch🌾',
        shopId = shopId,
        balance = balance,
        items = items
    })
    SetNuiFocus(true, true)
end)

-- NUI callbacks
RegisterNUICallback('sellItem', function(data, cb)
    TriggerServerEvent('aq_farming:server:sellItem', data.shopId, data.item, data.price, data.count)
    cb(true)
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb(true)
end)

-- Utility: get shop inventory definition
function getShopInventory(shopId)
    for _, loc in pairs(Locations or {}) do
        for _, s in ipairs(loc.shops or {}) do
            if s.id == shopId then return s.inventory end
        end
    end
    return { sell = {} }
end