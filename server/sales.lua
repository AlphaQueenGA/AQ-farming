RegisterNetEvent('farming:server:sellItems', function(data)
  local src = source
  local storeId = data.storeId
  local items = data.items or {}

  -- Validate store
  local store
  for _, s in ipairs(Config.Stores) do
    if s.id == storeId then store = s break end
  end
  if not store then return end

  local Player = QBCore and QBCore.Functions.GetPlayer(src)
  if not Player then return end

  local total = 0
  for _, req in ipairs(items) do
    local item = req.item
    local qty = math.max(1, math.floor(req.qty))
    local price
    for _, w in ipairs(store.whitelist) do
      if w.item == item then price = w.price break end
    end
    if price then
      local invItem = Player.Functions.GetItemByName(item)
      local invQty = invItem and invItem.amount or 0
      local sellQty = math.min(invQty, qty)
      if sellQty > 0 then
        Player.Functions.RemoveItem(item, sellQty)
        total = total + (sellQty * price)
      end
    end
  end

  if total > 0 then
    Player.Functions.AddMoney('cash', total)
  end

  TriggerClientEvent('farming:client:saleResult', src, { total = total })
end)