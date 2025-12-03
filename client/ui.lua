RegisterNUICallback('close', function(_, cb)
  SetNuiFocus(false, false)
  cb(true)
end)

RegisterNUICallback('sellItems', function(data, cb)
  -- data: { storeId, items: [{ item, qty }] }
  TriggerServerEvent('farming:server:sellItems', data)
  cb(true)
end)