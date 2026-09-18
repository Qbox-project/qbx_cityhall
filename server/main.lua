local sharedConfig = require 'config.shared'

local function getClosestHall(pedCoords)
    local distance = #(pedCoords - sharedConfig.cityhalls[1].coords)
    local closest = 1
    for i = 1, #sharedConfig.cityhalls do
        local hall = sharedConfig.cityhalls[i]
        local dist = #(pedCoords - hall.coords)
        if dist < distance then
            distance = dist
            closest = i
        end
    end
    return closest
end

local function isNearCityhall(source, hall)
    if type(hall) ~= 'number' or hall % 1 ~= 0 then return false end

    local cityhall = sharedConfig.cityhalls[hall]
    if not cityhall then return false end

    local ped = GetPlayerPed(source)
    if ped == 0 then return false end

    local pedCoords = GetEntityCoords(ped)
    return #(pedCoords - cityhall.coords) < 20.0
end

local function employmentDistanceCheck(source, job)
    if type(job) ~= 'string' or not sharedConfig.employment.jobs[job] then return false end

    local ped = GetPlayerPed(source)
    if ped == 0 then return false end

    local pedCoords = GetEntityCoords(ped)
    local closestCityhall = getClosestHall(pedCoords)
    return #(pedCoords - sharedConfig.cityhalls[closestCityhall].coords) < 20.0
end

lib.callback.register('qbx_cityhall:server:requestId', function(source, item, hall)
    local player = exports.qbx_core:GetPlayer(source)
    if not player or type(item) ~= 'string' or not isNearCityhall(source, hall) then return false end

    local itemType = sharedConfig.cityhalls[hall].licenses[item]
    local licences = player.PlayerData.metadata.licences
    if not itemType or not licences or licences[item] ~= true then
        exports.qbx_core:Notify(source, locale('error.invalid_type'), 'error')
        return false
    end

    if itemType.item ~= 'id_card' and itemType.item ~= 'driver_license' and itemType.item ~= 'weaponlicense' then
        exports.qbx_core:Notify(source, locale('error.invalid_type'), 'error')
        return false
    end

    if not player.Functions.RemoveMoney('cash', itemType.cost) then
        exports.qbx_core:Notify(source, locale('error.not_enough_money'), 'error')
        return false
    end

    exports.qbx_idcard:CreateMetaLicense(source, itemType.item)
    exports.qbx_core:Notify(source, locale('success.item_recieved') .. itemType.label, 'success')
    return true
end)

lib.callback.register('qbx_cityhall:server:applyJob', function(source, job)
    if not sharedConfig.employment.enabled then
        lib.print.error((
            'Weird applyJob attempt while employment is disabled | source=%s | name=%s | requestedJob=%s'
        ):format(source, GetPlayerName(source), tostring(job)))
        return false
    end

    local player = exports.qbx_core:GetPlayer(source)
    if not player or not employmentDistanceCheck(source, job) then return false end

    if not sharedConfig.employment.jobs[job] then
        exports.qbx_core:Notify(source, locale('error.invalid_job'), 'error')
        return false
    end
    
    player.Functions.SetJob(job, 0)
    exports.qbx_core:Notify(source, locale('success.new_job'), 'success')
end)
