local propState = {}        -- [nodeKey] = { locId, nodeKey, pos, model, heading, cdef }
local propLocationMap = {}  -- [nodeKey] = true
local storePeds = {}        -- [storeId] = pedEntity  <-- NEW
local roamingAnimals = {}   -- [animalId] = pedEntity <-- NEW

local function vec3(x, y, z) return { x = x, y = y, z = z } end

local function makePropKey(pos, colId)
    return ('%s:%.2f:%.2f:%.2f'):format(colId, pos.x, pos.y, pos.z)
end


local function generateRadiusNodes(def)
    local res = {}
    local step = (2.0 * math.pi) / def.points
    for i = 1, def.points do
        local angle = step * i
        res[#res+1] = vec3(
            def.center.x + math.cos(angle) * def.radius,
            def.center.y + math.sin(angle) * def.radius,
            def.center.z
        )
    end
    return res
end

local function generateGridNodes(def)
    local res = {}
    for r = 0, def.rows - 1 do
        for c = 0, def.cols - 1 do
            res[#res+1] = vec3(
                def.start.x + (c * def.spacing.x),
                def.start.y + (r * def.spacing.y),
                def.start.z
            )
        end
    end
    return res
end

local function pointInPoly2D(p, poly)
    local x, y = p.x, p.y
    local inside = false
    local j = #poly
    for i = 1, #poly do
        local xi, yi = poly[i].x, poly[i].y
        local xj, yj = poly[j].x, poly[j].y
        local intersect = ((yi > y) ~= (yj > y)) and
            (x < (xj - xi) * (y - yi) / ((yj - yi) ~= 0 and (yj - yi) or 1e-9) + xi)
        if intersect then inside = not inside end
        j = i
    end
    return inside
end

local function generateFieldNodes(def)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    for _, p in ipairs(def.polygon) do
        minX = math.min(minX, p.x); minY = math.min(minY, p.y)
        maxX = math.max(maxX, p.x); maxY = math.max(maxY, p.y)
    end
    local density = def.samplingDensity or 0.25
    local step = 1.0 / density
    local res = {}
    for x = minX, maxX, step do
        for y = minY, maxY, step do
            local p = vec3(x, y, def.polygon[1].z)
            if pointInPoly2D(p, def.polygon) then
                res[#res+1] = p
            end
        end
    end
    return res
end

-- NEW: Helper to spawn a single entity server-side
local function spawnServerPed(modelName, coords, heading, isStatic, scenario)
    local mhash = type(modelName) == 'number' and modelName or GetHashKey(modelName)
    local ped = CreatePed(4, mhash, coords.x, coords.y, coords.z - 1.0, heading or 0.0, false, true)
    
    RequestModel(mhash)
    Wait(500)
    
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)

    if isStatic then
        FreezeEntityPosition(ped, true)
    end

    if scenario then
        TaskStartScenarioInPlace(ped, scenario, 0, true)
    end
    
    return ped
end

-- NEW: Server-side cleanup function
local function cleanupEntities()
    -- Cleanup Props (triggers client deletion)
    TriggerClientEvent('farming:client:deletePropByNodeKey', -1, propState)
    propState = {}
    propLocationMap = {}
    
    -- Cleanup Store Peds
    for storeId, ped in pairs(storePeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    storePeds = {}
    
    -- Cleanup Roaming Animals
    for animalId, ped in pairs(roamingAnimals) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    roamingAnimals = {}

    print('[farming] Cleaned up all server-spawned entities.')
end


-- Build authoritative state and spawn permanent entities on server start
CreateThread(function()
    Wait(2000)
    
    -- 1. Prop Node Generation (Existing Logic)
    for _, location in pairs(Locations or {}) do
        if location.propsEnabled then
            -- ... [existing prop generation logic] ...
            for _, cdef in ipairs(location.collection) do
                if cdef.props and #cdef.props > 0 then
                    local positions = {}
                    if cdef.type == 'radius' then
                        positions = generateRadiusNodes(cdef)
                    elseif cdef.type == 'grid' then
                        positions = generateGridNodes(cdef)
                    elseif cdef.type == 'coords' then
                        positions = cdef.coords or {}
                    elseif cdef.type == 'field' then
                        positions = generateFieldNodes(cdef)
                    else
                        print(('[farming] Unknown prop type: %s'):format(tostring(cdef.type)))
                        goto continue_cdef
                    end

                    for _, pos in ipairs(positions) do
                        local nodeKey = makePropKey(pos, cdef.id)
                        if not propLocationMap[nodeKey] then
                            local choice = cdef.props[1]
                            propState[nodeKey] = {
                                locId = location.id,
                                nodeKey = nodeKey,
                                pos = pos,
                                model = choice.model,
                                heading = choice.heading or 0.0,
                                cdef = cdef
                            }
                            propLocationMap[nodeKey] = true
                        end
                    end
                end
                ::continue_cdef::
            end
        end
    end

    -- 2. Store Ped Spawning (NEW SERVER LOGIC: Fixes multiple shop peds)
    if Config.Stores then
        for _, s in ipairs(Config.Stores) do
            if s.ped and s.ped.model and not storePeds[s.id] then
                local ped = spawnServerPed(s.ped.model, s.coords, s.ped.heading, true, s.ped.scenario)
                storePeds[s.id] = ped
                print(('[farming] Spawned Store Ped %s at (%.2f, %.2f, %.2f)'):format(s.id, s.coords.x, s.coords.y, s.coords.z))
            end
        end
    end
    
    -- 3. Roaming Animal Spawning (NEW SERVER LOGIC: Fixes multiple roaming animals)
    if AnimalConfig and (AnimalConfig.cows or AnimalConfig.chickens) then
        local function spawnAnimalList(list)
            for _, entry in ipairs(list or {}) do
                if entry.id and entry.model then
                    if entry.spawnPoints then -- Handle multi-spawn points
                        for i, pos in ipairs(entry.spawnPoints) do
                            local uniqueId = entry.id .. '_' .. i
                            if not roamingAnimals[uniqueId] then
                                local ped = spawnServerPed(entry.model, pos, 0.0, false, nil) -- Roaming, so not static/frozen
                                roamingAnimals[uniqueId] = ped
                                print(('[farming] Spawned Roaming Animal %s at (%.2f, %.2f, %.2f)'):format(uniqueId, pos.x, pos.y, pos.z))
                            end
                        end
                    elseif entry.coords and not roamingAnimals[entry.id] then -- Handle single spawn point
                        local ped = spawnServerPed(entry.model, entry.coords, 0.0, false, nil)
                        roamingAnimals[entry.id] = ped
                        print(('[farming] Spawned Roaming Animal %s at (%.2f, %.2f, %.2f)'):format(entry.id, entry.coords.x, entry.coords.y, entry.coords.z))
                    end
                end
            end
        end
        spawnAnimalList(AnimalConfig.cows)
        spawnAnimalList(AnimalConfig.chickens)
    end
    
    -- Broadcast authoritative prop state (keyed by nodeKey)
    TriggerClientEvent('farming:client:applyPropState', -1, propState)
end)

-- When a client proposes a new prop (optional path, e.g. player planting), accept if free
RegisterNetEvent('farming:server:registerProp', function(info)
    local nodeKey = info.nodeKey or makePropKey(info.pos, info.cdef.id)
    if propLocationMap[nodeKey] then
        TriggerClientEvent('farming:client:deleteDuplicateProp', source, nodeKey)
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Farm System',
            description = 'Duplicate prop rejected.',
            type = 'error'
        })
        return
    end
    propState[nodeKey] = {
        locId = info.locId,
        nodeKey = nodeKey,
        pos = info.pos,
        model = info.model,
        heading = info.heading,
        cdef = info.cdef
    }
    propLocationMap[nodeKey] = true
    TriggerClientEvent('farming:client:applyPropState', -1, propState)
end)

-- Clear all entities on resource stop (UPDATED to use new cleanup function)
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    cleanupEntities()
end)

-- Admin command to delete within radius (by nodeKey)
local function getDistanceSq(a, b)
    return (a.x - b.x)^2 + (a.y - b.y)^2 + (a.z - b.z)^2
end

RegisterCommand('clearfarmprops', function(src, args)
    local radius = tonumber(args[1])
    if not radius or radius <= 0 or radius > 1000 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Farm Admin',
            description = 'Usage: /clearfarmprops <radius>. Max 1000.',
            type = 'error'
        })
        return
    end

    local Player = QBCore and QBCore.Functions.GetPlayer(src) or nil
    if not Player or not Player.PlayerData or not Player.PlayerData.coords then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Farm Admin',
            description = 'Could not get your position.',
            type = 'error'
        })
        return
    end
    local pos = Player.PlayerData.coords
    local radiusSq = radius * radius

    local deleted = 0
    for nodeKey, info in pairs(propState) do
        if getDistanceSq(pos, info.pos) <= radiusSq then
            TriggerClientEvent('farming:client:deletePropByNodeKey', -1, {[nodeKey] = info})
            propState[nodeKey] = nil
            propLocationMap[nodeKey] = nil
            deleted = deleted + 1
        end
    end

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Farm Admin',
        description = deleted == 0 and ('Found no farm props within %d meters.'):format(radius)
            or ('Deleted %d farm props within %d meters.'):format(deleted, radius),
        type = deleted == 0 and 'inform' or 'success'
    })
end, false)

-- On successful harvest (call this from your collectItem flow)
RegisterNetEvent('farming:server:deletePropNode', function(nodeKey)
    local info = propState[nodeKey]
    if not info then return end
    propState[nodeKey] = nil
    propLocationMap[nodeKey] = nil
    TriggerClientEvent('farming:client:deletePropByNodeKey', -1, {[nodeKey] = info})
end)