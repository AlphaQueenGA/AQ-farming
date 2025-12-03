return {
  id = 'template_location',
  label = 'Template Farm',
  propsEnabled = true,
  collection = {
    {
      id = 'grid_apples',
      type = 'grid',
      item = 'apple',
      qty = { min = 1, max = 3 },

      -- Grid requires start + rows + cols + spacing
      start = vec3(1457.23, 1204.39, 113.0),
      rows = 3,
      cols = 3,
      spacing = vec2(4.0, 4.0),

      props = {
        { model = `prop_tree_birch_03b`, heading = 0.0 },
        { model = `prop_tree_birch_03`, heading = 90.0 }
      },

      prompt = 'Pick apples',
      progressMs = 2500,
      anim = { dict = 'amb@prop_human_movie_studio_light@idle_a', clip = 'idle_a', flag = 0 },
      blip = { showBlip = true, sprite = 686, color = 2, scale = 0.7, label = 'Apple Grid' }
    },

    {
      id = 'radius_oranges',
      type = 'radius',
      item = 'orange',
      qty = { min = 1, max = 2 },

      center = vec3(1436.42, 1196.96, 113.88),
      radius = 20.0,
      points = 12, -- number of sample points around circle

      props = {
        { model = `prop_tree_orange_01`, heading = 0.0 },
        { model = `prop_tree_orange_02`, heading = 180.0 }
      },

      prompt = 'Pick oranges',
      progressMs = 2200,
      anim = { dict = 'amb@prop_human_movie_studio_light@idle_a', clip = 'idle_a', flag = 0 },
      blip = { showBlip = true, sprite = 686, color = 47, scale = 0.7, label = 'Orange Grove' }
    },
    {
      id = 'coords_grapes',
      type = 'coords',
      item = 'grape',
      qty = { min = 2, max = 5 },

      coords = {
        vec3(1445.47, 1115.33, 114.32),
        vec3(1450.04, 1115.11, 114.48),
        vec3(1450.02, 1118.39, 114.43)
      },

      props = {
        { model = `prop_grapes_01`, heading = 0.0 },
        { model = `prop_grapes_02`, heading = 90.0 }
      },

      prompt = 'Harvest grapes',
      progressMs = 2000,
      anim = { dict = 'amb@prop_human_movie_studio_light@idle_a', clip = 'idle_a', flag = 0 },
      blip = { showBlip = true, sprite = 469, color = 7, scale = 0.7, label = 'Vineyard' }
    },
    {
      id = 'field_wheat',
      type = 'field',
      item = 'wheat',
      qty = { min = 1, max = 3 },

      polygon = {
        vec3(2020.0, 4900.0, 42.0),
        vec3(2050.0, 4925.0, 42.0),
        vec3(2070.0, 4890.0, 42.0),
        vec3(2035.0, 4870.0, 42.0),
      },
      vehicleOnly = true, -- must be in tractor/harvester
      samplingDensity = 0.3,

      props = {
        { model = `prop_wheat_01`, heading = 0.0 },
        { model = `prop_wheat_02`, heading = 90.0 }
      },

      prompt = 'Harvest wheat (vehicle required)',
      progressMs = 2000,
      anim = { dict = 'amb@prop_human_movie_studio_light@idle_a', clip = 'idle_a', flag = 0 },
      blip = { showBlip = true, sprite = 469, color = 46, scale = 0.7, label = 'Wheat Field' }
    }


  }
}