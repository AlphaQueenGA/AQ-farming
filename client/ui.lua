RegisterNUICallback('close', function(_, cb)
  SetNuiFocus(false, false)
  cb(true)
end)

RegisterNUICallback("sellItems", function(data, cb)
    TriggerServerEvent("aq-farming:sellItems", data.storeId, data.items)
    cb("ok")
end)