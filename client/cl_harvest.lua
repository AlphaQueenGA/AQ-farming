local QBCore = exports['qb-core']:GetCoreObject()
local interactKey = Config.interactKey

-- Local caches
local zones = zones or {}         -- ensure existing reference
local fieldPolys = fieldPolys or {}
local enteredZones = enteredZones or {}

-- Debounce and in-progress flags
local lastKeyPress = 0
local keyDebounce = 250
local isHarvesting = false

-- Utility: safe contains on ox_lib zones
local function zoneContains(zoneObj, pos)
  if not zoneObj or not zoneObj.contains then return false end
  return zoneObj:contains(pos)
end

local function inAnyZone(zone, pos)
  if zone.type == 'field' then
    local poly = fieldPolys[zone.id]
    return zoneContains(poly, pos)
  end

  local zentry = zones[zone.id]
  if type(zentry) == 'table' then
    for _, sphere in ipairs(zentry) do
      if zoneContains(sphere, pos) then
        return true
      end
    end
  else
    if zoneContains(zentry, pos) then
      return true
    end
  end
  return false
end

local function playOptionalAnim(anim)
  if not anim or not anim.dict or anim.dict == '' then return end
  local ped = PlayerPedId()
  RequestAnimDict(anim.dict)
  local tries = 0
  while not HasAnimDictLoaded(anim.dict) and tries < 200 do
    Wait(10)
    tries = tries + 1
  end
  TaskPlayAnim(ped, anim.dict, anim.clip or 'idle_a', 1.0, 1.0, anim.time or -1, anim.flag or 0, 0.0, false, false, false)
end

local function stopAnim(anim)
  if not anim or not anim.dict or anim.dict == '' then return end
  ClearPedTasks(PlayerPedId())
  -- Optionally unload dict for memory hygiene
  RemoveAnimDict(anim.dict)
end

-- Lightweight zone presence polling (uses shared tick rate)
CreateThread(function()
  while true do
    Wait(Config.tickRate)
    local pos = GetEntityCoords(PlayerPedId())
    for zoneId, zone in pairs(FarmingZones or {}) do
      local inside = inAnyZone(zone, pos)
      if inside and not enteredZones[zoneId] then
        enteredZones[zoneId] = true
        -- Optional prompt when entering zones that want an immediate hint
        if Config.openShopViaPrompt and zone.shopId then
          lib.notify({ type = 'inform', description = 'Press E to open shop' })
        elseif zone.handHarvest then
          lib.notify({ type = 'inform', description = 'Press E to harvest' })
        end
      elseif not inside and enteredZones[zoneId] then
        enteredZones[zoneId] = nil
      end
    end
  end
end)

-- Single-zone resolver on demand (prefers nearest match)
local function findActiveZone(pos)
  local nearestId, nearestDist = nil, math.huge
  for zoneId, zone in pairs(FarmingZones or {}) do
    if inAnyZone(zone, pos) then
      -- Prefer field poly boundaries first, then spheres by distance
      if zone.type == 'field' then
        return zoneId, zone
      else
        local anchor = zone.center or (zone.coords and zone.coords[1])
        if anchor then
          local dist = #(pos - anchor)
          if dist < nearestDist then
            nearestDist = dist
            nearestId, nearestZone = zoneId, zone
          end
        else
          -- If no anchor, still return the first match
          return zoneId, zone
        end
      end
    end
  end
  return nearestId, nearestZone
end

-- Key control (E), debounced and guarded against concurrent harvests
CreateThread(function()
  while true do
    Wait(0)
    if IsControlJustReleased(0, interactKey) then
      local now = GetGameTimer()
      if now - lastKeyPress < keyDebounce then
        -- Debounced
        goto continue
      end
      lastKeyPress = now
      if isHarvesting then
        -- Prevent spamming while progress bar running
        goto continue
      end

      local pos = GetEntityCoords(PlayerPedId())
      local zoneId, zone = findActiveZone(pos)
      if zoneId and zone then
        -- If zone has explicit shopId, prefer opening shop over harvest
        if zone.shopId then
          TriggerEvent('aq_farming:client:openShop', zone.shopId)
          goto continue
        end

        -- Start harvest flow (server handles validation for vehicle/cooldown)
        isHarvesting = true
        local cancelled = false

        if zone.handHarvest then
          local time = zone.harvestTime or Config.defaultHarvestTime
          playOptionalAnim(zone.anim)
          local ok = lib.progressBar({
            duration = time,
            label = 'Harvesting...',
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = false, combat = true },
          })
          stopAnim(zone.anim)
          cancelled = not ok
        end

        if not cancelled then
          TriggerServerEvent('aq_farming:server:requestHarvest', zoneId)
        end

        isHarvesting = false
      end
    end
    ::continue::
  end
end)

-- Feedback events
RegisterNetEvent('aq_farming:client:harvestSuccess', function(zoneId, awarded)
  local msg = 'Harvest complete'
  if awarded and #awarded > 0 then
    local parts = {}
    for _, a in ipairs(awarded) do parts[#parts+1] = ('%sx %s'):format(a.amount, a.item) end
    msg = ('You received: %s'):format(table.concat(parts, ', '))
  end
  lib.notify({ type = 'success', description = msg })
end)

RegisterNetEvent('aq_farming:client:harvestFailed', function(zoneId, reason)
  lib.notify({ type = 'error', description = reason or 'Harvest failed' })
end)

-- Server-authoritative spawn sync hook
RegisterNetEvent('aq_farming:server:syncSpawnedEntities', function(zoneId, netIds)
  -- Intentionally no client spawning; server owns lifecycle.
  -- If you want local visibility logic or LOD hints, you can cache netIds here.
end)

RegisterNetEvent('aq_farming:client:cleanup', function()
  enteredZones = {}
  isHarvesting = false
end)