AnimalConfig = {
  cows = {
    {
      id = 'cow_group_1',
      model = `a_c_cow`,
      prompt = 'Milk cow',
      item = 'milk',
      qty = { min = 1, max = 1 },
      requiresItem = 'bucket',
      cooldownMs = 60000,
      spawnPoints = {
        vec3(1745.2, 4698.9, 43.3),
        vec3(1752.0, 4690.5, 43.1),
        vec3(1738.6, 4684.2, 43.0)
      },
      roam = { enabled = true, radius = 25.0, wander = true, speed = 1.0 }
    }
  },
  chickens = {
    {
      id = 'chicken_group_1',
      model = `a_c_chickenhawk`,
      prompt = 'Collect eggs',
      item = 'egg',
      qty = { min = 1, max = 3 },
      cooldownMs = 45000,
      spawnPoints = {
        vec3(1738.7, 4692.2, 43.1),
        vec3(1742.1, 4695.2, 43.1)
      },
      roam = { enabled = true, radius = 15.0, wander = true, speed = 1.2 }
    }
  },
  beehives = {
    {
      id = 'beehive_1',
      model = `prop_beehive_01`,
      prompt = 'Harvest honey',
      item = 'honey',
      qty = { min = 1, max = 1 },
      requiresItem = 'smoker',
      cooldownMs = 90000,
      coords = vec3(1733.2, 4687.4, 43.1)
    }
  }
}