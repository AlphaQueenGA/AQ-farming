local storePoints = {}

AddEventHandler('farming:client:initStores', function()
  if storePoints.__init then return end
  storePoints.__init = true

  for _, s in ipairs(Config.Stores) do
    if not storePoints[s.id] then
      -- spawn ped and create point
      local model = type(s.ped.model) == 'number' and s.ped.model or GetHashKey(s.ped.model)
      RequestModel(model); while not HasModelLoaded(model) do Wait(0) end
      local ped = CreatePed(4, model, s.coords.x, s.coords.y, s.coords.z - 1.0, s.ped.heading or 0.0, false, true)
      SetBlockingOfNonTemporaryEvents(ped, true); FreezeEntityPosition(ped, true); SetEntityInvincible(ped, true)
      if s.ped.scenario then TaskStartScenarioInPlace(ped, s.ped.scenario, 0, true) end

      local point = lib.points.new({
        coords = s.coords,
        distance = 25.0,
        onEnter = function() lib.showTextUI('[E] Talk to Store Clerk') end,
        onExit = function() lib.hideTextUI() end,
        nearby = function(self)
          if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(ped)) <= (s.radius or 2.0)
            and IsControlJustPressed(0, 38) then
            TriggerEvent('farming:client:openStore', s.id)
          end
        end
      })

      storePoints[s.id] = { ped = ped, point = point }
    end
  end
end)

RegisterNetEvent('farming:client:openStore', function(storeId)
  SetNuiFocus(true, true)
  SendNUIMessage({
    action = 'open',
    storeId = storeId,
    whitelist = getStoreWhitelist(storeId),
    imgRoot = Config.QBInventoryImageRoot
  })
end)

function getStoreWhitelist(storeId)
  for _, s in ipairs(Config.Stores) do
    if s.id == storeId then return s.whitelist end
  end
  return {}
end