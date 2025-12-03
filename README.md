Installation
- Dependencies:
- QBCore (current stable)
- ox_lib (zones, progressbars, notifications)
- qb-inventory (items + images for shop UI)
- Optional: oxmysql (set Config.useDatabase = true)
- Install:
- Place resource as aq_farming
- Ensure fxmanifest.lua matches provided
- Add to server.cfg: ensure ox_lib, qb-core, qb-inventory, aq_farming (order matters)
Configuration
- Global: config/config.lua
- enableBlips, enablePropSpawning, cleanupOnStop, useDatabase
- defaultHarvestTime, maxSpawnsPerZone, tickRate
- jobBlipsOnly, allowedJobsForBlips
- Animals: config/animals.lua for per-type defaults
- Locations: config/locations/*.lua
- Multiple files supported; each can define zones, animals, shops
Zones
- Types: radius, grid, coords, field (poly)
- Each zone:
- id, type, coords/center/radius/grid
- requiredVehicleModel (optional)
- props, propModel(s), maxProps
- harvestableItems with chance/min/max
- harvestTime, handHarvest, anim
- cooldown, showBlip, blip, sync
Spawning and cleanup
- Server-side spawning: props/NPCs via CreateObject/CreatePed; synced to clients
- Pooling: per-zone max; respawn via export ForceRespawnProps
- Cleanup: all entities deleted on resource stop/restart server-side; clients clear local state
Harvest mechanics
- Hand harvest: press E inside zone → ox_lib progress bar + optional animation
- Vehicle harvest: server validates requiredVehicleModel or class
- Cooldowns: per-player per-zone enforced server-side
- Rewards: server awards items via QBCore Player.Functions.AddItem
Shops
- NPC ped: server-spawned, invincible/frozen
- NUI: responsive HTML/CSS/JS; images loaded via qb-inventory identifiers (nui path)
- Buy/Sell: price configurable; multipliers via Config.shopBuyMultiplier/Config.shopSellMultiplier
- Open: enter shop zone and press E (or prompt via ox_lib)
Persistence (optional)
- Animals: production timers can be saved with oxmysql when Config.useDatabase = true
- Tables: example schema included; tailor as needed
Developer notes
- No targeting: all interactions via ox_lib zones + E key
- Server authority: validation of position, vehicle, cooldown, and item awards
- Exports: GetZoneInfo, ForceRespawnProps, HarvestZone
- Events: requestHarvest, syncSpawnedEntities, openShop
- Debug: aq_zones, aq_props
- Extensibility: add more locations under config/locations; tune pooling/tickRate per server performance