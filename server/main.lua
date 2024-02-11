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

local function distanceCheck(source, job)
    local ped = GetPlayerPed(source)
    local pedCoords = GetEntityCoords(ped)
    local closestCityhall = getClosestHall(pedCoords)
    local cityhallCoords = sharedConfig.cityhalls[closestCityhall].coords
    if #(pedCoords - cityhallCoords) >= 20.0 or not sharedConfig.employment.jobs[job] then
        return false
    end
    return true
end

lib.callback.register('qbx_cityhall:server:requestId', function(source, item, hall)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end
    local itemType = sharedConfig.cityhalls[hall].licenses[item]

    if itemType.item ~= 'id_card' and itemType.item ~= 'driver_license' and itemType.item ~= 'weaponlicense' then
        return exports.qbx_core:Notify(source, locale('error.invalid_type'), 'error')
    end

    if not player.Functions.RemoveMoney('cash', itemType.cost) then
        return exports.qbx_core:Notify(source, locale('error.not_enough_money'), 'error')
    end

    exports.qbx_idcard:CreateMetaLicense(source, itemType.item)
    exports.qbx_core:Notify(source, locale('success.item_recieved') .. itemType.label, 'success')
end)

lib.callback.register('qbx_cityhall:server:applyJob', function(source, job)
    local player = exports.qbx_core:GetPlayer(source)
    if not player or not distanceCheck(source, job) then return end

    player.Functions.SetJob(job, 0)
    exports.qbx_core:Notify(source, locale('success.new_job'), 'success')
end)
