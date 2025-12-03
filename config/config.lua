-- config/config.lua
Config = {}

-- **Global toggles**
Config.enableBlips = true
Config.enablePropSpawning = true
Config.cleanupOnStop = true
Config.useDatabase = false -- optional oxmysql persistence
Config.defaultHarvestTime = 3500
Config.maxSpawnsPerZone = 40
Config.debug = false

-- **Permissions**
Config.jobBlipsOnly = false
Config.allowedJobsForBlips = { 'farmer' } -- optional

-- **Keys and UI**
Config.interactKey = 38 -- E
Config.openShopViaPrompt = true -- ox_lib context prompt on zone enter

-- **Vehicle whitelist examples**
Config.vehicleClasses = {
  tractor = { 'tractor', 'handler', 'bulldozer' }, -- model names; extend per server usage
}

-- **Cooldowns and anti-exploit**
Config.zoneHarvestCooldown = 60000 -- default per-zone cooldown per player (ms)
Config.zoneEntryCooldown = 1500 -- debounce enter events
Config.harvestStaminaCost = 0 -- placeholder; integrate with stamina resource if present
Config.tickRate = 500 -- ms for zone polling (lightweight)

-- **Pooling**
Config.pooling = {
  enabled = true,
  perZoneMax = 40,
  recycleDistance = 120.0, -- despawn props when player far
}

-- **Shops**
Config.shopBuyMultiplier = 1.0
Config.shopSellMultiplier = 1.0

-- **Blip defaults**
Config.defaultBlip = { sprite = 85, scale = 0.6, color = 2 }

-- **Developer debug command**
Config.enableDevCommands = true