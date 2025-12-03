local lastCollect = 0

local function canCollect()
    local now = GetGameTimer()
    if now - lastCollect < Config.CollectCooldownMs then
        return false
    end
    lastCollect = now
    return true
end

local function isVehicleModelAllowed()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then return false end
    local veh = GetVehiclePedIsIn(ped, false)
    local model = GetEntityModel(veh)
    for _, allow in ipairs(Config.VehicleHarvestModels) do
        local mhash = type(allow) == 'number' and allow or GetHashKey(allow)
        if model == mhash then
            return true
        end
    end
    return false
end

AddEventHandler('farming:client:attemptCollect', function(locId, cdef, pos)
    local label = cdef.prompt or ('Collect ' .. (cdef.item or 'item'))

    -- enforce vehicle requirement if set
    if cdef.vehicleOnly and not isVehicleModelAllowed() then
        lib.notify({ title = 'Farm', description = 'You need a harvester/tractor to collect here.', type = 'error' })
        return
    end

    -- progress UI
    if not lib.progressCircle({
        duration = cdef.progressMs or Config.ProgressDurationMs.default,
        position = 'bottom',
        label = label,
        disable = { move = true, car = cdef.vehicleOnly or false, combat = true }
    }) then
        return
    end

    -- play animation once
    if cdef.anim then
        local ped = PlayerPedId()
        RequestAnimDict(cdef.anim.dict)
        while not HasAnimDictLoaded(cdef.anim.dict) do Wait(0) end
        TaskPlayAnim(ped, cdef.anim.dict, cdef.anim.clip, 3.0, -1.0,
            cdef.progressMs or 2000, cdef.anim.flag or 0, 0, false, false, false)
    end

    -- grant item via server
    local qty = math.random(cdef.qty.min, cdef.qty.max)
    TriggerServerEvent('farming:server:collectItem', {
        locId = locId,
        colId = cdef.id,
        item = cdef.item,
        qty = qty,
        pos = pos,
        type = cdef.type
    })
end)