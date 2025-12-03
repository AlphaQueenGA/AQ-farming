return {
  id = 'hellhound_ranch',
  label = 'Hellhounds Ranch',
  propsEnabled = true,
  collection = {
    {
      id = 'hell_apple',
      type = 'grid',
      item = 'apple',
      qty = { min = 1, max = 3 },

      start = vec3(1457.23, 1204.39, 113.0),
      rows = 3,
      cols = 3,
      spacing = vec3(4.0, 4.0, 0.0),

      props = {
        { model = "prop_tree_birch_03b", heading = 0.0 }
      },

      prompt = 'Pick apples',
      progressMs = 5000,
      anim = { dict = 'amb@prop_human_movie_studio_light@idle_a', clip = 'idle_a', flag = 0 },
      blip = { showBlip = false, sprite = 686, color = 2, scale = 0.7, label = 'Apple Orchard' }
    }
  }
}