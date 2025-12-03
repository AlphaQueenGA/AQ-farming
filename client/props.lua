local spawnedProps = {}  -- [nodeKey] = { entity = obj }

local function spawnLocalProp(model, pos, heading)
    local mhash = type(model) == 'number' and model or GetHashKey(model)
    RequestModel(mhash)
    while not HasModelLoaded(mhash) do Wait(0) end

    local obj = CreateObject(mhash, pos.x, pos.y, pos.z, false, false, false)
    SetEntityHeading(obj, heading or 0.0)
    FreezeEntityPosition(obj, true)
    return obj
end

-- Apply full state from server
RegisterNetEvent('farming:client:applyPropState', function(state)
    -- spawn new props
    for nodeKey, info in pairs(state) do
        if not spawnedProps[nodeKey] then
            local obj = spawnLocalProp(info.model, info.pos, info.heading or 0.0)
            spawnedProps[nodeKey] = { entity = obj }
        end
    end

    -- remove any props no longer in state
    for nodeKey, entry in pairs(spawnedProps) do
        if not state[nodeKey] then
            if entry.entity and DoesEntityExist(entry.entity) then
                DeleteEntity(entry.entity)
            end
            spawnedProps[nodeKey] = nil
        end
    end
end)

-- Delete specific props by nodeKey
RegisterNetEvent('farming:client:deletePropByNodeKey', function(payload)
    for nodeKey in pairs(payload) do
        local entry = spawnedProps[nodeKey]
        if entry and entry.entity and DoesEntityExist(entry.entity) then
            DeleteEntity(entry.entity)
        end
        spawnedProps[nodeKey] = nil
    end
end)

-- Delete duplicate prop (server rejected)
RegisterNetEvent('farming:client:deleteDuplicateProp', function(nodeKey)
    local entry = spawnedProps[nodeKey]
    if entry and entry.entity and DoesEntityExist(entry.entity) then
        DeleteEntity(entry.entity)
    end
    spawnedProps[nodeKey] = nil
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for _, entry in pairs(spawnedProps) do
        if entry.entity and DoesEntityExist(entry.entity) then
            DeleteEntity(entry.entity)
        end
    end
    spawnedProps = {}
end)
