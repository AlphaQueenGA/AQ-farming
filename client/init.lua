local loadedLocations = {}
local loadedAnimals = AnimalConfig or {}
local locationsInitialised = false
local animalsInitialised = false
local storesInitialised = false

CreateThread(function()
    if Locations then
        for _, cfg in ipairs(Locations) do
            loadedLocations[cfg.id] = cfg
        end
    end

    exports.ox_lib:registerContext({
        id = 'farm_store_context',
        title = 'Farm Store',
        options = {
            { title = 'Open Store', description = 'Sell farm goods', event = 'farming:client:openStore' }
        }
    })

    -- Only initialise once
    if not locationsInitialised then
        TriggerEvent('farming:client:initLocations', loadedLocations)
        locationsInitialised = true
    end

    if not animalsInitialised then
        TriggerEvent('farming:client:initAnimals', loadedAnimals)
        animalsInitialised = true
    end

    if not storesInitialised then
        TriggerEvent('farming:client:initStores')
        storesInitialised = true
    end
end)