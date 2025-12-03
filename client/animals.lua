local animalPoints = {}

-- Register static interaction point (used for hives or coops)
local function registerAnimalPoint(entry, label)
    local point = lib.points.new({
        coords = entry.coords,
        distance = 25.0,
        onEnter = function()
            lib.showTextUI(('[E] %s'):format(label))
        end,
        onExit = function()
            lib.hideTextUI()
        end,
        nearby = function(self)
            local dist = #(self.coords - GetEntityCoords(PlayerPedId()))
            if dist <= 2.0 and IsControlJustPressed(0, 38) then
                TriggerEvent('farming:client:interactAnimal', entry)
            end
        end
    })
    animalPoints[#animalPoints+1] = point
end

-- Init all animal-related client-side interactions (only interaction points remain)
AddEventHandler('farming:client:initAnimals', function(cfg)
    for _, hive in ipairs(cfg.beehives or {}) do
        registerAnimalPoint(hive, hive.prompt or 'Harvest honey')

    end
end)

AddEventHandler('farming:client:interactAnimal', function(entry)
    local label = entry.prompt or 'Interact'
    if not lib.progressCircle({
        duration = Config.ProgressDurationMs.animal,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        label = label,
        disable = { move = true, combat = true }
    }) then return end

    TriggerServerEvent('farming:server:animalCollect', entry.id)
end)

-- Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for _, point in ipairs(animalPoints) do
        if point and point.remove then
            point:remove()
        end
    end
    animalPoints = {}
    -- Removed local animal ped deletion logic
end)