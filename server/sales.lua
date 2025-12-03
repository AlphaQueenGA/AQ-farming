RegisterNetEvent('farming:server:completeLocalOrder', function(orderId, reward)
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    Player.Functions.AddMoney('cash', reward)
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Local Order',
        description = ('Completed order %s, earned $%d'):format(orderId, reward),
        type = 'success'
    })
end)