local sharedConfig = require 'config.shared'

-- Functions

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

local function getClosestSchool(pedCoords)
    local distance = #(pedCoords - sharedConfig.drivingSchools[1].coords)
    local closest = 1
    for i = 1, #sharedConfig.drivingSchools do
        local school = sharedConfig.drivingSchools[i]
        local dist = #(pedCoords - school.coords)
        if dist < distance then
            distance = dist
            closest = i
        end
    end
    return closest
end

-- Events

RegisterNetEvent('qb-cityhall:server:requestId', function(item, hall)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end
    local itemInfo = sharedConfig.cityhalls[hall].licenses[item]
    if not Player.Functions.RemoveMoney("cash", itemInfo.cost) then
        return exports.qbx_core:Notify(src, Lang:t('error.not_enough_money', {cost = itemInfo.cost}), 'error')
    end
    local metadata
    if itemInfo.item == "id_card" then
        metadata = {
            type = string.format('%s %s', Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname),
            description = string.format('CID: %s  \nBirth date: %s  \nSex: %s  \nNationality: %s',
            Player.PlayerData.citizenid, Player.PlayerData.charinfo.birthdate, Player.PlayerData.charinfo.gender == 0 and 'Male' or 'Female', Player.PlayerData.charinfo.nationality)
        }
    elseif itemInfo.item == "driver_license" then
        metadata = {
            type = 'Class C Driver License',
            description = string.format('First name: %s  \nLast name: %s  \nBirth date: %s',
            Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, Player.PlayerData.charinfo.birthdate)
        }
    elseif itemInfo.item == "weaponlicense" then
        metadata = {
            type = string.format('%s %s', Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname),
            description = string.format('First name: %s  \nLast name: %s  \nBirth date: %s',
            Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, Player.PlayerData.charinfo.birthdate)
        }
    else
        return DropPlayer(src, Lang:t('error.exploit_attempt'))
    end
    exports.ox_inventory:AddItem(src, itemInfo.item, 1, metadata)
    exports.qbx_core:Notify(src, Lang:t('info.item_received', {label = itemInfo.label, cost = itemInfo.cost}), 'success')
end)

RegisterNetEvent('qb-cityhall:server:sendDriverTest', function()
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end
    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local closestDrivingSchool = getClosestSchool(pedCoords)
    local instructors = sharedConfig.drivingSchools[closestDrivingSchool].instructors
    for i = 1, #instructors do
        local citizenid = instructors[i]
        local instructor = exports.qbx_core:GetPlayerByCitizenId(citizenid)
        if instructor then
            TriggerClientEvent("qb-cityhall:client:sendDriverEmail", instructor.PlayerData.source, Player.PlayerData.charinfo)
        else
            local mailData = {
                sender = Lang:t('email.sender'),
                subject = Lang:t('email.subject'),
                message = Lang:t('email.message', {firstname = Player.PlayerData.charinfo.firstname, lastname = Player.PlayerData.charinfo.lastname, phone = Player.PlayerData.charinfo.phone}),
                button = {}
            }
            TriggerEvent("qb-phone:server:sendNewMailToOffline", citizenid, mailData)
        end
    end
    exports.qbx_core:Notify(src, Lang:t('info.email_sent'), 'success')
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

-- Commands

lib.addCommand('drivinglicense', {
    help = 'Give a drivers license to someone',
    params = {
        { name = 'id', type = 'playerId', help = "ID of a person" },
    }
}, function(source, args)
    if not args.id then return exports.qbx_core:Notify(source, Lang:t('error.player_not_online'), 'error') end

    local Player = exports.qbx_core:GetPlayer(source)
    local SearchedPlayer = exports.qbx_core:GetPlayer(tonumber(args.id))
    if SearchedPlayer then
        if not SearchedPlayer.PlayerData.metadata["licences"]["driver"] then
            for i = 1, #sharedConfig.drivingSchools do
                for id = 1, #sharedConfig.drivingSchools[i].instructors do
                    if sharedConfig.drivingSchools[i].instructors[id] == Player.PlayerData.citizenid then
                        SearchedPlayer.PlayerData.metadata["licences"]["driver"] = true
                        SearchedPlayer.Functions.SetMetaData("licences", SearchedPlayer.PlayerData.metadata["licences"])
                        exports.qbx_core:Notify(SearchedPlayer.PlayerData.source, Lang:t('success.you_have_passed'), 'success')
                        exports.qbx_core:Notify(source, Lang:t('success.license_granted'), 'success')
                        break
                    end
                end
            end
        else
            exports.qbx_core:Notify(source, Lang:t('error.already_earned_license'), 'error')
        end
    else
        exports.qbx_core:Notify(source, Lang:t('error.player_not_online'), 'error')
    end
end)
