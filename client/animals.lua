local animalsInitialised = false

AddEventHandler('farming:client:initAnimals', function(loadedAnimals)
    if animalsInitialised then return end
    animalsInitialised = true

    for _, animal in ipairs(loadedAnimals or {}) do
        -- spawn animal ped or blip here
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    animalsInitialised = false
end)
