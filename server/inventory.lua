local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("aq-farming:sellItems", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    local itemName = "farm_item" -- change to your actual item name
    local item = Player.Functions.GetItemByName(itemName)

    if item and item.amount > 0 then
        local sellPrice = Config.SellPrice or 10
        local total = item.amount * sellPrice

        Player.Functions.RemoveItem(itemName, item.amount)
        Player.Functions.AddMoney("cash", total, "farming-sell")

        TriggerClientEvent("QBCore:Notify", src, ("You sold %d %s for $%d"):format(item.amount, itemName, total), "success")
    else
        TriggerClientEvent("QBCore:Notify", src, "You have nothing to sell!", "error")
    end
end)