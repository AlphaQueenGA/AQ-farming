local QBCore = exports['qb-core']:GetCoreObject()

-- Only sell items now
RegisterNetEvent('aq_farming:server:sellItem', function(shopId, item, price, count)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    if not xPlayer then return end

    local s = Farming.shops[shopId]
    if not s then return end

    local finalPrice = math.floor((price or 0) * (Config.shopSellMultiplier or 1.0)) * (count or 1)
    if finalPrice <= 0 then return end

    local has = xPlayer.Functions.GetItemByName(item)
    if not has or (has.amount or 0) < (count or 1) then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Not enough items' })
        return
    end

    if xPlayer.Functions.RemoveItem(item, count or 1) then
        xPlayer.Functions.AddMoney('cash', finalPrice)
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = ('Sold %sx %s'):format(count or 1, item)
        })
    end
end)