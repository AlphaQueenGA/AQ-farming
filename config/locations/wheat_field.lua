return {
  id = 'wheat_field_1',
  label = 'Wheat Field',
  propsEnabled = true,
  collection = {
    {
      id = 'wheat_field_area',
      type = 'field',
      item = 'wheat',
      qty = { min = 1, max = 3 },
      polygon = {
        vec3(2020.0, 4900.0, 42.0),
        vec3(2050.0, 4925.0, 42.0),
        vec3(2070.0, 4890.0, 42.0),
        vec3(2035.0, 4870.0, 42.0),
      },
      vehicleOnly = true,
      prop = { model = `prop_wheat_02`, heading = 0.0 },
      samplingDensity = 0.3,
      prompt = 'Harvest wheat (vehicle required)',
      progressMs = 2000
    }
  }
}