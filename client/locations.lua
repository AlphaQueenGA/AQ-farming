local nodes = {}
local CollectState = require('client/collection')

local function makeNodeKey(pos, id)
    return ('%s:%.2f:%.2f:%.2f'):format(id, pos.x, pos.y, pos.z)
end

local function registerNodeInteraction(locId, cdef, pos)
    local nodeKey = makeNodeKey(pos, cdef.id)
    nodes[locId] = nodes[locId] or { points = {} }
    for _, existing in ipairs(nodes[locId].points) do
        if existing.nodeKey == nodeKey then return end
    end

    local label = cdef.prompt or ('Collect ' .. (cdef.item or 'item'))
    local point = lib.points.new({
        coords = pos,
        distance = 25.0,
        onEnter = function() lib.showTextUI(('[E] %s'):format(label)) end,
        onExit = function() lib.hideTextUI() end,
        nearby = function(self)
            if #(self.coords - GetEntityCoords(PlayerPedId())) <= 2.0 and IsControlJustPressed(0, 38) then
                if not CollectState.lock(locId, nodeKey) then return end
                TriggerEvent('farming:client:attemptCollect', locId, cdef, pos, nodeKey)
            end
        end
    })

    table.insert(nodes[locId].points, { nodeKey = nodeKey, point = point })
end

AddEventHandler('farming:client:initLocations', function(loadedLocations)
    -- cleanup old points
    for locId, data in pairs(nodes) do
        for _, entry in ipairs(data.points) do
            if entry.point and entry.point.remove then entry.point:remove() end
        end
    end
    nodes = {}

    for _, location in pairs(loadedLocations) do
        for _, cdef in ipairs(location.collection or {}) do
            local positions = cdef.coords or {}
            print(('[farming] Generated %d nodes for %s'):format(#positions, cdef.id or cdef.item))
            for _, pos in ipairs(positions) do
                registerNodeInteraction(location.id, cdef, pos)
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for _, data in pairs(nodes) do
        for _, entry in ipairs(data.points) do
            if entry.point and entry.point.remove then entry.point:remove() end
        end
    end
    nodes = {}
end)