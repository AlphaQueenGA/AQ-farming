local spawnedProps = {}
local spawnedByLoc = {}

local function getGroundZ(pos)
    local z = pos.z
    local attempt, success, gz = 0, false, pos.z
    repeat
        success, gz = GetGroundZFor_3dCoord(pos.x, pos.y, z, false)
        z = z + 0.5
        attempt = attempt + 1
    until success or attempt >= (Config.GroundRaycastMaxAttempts or 10)
    return success and gz or pos.z
end

local function spawnLocalProp(model, pos, heading)
    local mhash = type(model) == 'number' and model or GetHashKey(model)
    RequestModel(mhash)
    while not HasModelLoaded(mhash) do Wait(0) end

    -- Spawn directly at given coords (no ground check)
    local obj = CreateObject(mhash, pos.x, pos.y, pos.z, false, false, false)

    if Config.UsePlaceObjectGroundProperly then
        PlaceObjectOnGroundProperly(obj)
    end
    SetEntityHeading(obj, heading or 0.0)
    FreezeEntityPosition(obj, true)
    return obj
end

RegisterNetEvent('farming:client:applyPropState', function(state)
  -- spawn new
  for nodeKey, info in pairs(state) do
    if not spawnedProps[nodeKey] then
      local obj = CreateObject(GetHashKey(info.model), info.pos.x, info.pos.y, info.pos.z, false, false, false)
      SetEntityHeading(obj, info.heading or 0.0)
      FreezeEntityPosition(obj, true)
      spawnedProps[nodeKey] = { entity = obj, locId = info.locId }
    end
  end
  -- delete removed
  for nodeKey, entry in pairs(spawnedProps) do
    if not state[nodeKey] then
      if DoesEntityExist(entry.entity) then DeleteEntity(entry.entity) end
      spawnedProps[nodeKey] = nil
    end
  end
end)


-- Delete by nodeKey (server sends a map {[nodeKey] = info} or single key)
RegisterNetEvent('farming:client:deletePropByNodeKey', function(payload)
    -- payload may be a single nodeKey->info map or the entire state subset
    for nodeKey, info in pairs(payload) do
        local entry = spawnedProps[nodeKey]
        if entry then
            local ent = entry.entity
            if DoesEntityExist(ent) then DeleteEntity(ent) end
            spawnedProps[nodeKey] = nil
            if spawnedByLoc[entry.locId] then
                spawnedByLoc[entry.locId][nodeKey] = nil
            end
        end
    end
end)

-- Optional: client proposal path (e.g. player plants) — server validates and rebroadcasts
RegisterNetEvent('farming:client:spawnPropAt', function(locId, cdef, pos)
    local nodeKey = ('%s:%.2f:%.2f:%.2f'):format(cdef.id, pos.x, pos.y, pos.z)
    if spawnedProps[nodeKey] then return end
    spawnedByLoc[locId] = spawnedByLoc[locId] or {}
    if spawnedByLoc[locId][nodeKey] then return end

    -- propose to server; server will accept and broadcast applyPropState
    local choice = cdef.props[1]  -- deterministic; or define your selection policy
    TriggerServerEvent('farming:server:registerProp', {
        locId = locId,
        nodeKey = nodeKey,
        pos = pos,
        model = choice.model,
        heading = choice.heading or 0.0,
        cdef = cdef
    })
end)

-- Clean up on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for nodeKey, entry in pairs(spawnedProps) do
        if DoesEntityExist(entry.entity) then DeleteEntity(entry.entity) end
    end
    spawnedProps = {}
    spawnedByLoc = {}
end)