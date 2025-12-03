local propState = {}
local initDone = false

CreateThread(function()
    if initDone then return end
    initDone = true

    Wait(500)
    for _, location in pairs(Locations or {}) do
        if location.propsEnabled then
            for _, cdef in ipairs(location.collection or {}) do
                if cdef.props and #cdef.props > 0 then
                    for _, pos in ipairs(cdef.coords or {}) do
                        local nodeKey = ('%s:%.2f:%.2f:%.2f'):format(cdef.id, pos.x, pos.y, pos.z)
                        if not propState[nodeKey] then
                            propState[nodeKey] = {
                                locId = location.id,
                                nodeKey = nodeKey,
                                pos = pos,
                                model = cdef.props[1].model,
                                heading = cdef.props[1].heading or 0.0,
                                cdef = cdef
                            }
                        end
                    end
                end
            end
        end
    end

    TriggerClientEvent('farming:client:applyPropState', -1, propState)
    TriggerClientEvent('farming:client:initAnimals', -1, AnimalConfig or {})
    TriggerClientEvent('farming:client:initStores', -1)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    propState = {}
    initDone = false
end)

exports('GetPropState', function() return propState end)