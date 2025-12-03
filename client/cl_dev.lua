if Config.enableDevCommands then
  RegisterCommand('aq_zones', function()
    local active = {}
    for id, z in pairs(FarmingZones) do table.insert(active, id) end
    print(('[aq_farming] Active zones: %s'):format(table.concat(active, ', ')))
  end, false)

  RegisterCommand('aq_props', function()
    TriggerServerEvent('aq_farming:dev:listProps')
  end, false)
end
