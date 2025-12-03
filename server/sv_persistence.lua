-- Optional oxmysql persistence for animal production state
if Config.useDatabase then
  MySQL.ready(function()
    -- Create tables if not exist (simple example)
    MySQL.query([[
      CREATE TABLE IF NOT EXISTS aq_farming_animals (
        id VARCHAR(64) PRIMARY KEY,
        type VARCHAR(32),
        readyAt BIGINT,
        units INT
      )
    ]])
  end)

  -- Example save on resource stop
  AddEventHandler('onResourceStop', function(resName)
    if resName ~= GetCurrentResourceName() then return end
    for aId, a in pairs(Farming.animals) do
      local atype = Animals.types[a.cfg.type]
      if atype then
        for idx, prod in pairs(a.production) do
          MySQL.query('REPLACE INTO aq_farming_animals (id, type, readyAt, units) VALUES (?, ?, ?, ?)', {
            ("%s_%d"):format(aId, idx), a.cfg.type, prod.readyAt, prod.units
          })
        end
      end
    end
  end)
end