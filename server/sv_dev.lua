if Config.enableDevCommands then
  RegisterNetEvent('aq_farming:dev:listProps', function()
    local src = source
    local out = {}
    for zoneId, list in pairs(Farming.props) do
      table.insert(out, ('%s: %d props'):format(zoneId, #(list.netIds or {})))
    end
    TriggerClientEvent('ox_lib:notify', src, { type = 'inform', description = table.concat(out, '\n') })
  end)
end
