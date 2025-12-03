Config = {}

-- Global interaction
Config.ProgressDurationMs = {
  default = 2500,
  animal = 3000,
  vehicleHarvest = 2000
}

-- Anti-spam cooldowns
Config.CollectCooldownMs = 1500

Config.VehicleHarvestModels = {
  `tractor`,      
  `tractor2`,    

}

Config.FieldServerDistanceMax = 5.0

-- Store(s)
Config.Stores = {
  {
    id = 'farm_store_1',
    label = 'Farm Co-op',
    coords = vector3(2310.04, 4885.02, 41.81),
    radius = 2.0,
    whitelist = {
      { item = 'apple', price = 8 },
      { item = 'pear', price = 9 },
      { item = 'wheat', price = 6 },
      { item = 'milk', price = 20 },
      { item = 'egg', price = 5 },
      { item = 'honey', price = 25 }
    },

    -- NEW: blip settings
    blip = {
      showBlip = true,
      sprite = 52,       -- store icon
      color = 2,
      scale = 0.8,
      label = 'Farm Store'
    },

    -- NEW: ped settings
    ped = {
      model = `a_m_m_farmer_01`,   -- ped model hash
      heading = 53.03,              -- facing direction
      scenario = 'WORLD_HUMAN_CLIPBOARD' -- optional idle animation
    }
  }
}

-- Paths to qb-inventory icons (used by NUI)
-- typical qb-inventory image path is html/images inside that resource
Config.QBInventoryImageRoot = 'nui://qb-inventory/html/images/' -- e.g., apple.png

-- Load multiple location config files
Config.LocationFiles = {
  -- 'config/locations/orchard.lua',
  -- 'config/locations/wheat_field.lua',
  -- 'config/locations/vineyard.lua',
  'config/locations/hellhound_ranch.lua',
  -- 'config/locations/_template.lua',
  
}

-- Props
Config.PropCleanupDelayMs = 30000  -- cleanup orphaned props if players leave
Config.PropSpawnDistanceMax = 200.0 -- never spawn props too far from player
Config.UsePlaceObjectGroundProperly = true
Config.GroundRaycastMaxAttempts = 5

-- Vehicle harvest class whitelist for Field-only harvest
Config.VehicleHarvestClasses = { 19, 20 } -- e.g., tractors/bulldozers (adjust as needed)