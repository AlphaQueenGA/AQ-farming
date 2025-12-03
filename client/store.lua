local storePoints = {}
local storesInitialised = false

-- Spawn a store ped safely
local function spawnStorePed(s)
    local model = type(s.ped.model) == 'number' and s.ped.model or GetHashKey(s.ped.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePed(4, model, s.coords.x, s.coords.y, s.coords.z - 1.0, s.ped.heading or 0.0, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)

    if s.ped.scenario then
        TaskStartScenarioInPlace(ped, s.ped.scenario, 0, true)
    end

    return ped
end

-- Initialise all stores once
AddEventHandler('farming:client:initStores', function()
    if storesInitialised then return end
    storesInitialised = true

    for _, s in ipairs(Config.Stores or {}) do
        -- Blip
        if s.blip and s.blip.showBlip then
            local blip = AddBlipForCoord(s.coords.x, s.coords.y, s.coords.z)
            SetBlipSprite(blip, s.blip.sprite or 52)
            SetBlipColour(blip, s.blip.color or 2)
            SetBlipScale(blip, s.blip.scale or 0.8)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(s.blip.label or s.label)
            EndTextCommandSetBlipName(blip)
        end

        -- Ped + interaction
        if s.ped and s.ped.model and not storePoints[s.id] then
            local ped = spawnStorePed(s)

            local point = lib.points.new({
                coords = s.coords,
                distance = 25.0,
                onEnter = function()
                    lib.showTextUI('[E] Talk to Store Clerk')
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                nearby = function(self)
                    local dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(ped))
                    if dist <= (s.radius or 2.0) and IsControlJustPressed(0, 38) then
                        TriggerEvent('farming:client:openStore', s.id)
                    end
                end
            })

            storePoints[s.id] = { ped = ped, point = point }
        end
    end
end)

-- Open store UI
RegisterNetEvent('farming:client:openStore', function(storeId)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        storeId = storeId,
        whitelist = (function(id)
            for _, s in ipairs(Config.Stores or {}) do
                if s.id == id then return s.whitelist or {} end
            end
            return {}
        end)(storeId),
        imgRoot = Config.QBInventoryImageRoot
    })
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    for _, data in pairs(storePoints) do
        if data.point and data.point.remove then data.point:remove() end
        if data.ped and DoesEntityExist(data.ped) then DeleteEntity(data.ped) end
    end
    storePoints = {}
    storesInitialised = false
end)