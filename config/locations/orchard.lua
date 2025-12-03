return {
  id = 'orchard_1',
  label = 'Apple & Pear Orchard',
  propsEnabled = true,
  collection = {
    {
      id = 'apple_grid',
      type = 'grid',
      item = 'apple',
      qty = { min = 1, max = 3 },
      start = vec3(2312.12, 4819.33, 34.20),
      rows = 6,
      cols = 8,
      spacing = vec2(3.0, 3.0),
      prop = { model = `p_tree_apple_01`, heading = 0.0 },
      prompt = 'Pick apples',
      progressMs = 2500
    },
    {
      id = 'pear_grid',
      type = 'grid',
      item = 'pear',
      qty = { min = 1, max = 2 },
      start = vec3(2320.12, 4825.33, 34.20),
      rows = 4,
      cols = 5,
      spacing = vec2(3.0, 3.0),
      prop = { model = `p_tree_pear_01`, heading = 0.0 },
      prompt = 'Pick pears',
      progressMs = 2500
    }
  }
}