local availableJobs = {
    ["unemployed"] = "Unemployed",
    ["trucker"] = "Trucker",
    ["taxi"] = "Taxi",
    ["tow"] = "Tow Truck",
    ["reporter"] = "News Reporter",
    ["garbage"] = "Garbage Collector",
    ["bus"] = "Bus Driver",
}

-- Functions

local function giveStarterItems()
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    for _, v in pairs(QBCore.Shared.StarterItems) do
        local info = {}
        if v.item == "id_card" then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == "driver_license" then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = "Class C Driver License"
        end
        Player.Functions.AddItem(v.item, 1, nil, info)
    end
end

local function getClosestHall(pedCoords)
    local distance = #(pedCoords - Config.Cityhalls[1].coords)
    local closest = 1
    for i = 1, #Config.Cityhalls do
        local hall = Config.Cityhalls[i]
        local dist = #(pedCoords - hall.coords)
        if dist < distance then
            distance = dist
            closest = i
        end
    end
    return closest
end

local function getClosestSchool(pedCoords)
    local distance = #(pedCoords - Config.DrivingSchools[1].coords)
    local closest = 1
    for i = 1, #Config.DrivingSchools do
        local school = Config.DrivingSchools[i]
        local dist = #(pedCoords - school.coords)
        if dist < distance then
            distance = dist
            closest = i
        end
    end
    return closest
end

-- Callbacks

lib.callback.register('qb-cityhall:server:receiveJobs', function()
    return availableJobs
end)

-- Events

RegisterNetEvent('qb-cityhall:server:requestId', function(item, hall)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local itemInfo = Config.Cityhalls[hall].licenses[item]
    if not Player.Functions.RemoveMoney("cash", itemInfo.cost) then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.not_enough_money', {cost = itemInfo.cost}), 'error')
    end
    local metadata = {}
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
    TriggerClientEvent('QBCore:Notify', src, Lang:t('info.item_received', {label = QBCore.Shared.Items[item].label, cost = itemInfo.cost}), 'success')
end)

RegisterNetEvent('qb-cityhall:server:sendDriverTest', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local closestDrivingSchool = getClosestSchool(pedCoords)
    local instructors = Config.DrivingSchools[closestDrivingSchool].instructors
    for i = 1, #instructors do
        local citizenid = instructors[i]
        local instructor = QBCore.Functions.GetPlayerByCitizenId(citizenid)
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
    TriggerClientEvent('QBCore:Notify', src, Lang:t('info.email_sent'), 'success')
end)

RegisterNetEvent('qb-cityhall:server:ApplyJob', function(job)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local closestCityhall = getClosestHall(pedCoords)
    local cityhallCoords = Config.Cityhalls[closestCityhall].coords
    local JobInfo = QBCore.Shared.Jobs[job]
    if #(pedCoords - cityhallCoords) >= 20.0 or not availableJobs[job] then
        return DropPlayer(src, Lang:t('error.exploit_attempt'))
    end
    Player.Functions.SetJob(job, 0)
    TriggerClientEvent('QBCore:Notify', src, Lang:t('info.new_job', {job = JobInfo.label}), 'success')
end)

RegisterNetEvent('qb-cityhall:server:getIDs', giveStarterItems)

-- Commands

lib.addCommand('drivinglicense', {
    help = 'Give a drivers license to someone',
    params = {
        { name = 'id', type = 'playerId', help = "ID of a person" },
    }
}, function(source, args)
    if not args.id then return TriggerClientEvent('QBCore:Notify', source, Lang:t('error.player_not_online'), 'error') end

    local Player = QBCore.Functions.GetPlayer(source)
    local SearchedPlayer = QBCore.Functions.GetPlayer(tonumber(args.id))
    if SearchedPlayer then
        if not SearchedPlayer.PlayerData.metadata["licences"]["driver"] then
            for i = 1, #Config.DrivingSchools do
                for id = 1, #Config.DrivingSchools[i].instructors do
                    if Config.DrivingSchools[i].instructors[id] == Player.PlayerData.citizenid then
                        SearchedPlayer.PlayerData.metadata["licences"]["driver"] = true
                        SearchedPlayer.Functions.SetMetaData("licences", SearchedPlayer.PlayerData.metadata["licences"])
                        TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source, Lang:t('success.you_have_passed'), 'success')
                        TriggerClientEvent('QBCore:Notify', source, Lang:t('success.license_granted'), 'success')
                        break
                    end
                end
            end
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t('error.already_earned_license'), 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.player_not_online'), 'error')
    end
end)
