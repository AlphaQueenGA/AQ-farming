local propState = exports['aq-farming']:GetPropState()

RegisterNetEvent('farming:server:registerProp', function(info)
    local nodeKey = info.nodeKey
    if propState[nodeKey] then
        TriggerClientEvent('farming:client:deleteDuplicateProp', source, nodeKey)
        return
    end
    propState[nodeKey] = info
    TriggerClientEvent('farming:client:applyPropState', -1, propState)
end)

RegisterNetEvent('farming:server:deletePropNode', function(nodeKey)
    if not propState[nodeKey] then return end
    propState[nodeKey] = nil
    TriggerClientEvent('farming:client:deletePropByNodeKey', -1, {[nodeKey] = true})
end)