local storePoints = {}   -- track point per store (Ped is now server-owned)

AddEventHandler('farming:client:initStores', function()
  for _, s in ipairs(Config.Stores) do
    -- Blip (Remains the same)
    if s.blip and s.blip.showBlip then
      local blip = AddBlipForCoord(s.coords.x, s.coords.y, s.coords.z)
      SetBlipSprite(blip, s.blip.sprite or 52)
      SetBlipColour(blip, s.blip.color or 2)
      SetBlipScale(blip, s.blip.scale or 0.8)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(s.blip.label or s.label)
      EndTextCommandSetBlipName(blip)
    end

    -- Ped spawn logic REMOVED: Now handled by server/init.lua
    if s.ped and s.ped.model then
      -- Interaction with ped
      local point = lib.points.new({
        coords = s.coords,
        distance = 25.0,
        onEnter = function()
          lib.showTextUI('[E] Talk to Store Clerk')
        end,
        onExit = function()
          lib.hideTextUI()
        end,
        nearby = function(self)
          -- CHANGE: Checking distance against the static point coords (self.coords)
          local dist = #(GetEntityCoords(PlayerPedId()) - self.coords)
          if dist <= s.radius and IsControlJustPressed(0, 38) then
            TriggerEvent('farming:client:openStore', s.id)
          end
        end
      })

      -- store references so we can clean up later
      storePoints[s.id] = { point = point } -- Removed ped reference
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

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
  if resourceName ~= GetCurrentResourceName() then return end
  for _, data in pairs(storePoints) do
    if data.point and data.point.remove then
      data.point:remove()
    end
    -- Removed local ped deletion logic since it's now server-owned
  end
  storePoints = {}
end)