RegisterNetEvent('farming:server:sellItem', function(item, amount, price)
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    if Player.Functions.RemoveItem(item, amount) then
        Player.Functions.AddMoney('cash', price * amount)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Farm Store',
            description = ('Sold %d %s for $%d'):format(amount, item, price * amount),
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Farm Store',
            description = 'Not enough items to sell',
            type = 'error'
        })
    end
end)