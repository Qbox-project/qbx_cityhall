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

RegisterNetEvent('qb-cityhall:server:requestId', function(item, hall)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end
    local itemInfo = sharedConfig.cityhalls[hall].licenses[item]
    if not Player.Functions.RemoveMoney("cash", itemInfo.cost) then
        return exports.qbx_core:Notify(src, Lang:t('error.not_enough_money', {cost = itemInfo.cost}), 'error')
    end
    if itemInfo.item == "id_card" then
        exports.qbx_idcard:CreateMetaLicense(src, 'id_card')
    elseif itemInfo.item == "driver_license" then
        exports.qbx_idcard:CreateMetaLicense(src, 'driver_license')
    elseif itemInfo.item == "weaponlicense" then
        exports.qbx_idcard:CreateMetaLicense(src, 'weaponlicense')
    else
        return DropPlayer(src, Lang:t('error.exploit_attempt'))
    end
    exports.qbx_core:Notify(src, Lang:t('info.item_received', {label = itemInfo.label, cost = itemInfo.cost}), 'success')
end)

RegisterNetEvent('qb-cityhall:server:ApplyJob', function(job)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end
    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local closestCityhall = getClosestHall(pedCoords)
    local cityhallCoords = sharedConfig.cityhalls[closestCityhall].coords
    local JobInfo = exports.qbx_core:GetJobs()[job]
    if #(pedCoords - cityhallCoords) >= 20.0 or not sharedConfig.employment.jobs[job] then
        return DropPlayer(src, Lang:t('error.exploit_attempt'))
    end
    Player.Functions.SetJob(job, 0)
    exports.qbx_core:Notify(src, Lang:t('info.new_job', {job = JobInfo.label}), 'success')
end)
