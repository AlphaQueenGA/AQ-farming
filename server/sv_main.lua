local QBCore = exports['qb-core']:GetCoreObject()

Farming = {
  zones = {},           -- [zoneId] = zoneConfig + runtime state
  shops = {},           -- [shopId] = shopConfig + ped netId
  props = {},           -- [zoneId] = { netIds = {} }
  animals = {},         -- [animalZoneId] = { peds/props netIds, production timers per entity }
  cooldowns = {},       -- [playerId] = { [zoneId] = lastHarvestTime }
}

function Farming:GetZone(zoneId)
  return Farming.zones[zoneId]
end

function Farming:CanHarvest(playerId, zoneId)
  local now = GetGameTimer()
  local cz = Farming.cooldowns[playerId]
  local zone = Farming.zones[zoneId]
  if not zone then return false, 'Invalid zone' end
  local cd = zone.cooldown or Config.zoneHarvestCooldown
  if not cz then
    Farming.cooldowns[playerId] = {}
    cz = Farming.cooldowns[playerId]
  end
  local last = cz[zoneId] or 0
  if now - last < cd then
    return false, 'Cooldown active'
  end
  return true
end

function Farming:SetHarvestTime(playerId, zoneId)
  Farming.cooldowns[playerId] = Farming.cooldowns[playerId] or {}
  Farming.cooldowns[playerId][zoneId] = GetGameTimer()
end

exports('GetZoneInfo', function(zoneId)
  return Farming:GetZone(zoneId)
end)

exports('ForceRespawnProps', function(zoneId)
  TriggerEvent('aq_farming:server:respawnProps', zoneId)
end)

exports('HarvestZone', function(playerId, zoneId)
  local src = playerId
  local xPlayer = QBCore.Functions.GetPlayer(src)
  if not xPlayer then return false, 'Player not found' end
  return TriggerHarvest(src, zoneId)
end)
