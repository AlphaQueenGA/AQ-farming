local nodes = {} -- per-location generated collection nodes
local CollectState = require('client/collection_state') -- separate state module

-- Generate nodes for radius type
local function generateRadiusNodes(def)
    local res = {}
    local step = (2.0 * math.pi) / def.points
    for i = 1, def.points do
        local angle = step * i
        local x = def.center.x + math.cos(angle) * def.radius
        local y = def.center.y + math.sin(angle) * def.radius
        local z = def.center.z
        res[#res+1] = vec3(x, y, z)
    end
    return res
end

-- Generate nodes for grid type
local function generateGridNodes(def)
    local res = {}
    for r = 0, def.rows - 1 do
        for c = 0, def.cols - 1 do
            local x = def.start.x + (c * def.spacing.x)
            local y = def.start.y + (r * def.spacing.y)
            local z = def.start.z
            res[#res+1] = vec3(x, y, z)
        end
    end
    return res
end

-- Simple point-in-polygon (2D)
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

-- Generate nodes for field type
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

-- Register interaction for a single node
local function registerNodeInteraction(locId, cdef, pos)
    local nodeKey = CollectState.makeNodeKey(pos, cdef.id)

    -- Deduplication: skip if already registered
    if nodes[locId] then
        for _, existing in ipairs(nodes[locId].points) do
            if existing.nodeKey == nodeKey then
                return -- already registered
            end
        end
    end

    local label = cdef.prompt or ('Collect ' .. (cdef.item or 'item'))
    local id = ('farm_node_%s_%s_%s'):format(locId, cdef.type, tostring(#nodes[locId].points + 1))

    local point = lib.points.new({
        coords = pos,
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
                if not CollectState.lock(locId, nodeKey) then
                    return -- already collecting here
                end
                TriggerEvent('farming:client:attemptCollect', locId, cdef, pos, nodeKey)
            end
        end
    })

    nodes[locId].points[#nodes[locId].points+1] = {
        id = id,
        nodeKey = nodeKey,
        point = point,
        pos = pos,
        cdef = cdef
    }
end

-- Add a location and generate its nodes
local function addLocation(location)
    nodes[location.id] = { points = {} }

    for _, cdef in ipairs(location.collection) do
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
            print('[farming] Unknown collection type: ' .. tostring(cdef.type))
        end

        -- FIX: Removed duplicate print log
        -- print(('[farming] Generated %d nodes for %s'):format(#positions, cdef.id or cdef.item))

        for _, pos in ipairs(positions) do
            registerNodeInteraction(location.id, cdef, pos)
        end

        if cdef.blip and cdef.blip.showBlip then
            local blipPos = positions[1] or cdef.center or cdef.start
            if blipPos then
                local blip = AddBlipForCoord(blipPos.x, blipPos.y, blipPos.z)
                SetBlipSprite(blip, cdef.blip.sprite or 1)
                SetBlipColour(blip, cdef.blip.color or 0)
                SetBlipScale(blip, cdef.blip.scale or 0.7)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(cdef.blip.label or location.label)
                EndTextCommandSetBlipName(blip)
            end
        end
    end
end

-- Init all locations
AddEventHandler('farming:client:initLocations', function(loadedLocations)
    for _, loc in pairs(loadedLocations) do
        if not nodes[loc.id] then
            addLocation(loc)
        else
            print(('[farming] Skipping duplicate init for location %s'):format(loc.id))
        end
    end
end)