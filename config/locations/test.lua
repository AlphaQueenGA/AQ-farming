Locations = Locations or {}
Locations['example_farm'] = {
  zones = {
    -- {
    --   id = "wheat_field_01",
    --   type = "field",
    --   coords = { vector3(100.0, 200.0, 34.0), vector3(110.0, 200.0, 34.0) }, -- polygon points
    --   props = true,
    --   propModels = { `prop_plant_01`, `prop_plant_02` },
    --   maxProps = 40,
    --   requiredVehicleModel = "tractor",
    --   harvestableItems = {
    --     { item = "wheat", chance = 0.9, min = 1, max = 3 },
    --     { item = "stalk", chance = 0.2, min = 1, max = 1 },
    --   },
    --   handHarvest = true,
    --   anim = { dict = 'amb@prop_human_movie_studio_light@idle_a', clip = 'idle_a', flag = 0 },
    --   harvestTime = 3500,
    --   cooldown = 60000,
    --   showBlip = true,
    --   blip = { sprite = 85, scale = 0.6, color = 2 },
    --   sync = true,
    -- },
    {
      id = "orchard_grid_01",
      type = "grid",
      grid = { rows = 3, cols = 3, spacing = 4.0 },
      center = vec3(1457.23, 1204.39, 113.0),
      props = true,
      propModels = { "prop_tree_birch_03b" },
      maxProps = 9,
      harvestableItems = {
        { item = "apple", chance = 0.8, min = 1, max = 2 },
      },
      handHarvest = true,
      harvestTime = 2500,
      cooldown = 45000,
      showBlip = true,
      sync = true,
    },
    -- {
    --   id = "herbs_points_01",
    --   type = "coords",
    --   coords = { vector3(165.0, 230.0, 35.2), vector3(168.0, 232.2, 35.2), vector3(171.0, 234.8, 35.2) },
    --   props = false,
    --   propModels = {},
    --   maxProps = 0,
    --   harvestableItems = {
    --     { item = "herb", chance = 0.7, min = 1, max = 1 },
    --   },
    --   handHarvest = true,
    --   harvestTime = 1500,
    --   cooldown = 30000,
    --   showBlip = false,
    --   sync = false,
    -- },
  },
  animals = {
    {
      id = 'cows_loc_01',
      type = 'cow',
      coords = { vector3(210.0, 180.0, 33.8), vector3(215.0, 182.0, 33.8), vector3(219.0, 185.0, 33.8) },
      count = 3,
      showBlip = true,
      blip = { sprite = 141, scale = 0.7, color = 5 },
      sync = true,
    },
    {
      id = 'chickens_loc_01',
      type = 'chicken',
      coords = { vector3(230.0, 190.0, 33.5), vector3(233.0, 193.0, 33.5) },
      count = 6,
      showBlip = false,
      sync = true,
    },
    {
      id = 'beehives_loc_01',
      type = 'beehive',
      coords = { vector3(240.0, 175.0, 33.0) },
      count = 2,
      showBlip = false,
      sync = true,
    },
  },
  shops = {
    {
      id = 'farm_shop_01',
      pedModel = `a_m_m_farmer_01`,
      coords = vector3(2310.36, 4885.13, 41.81),
      heading = 48.44,
      showBlip = true,
      blip = { sprite = 52, scale = 0.7, color = 2 },
      inventory = {
        sell = {
          { item = 'wheat', name = 'Wheat', price = 12, category = 'crops' },
          { item = 'corn', name = 'Corn', price = 10, category = 'crops' },
          { item = 'milk', name = 'Milk', price = 10, category = 'animal' },
          { item = 'egg', name = 'Eggs', price = 8, category = 'animal' },
          { item = 'apple', name = 'Apple', price = 14, category = 'crops' },
        }
      }
    }
  }
}
