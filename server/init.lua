local propState = {}        -- authoritative state keyed by nodeKey
local propLocationMap = {}  -- quick lookup for duplicates
local initDone = false      -- guard flag

local function vec3(x, y, z) return { x = x, y = y, z = z } end

local function makePropKey(pos, colId)
    return ('%s:%.2f:%.2f:%.2f'):format(colId, pos.x, pos.y, pos.z)
end

-- Node generators
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

-- Build authoritative state once
CreateThread(function()
    if initDone then return end
    initDone = true

    Wait(2000)
    for _, location in pairs(Locations or {}) do
        if location.propsEnabled then
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

                    print(('[farming] Generated %d nodes for %s'):format(#positions, cdef.id or cdef.item))

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

    -- Broadcast authoritative state once
    TriggerClientEvent('farming:client:applyPropState', -1, propState)
end)

-- Register new prop (e.g. player planting)
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

-- Delete prop by nodeKey
RegisterNetEvent('farming:server:deletePropNode', function(nodeKey)
    local info = propState[nodeKey]
    if not info then return end
    propState[nodeKey] = nil
    propLocationMap[nodeKey] = nil
    TriggerClientEvent('farming:client:deletePropByNodeKey', -1, {[nodeKey] = info})
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    propState = {}
    propLocationMap = {}
end)

-- Optional: refresh props manually
RegisterNetEvent('farming:server:refreshProps', function()
    propState = {}
    propLocationMap = {}
    initDone = false
    TriggerEvent('farming:server:init') -- or rerun your init thread
end)