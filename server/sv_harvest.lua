local QBCore = exports['qb-core']:GetCoreObject()

local function validateVehicleRequirement(src, zone)
  if not zone.requiredVehicleModel then return true end
  local ped = GetPlayerPed(src)
  local veh = GetVehiclePedIsIn(ped, false)
  if veh == 0 then return false, 'You must be in the required vehicle.' end
  local model = GetEntityModel(veh)
  local required = zone.requiredVehicleModel
  local whitelist = Config.vehicleClasses[required] or { required }
  for _, name in ipairs(whitelist) do
    if model == joaat(name) then
      return true
    end
  end
  return false, 'Wrong vehicle for this harvest.'
end

local function awardItems(src, zone)
  local xPlayer = QBCore.Functions.GetPlayer(src)
  if not xPlayer then return false, 'Player not found' end
  local awarded = {}

  for _, entry in ipairs(zone.harvestableItems or {}) do
    if math.random() < (entry.chance or 0) then
      local amount = math.random(entry.min or 1, entry.max or 1)
      local ok = xPlayer.Functions.AddItem(entry.item, amount)
      if ok then
        table.insert(awarded, { item = entry.item, amount = amount })
      else
        return false, 'Inventory full'
      end
    end
  end

  return true, awarded
end

local function playerWithinZone(src, zone)
  -- Server-side validation: rough check using player coords vs zone type
  local ped = GetPlayerPed(src)
  local pcoords = GetEntityCoords(ped)
  if zone.type == 'radius' and zone.center and zone.radius then
    return #(pcoords - zone.center) <= zone.radius + 2.0
  elseif zone.type == 'coords' and zone.coords then
    for _, c in ipairs(zone.coords) do
      if #(pcoords - c) <= 3.0 then return true end
    end
    return false
  elseif zone.type == 'grid' and zone.center and zone.grid then
    local points = {}
    local rows, cols, spacing = zone.grid.rows, zone.grid.cols, zone.grid.spacing
    local origin = zone.center
    for r = 0, rows - 1 do
      for c = 0, cols - 1 do
        local x = origin.x + (c * spacing)
        local y = origin.y + (r * spacing)
        table.insert(points, vector3(x, y, origin.z))
      end
    end
    for _, c in ipairs(points) do
      if #(pcoords - c) <= 3.0 then return true end
    end
    return false
  elseif zone.type == 'field' and zone.coords then
    -- Treat polygon as set of nodes; simple proximity validation
    for _, c in ipairs(zone.coords) do
      if #(pcoords - c) <= 5.0 then return true end
    end
    return false
  end
  return false
end

function TriggerHarvest(src, zoneId)
  local zone = Farming.zones[zoneId]
  if not zone then return false, 'Invalid zone' end

  local can, reason = Farming:CanHarvest(src, zoneId)
  if not can then return false, reason end

  local vehOk, vReason = validateVehicleRequirement(src, zone)
  if not vehOk then return false, vReason end

  local inZone = playerWithinZone(src, zone)
  if not inZone then return false, 'You are not in the zone.' end

  local ok, awardedOrErr = awardItems(src, zone)
  if not ok then return false, awardedOrErr end

  Farming:SetHarvestTime(src, zoneId)
  return true, awardedOrErr
end

RegisterNetEvent('aq_farming:server:requestHarvest', function(zoneId)
  local src = source
  local ok, result = TriggerHarvest(src, zoneId)
  if ok then
    TriggerClientEvent('aq_farming:client:harvestSuccess', src, zoneId, result)
  else
    TriggerClientEvent('aq_farming:client:harvestFailed', src, zoneId, result or 'Harvest failed')
  end
end)
