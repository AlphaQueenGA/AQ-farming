local INIT = {
  locations = false,
  animals = false,
  stores = false,
  props = false
}

CreateThread(function()
  TriggerEvent('farming:client:bootstrap')
end)

AddEventHandler('farming:client:bootstrap', function()
  if not INIT.locations then
    TriggerEvent('farming:client:initLocations', Locations)
    INIT.locations = true
  end

  if not INIT.animals then
    TriggerEvent('farming:client:initAnimals', AnimalConfig)
    INIT.animals = true
  end

  if not INIT.stores then
    TriggerEvent('farming:client:initStores')
    INIT.stores = true
  end
end)

AddEventHandler('onResourceStop', function(resourceName)
  if resourceName ~= GetCurrentResourceName() then return end

  -- props
  for nodeKey, entry in pairs(spawnedProps or {}) do
    if entry.entity and DoesEntityExist(entry.entity) then DeleteEntity(entry.entity) end
  end
  spawnedProps = {}

  -- store peds & points
  for storeId, data in pairs(storePoints or {}) do
    if data.point and data.point.remove then data.point:remove() end
    if data.ped and DoesEntityExist(data.ped) then DeleteEntity(data.ped) end
  end
  storePoints = {}
end)
