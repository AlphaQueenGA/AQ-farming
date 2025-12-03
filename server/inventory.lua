local areaCooldowns = {}


local function addItem(src, item, qty)
  -- qb-inventory export style; adjust for your version if different
  local Player = QBCore and QBCore.Functions.GetPlayer(src) or nil
  if Player and Player.Functions.AddItem then
    Player.Functions.AddItem(item, qty)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add')
  else
    print(('[farming] AddItem fallback for %s x%d'):format(item, qty))
  end
end

local function hasItem(src, itemName)
  local Player = QBCore and QBCore.Functions.GetPlayer(src)
  if not Player then return false end
  local item = Player.Functions.GetItemByName(itemName)
  return item ~= nil and item.amount > 0
end

exports('GiveFarmItem', addItem)
exports('HasItem', hasItem)

RegisterNetEvent('farming:server:collectItem', function(payload)
    local src = source
    local colId = payload.colId
    local item = payload.item
    local qty = payload.qty

    -- Cooldown check
    local now = GetGameTimer()
    areaCooldowns[src] = areaCooldowns[src] or {}
    local last = areaCooldowns[src][colId] or 0
    if now - last < Config.CollectCooldownMs then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Farm', description = 'You must wait before harvesting again.', type = 'error' })
        return
    end
    areaCooldowns[src][colId] = now

    -- Actually give the item
    local success = exports['qb-inventory']:AddItem(src, item, qty)
    if not success then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Farm', description = 'Inventory full.', type = 'error' })
    else
        TriggerClientEvent('ox_lib:notify', src, { title = 'Farm', description = ('You collected %d %s'):format(qty, item), type = 'success' })
    end
end)
