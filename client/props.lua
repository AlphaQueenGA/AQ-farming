local spawnedProps = {}

local function spawnLocalProp(model, pos, heading)
    local mhash = type(model) == 'number' and model or GetHashKey(model)
    RequestModel(mhash); while not HasModelLoaded(mhash) do Wait(0) end
    local obj = CreateObject(mhash, pos.x, pos.y, pos.z, false, false, false)
    SetEntityHeading(obj, heading or 0.0)
    FreezeEntityPosition(obj, true)
    return obj
end

RegisterNetEvent('farming:client:applyPropState', function(state)
    for nodeKey, info in pairs(state) do
        if not spawnedProps[nodeKey] then
            spawnedProps[nodeKey] = { entity = spawnLocalProp(info.model, info.pos, info.heading) }
        end
    end
    for nodeKey, entry in pairs(spawnedProps) do
        if not state[nodeKey] then
            if DoesEntityExist(entry.entity) then DeleteEntity(entry.entity) end
            spawnedProps[nodeKey] = nil
        end
    end
end)

RegisterNetEvent('farming:client:deletePropByNodeKey', function(payload)
    for nodeKey in pairs(payload) do
        local entry = spawnedProps[nodeKey]
        if entry and DoesEntityExist(entry.entity) then DeleteEntity(entry.entity) end
        spawnedProps[nodeKey] = nil
    end
end)

RegisterNetEvent('farming:client:deleteDuplicateProp', function(nodeKey)
    local entry = spawnedProps[nodeKey]
    if entry and DoesEntityExist(entry.entity) then DeleteEntity(entry.entity) end
    spawnedProps[nodeKey] = nil
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for _, entry in pairs(spawnedProps) do
        if DoesEntityExist(entry.entity) then DeleteEntity(entry.entity) end
    end
    spawnedProps = {}
end)