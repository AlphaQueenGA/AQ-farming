Animals = {
  types = {
    cow = {
      label = 'Cow',
      productionItem = 'milk',
      productionTime = 15 * 60000, -- 15 minutes (ms)
      maxUnits = 3,
      spawnModel = `a_c_cow`, -- ped model (optional)
      useVisual = true, -- toggle for purely logical farming (no visual)
    },
    chicken = {
      label = 'Chicken',
      productionItem = 'egg',
      productionTime = 10 * 60000,
      maxUnits = 5,
      spawnModel = `a_c_hen`,
      useVisual = true,
    },
    beehive = {
      label = 'Beehive',
      productionItem = 'honey',
      productionTime = 20 * 60000,
      maxUnits = 2,
      spawnModel = `prop_beehive_01`, -- prop (optional)
      useVisual = true,
    },
  }
}