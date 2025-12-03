RegisterNetEvent('farming:server:spawnAnimalProp', function(entry)
  -- Optional: spawn entity server-side and network; for simplicity, rely on client spawn for visuals
  -- You can extend to server-owned animals if needed.
end)

RegisterNetEvent('farming:server:animalCollect', function(animalId)
  local src = source
  local now = GetGameTimer()
  local last = animalCooldowns[animalId] or 0
  local animalEntry

  -- Find entry from AnimalConfig
  local function findAnimal(id)
    for _, a in ipairs(AnimalConfig.cows or {}) do if a.id == id then return a end end
    for _, a in ipairs(AnimalConfig.chickens or {}) do if a.id == id then return a end end
    for _, a in ipairs(AnimalConfig.beehives or {}) do if a.id == id then return a end end
    return nil
  end

  animalEntry = findAnimal(animalId)
  if not animalEntry then return end

  if now - last < (animalEntry.cooldownMs or 30000) then
    TriggerClientEvent('ox_lib:notify', src, { title = 'Farm', description = 'This is not ready yet.', type = 'error' })
    return
  end

  if animalEntry.requiresItem then
    local hasReq = exports[GetCurrentResourceName()] and exports[GetCurrentResourceName()]:HasItem(src, animalEntry.requiresItem)
    if not hasReq then
      TriggerClientEvent('ox_lib:notify', src, { title = 'Farm', description = ('You need a %s.'):format(animalEntry.requiresItem), type = 'error' })
      return
    end
  end

  animalCooldowns[animalId] = now
  local qty = math.random(animalEntry.qty.min, animalEntry.qty.max)
  exports[GetCurrentResourceName()]:GiveFarmItem(src, animalEntry.item, qty)
end)