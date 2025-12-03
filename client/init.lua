local INIT = { locations = false, animals = false, stores = false }

CreateThread(function()
    exports.ox_lib:registerContext({
        id = 'farm_store_context',
        title = 'Farm Store',
        options = {
            { title = 'Open Store', description = 'Sell farm goods', event = 'farming:client:openStore' }
        }
    })

    if not INIT.locations then
        TriggerEvent('farming:client:initLocations', Locations or {})
        INIT.locations = true
    end
    if not INIT.animals then
        TriggerEvent('farming:client:initAnimals', AnimalConfig or {})
        INIT.animals = true
    end
    if not INIT.stores then
        TriggerEvent('farming:client:initStores')
        INIT.stores = true
    end
end)