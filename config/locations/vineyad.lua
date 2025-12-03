return {
  id = 'vineyard_1',
  label = 'Vineyard',
  propsEnabled = false, -- invisible collection spots for performance
  collection = {
    {
      type = 'grid',
      item = 'grapes',
      qty = { min = 2, max = 5 },
      start = vec3(-1850.0, 2190.0, 95.0),
      rows = 10,
      cols = 12,
      spacing = vec2(2.5, 2.5),
      prop = nil,
      prompt = 'Collect grapes',
      progressMs = 1800
    }
  }
}