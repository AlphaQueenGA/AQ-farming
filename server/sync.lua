-- Periodic cleanup hook in case stray props exist without references
CreateThread(function()
  while true do
    Wait(Config.PropCleanupDelayMs)
    -- In this simplified version we trust state; if needed, verify entities by netId and prune dead ones
    TriggerClientEvent('farming:client:refreshProps', -1, propState or {})
  end
end)