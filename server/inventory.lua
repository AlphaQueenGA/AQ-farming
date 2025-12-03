local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("aq-farming:sellItems", function(storeId, items)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Find store config
    local store = nil
    for _, s in ipairs(Config.Stores) do
        if s.id == storeId then
            store = s
            break
        end
    end
    if not store then
        TriggerClientEvent("QBCore:Notify", src, "Invalid store!", "error")
        return
    end

    local totalEarned = 0
    for _, req in ipairs(items or {}) do
        local whitelistEntry = nil
        for _, w in ipairs(store.whitelist) do
            if w.item == req.item then
                whitelistEntry = w
                break
            end
        end

        if whitelistEntry then
            local item = Player.Functions.GetItemByName(req.item)
            if item and item.amount >= req.qty then
                Player.Functions.RemoveItem(req.item, req.qty)
                local payout = req.qty * whitelistEntry.price
                Player.Functions.AddMoney("cash", payout, "farming-sell")
                totalEarned = totalEarned + payout
            end
        end
    end

    if totalEarned > 0 then
        TriggerClientEvent("QBCore:Notify", src, ("You earned $%d"):format(totalEarned), "success")
        TriggerClientEvent("farming:client:saleResult", src, totalEarned)
    else
        TriggerClientEvent("QBCore:Notify", src, "You have nothing to sell!", "error")
    end
end)