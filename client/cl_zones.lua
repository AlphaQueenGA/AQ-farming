local zones = {}
local fieldPolys = {} -- ox_lib poly zones
local enteredZones = {}
local lastEnter = 0

local function addBlipIfAllowed(z)
  if not Config.enableBlips or not z.showBlip then return end
  if Config.jobBlipsOnly then
    local job = exports['qb-core']:GetCoreObject().Functions.GetPlayerData().job
    local allowed = false
    for _, j in ipairs(Config.allowedJobsForBlips) do
      if job and job.name == j then allowed = true break end
    end
    if not allowed then return end
  end
  local pos = z.center or (z.coords and z.coords[1]) or vector3(0,0,0)
  local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
  local b = z.blip or Config.defaultBlip
  SetBlipSprite(blip, b.sprite or 85)
  SetBlipScale(blip, b.scale or 0.6)
  SetBlipColour(blip, b.color or 2)
  BeginTextCommandSetBlipName('STRING')
  AddTextComponentString(z.id)
  EndTextCommandSetBlipName(blip)
end

CreateThread(function()
  -- Build zones from server shared config (already loaded via shared_scripts)
  for zoneId, z in pairs(FarmingZones or {}) do
    -- FarmingZones is built below via merge
  end
end)

-- Merge shared config into a client table for convenience
FarmingZones = {}
CreateThread(function()
  for _, loc in pairs(Locations or {}) do
    for _, z in ipairs(loc.zones or {}) do
      FarmingZones[z.id] = z
      addBlipIfAllowed(z)

      if z.type == 'radius' and z.center and z.radius then
        local sphere = lib.zones.sphere({
          coords = z.center,
          radius = z.radius,
          debug = Config.debug
        })
        zones[z.id] = sphere
      elseif z.type == 'coords' and z.coords then
        -- Make small spheres per point
        zones[z.id] = {}
        for i, c in ipairs(z.coords) do
          zones[z.id][i] = lib.zones.sphere({ coords = c, radius = 2.5, debug = Config.debug })
        end
      elseif z.type == 'grid' and z.center and z.grid then
        zones[z.id] = {}
        local rows, cols, spacing = z.grid.rows, z.grid.cols, z.grid.spacing
        local origin = z.center
        for r = 0, rows - 1 do
          for c = 0, cols - 1 do
            local x = origin.x + (c * spacing)
            local y = origin.y + (r * spacing)
            local node = lib.zones.sphere({ coords = vector3(x, y, origin.z), radius = 2.5, debug = Config.debug })
            table.insert(zones[z.id], node)
          end
        end
      elseif z.type == 'field' and z.coords then
        local poly = lib.zones.poly({
          points = z.coords,
          thickness = 6.0,
          debug = Config.debug
        })
        fieldPolys[z.id] = poly
      end
    end

    for _, shop in ipairs(loc.shops or {}) do
      addBlipIfAllowed({
        id = shop.id, showBlip = shop.showBlip, blip = shop.blip, center = shop.coords
      })
    end
  end
end)
