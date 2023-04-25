local QBCore = exports['qbx-core']:GetCoreObject()
local availableJobs = {
    ["unemployed"] = "Unemployed",
    ["trucker"] = "Trucker",
    ["taxi"] = "Taxi",
    ["tow"] = "Tow Truck",
    ["reporter"] = "News Reporter",
    ["garbage"] = "Garbage Collector",
    ["bus"] = "Bus Driver",
    ["hotdog"] = "Hot Dog Stand"
}

-- Functions
local function genderString(sexString)
    if not sexString == 1 then sexString = 'Female' else  sexString = 'Male' end return sexString
end

local function giveStarterItems()
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid, firstname, lastname, gender, birthdate, nationality = Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, genderString(Player.PlayerData.charinfo.gender), Player.PlayerData.charinfo.birthdate, Player.PlayerData.charinfo.nationality
    for _, v in pairs(QBCore.Shared.StarterItems) do
        if v.item == 'id_card' then
            local metadata = {
                type = string.format('%s %s', firstname, lastname),
                description = string.format('CID: %s  \nDOB: %s  \nGender: %s  \nNationality: %s ', citizenid, birthdate, gender, nationality),
                citizenid = citizenid,
                firstname = firstname,
                lastname = lastname,
                gender = gender,
                birthdate = birthdate,
                nationality = nationality,
            }
            exports.ox_inventory:AddItem(source, v.item, v.amount, metadata)
        elseif v.item == 'driver_license' then
            local metadata = {
                type = 'Class C Driver License',
                description = string.format('CID: %s  \nFirst Name: %s  \nLast Name: %s  \nDOB: %s  \nGender: %s  \nNationality: %s ', citizenid, firstname, lastname, birthdate, gender, nationality),
                citizenid = citizenid,
                firstname = firstname,
                lastname = lastname,
                gender = gender,
                birthdate = birthdate,
                nationality = nationality,
            }
            exports.ox_inventory:AddItem(source, v.item, v.amount, metadata)
        elseif v.item == "weaponlicense" then
            local metadata = {
                type = 'Weapon License',
                description = string.format('CID: %s  \nFirst Name: %s  \nLast Name: %s  \nDOB: %s  \nGender: %s  \nNationality: %s ', citizenid, firstname, lastname, birthdate, gender, nationality),
                citizenid = citizenid,
                firstname = firstname,
                lastname = lastname,
                gender = gender,
                birthdate = birthdate,
                nationality = nationality,
            }
            exports.ox_inventory:AddItem(source, v.item, v.amount, metadata)
        else
            exports.ox_inventory:AddItem(source, v.item, v.amount)
        end
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

lib.callback.register('qb-cityhall:server:receiveJobs', function(source)
    return availableJobs
end)

-- Events

RegisterNetEvent('qb-cityhall:server:requestId', function(item, hall)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local itemInfo = Config.Cityhalls[hall].licenses[item]
    local citizenid, firstname, lastname, gender, birthdate, nationality = Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, genderString(Player.PlayerData.charinfo.gender), Player.PlayerData.charinfo.birthdate, Player.PlayerData.charinfo.nationality
    if not Player.Functions.RemoveMoney("cash", itemInfo.cost) then 
        return TriggerClientEvent('ox_lib:notify', src, { description = ('You don\'t have enough money on you, you need %s cash'):format(itemInfo.cost), type = 'error' })
    end
    local metadata = {}
    if item == "id_card" then
        metadata = {
            type = string.format('%s %s', firstname, lastname),
            description = string.format('CID: %s  \nDOB: %s  \nGender: %s  \nNationality: %s ', citizenid, birthdate, gender, nationality),
            citizenid = citizenid,
            firstname = firstname,
            lastname = lastname,
            gender = gender,
            birthdate = birthdate,
            nationality = nationality,
        }
    elseif item == "driver_license" then
        metadata = {
            type = 'Class C Driver License',
            description = string.format('CID: %s  \nFirst Name: %s  \nLast Name: %s  \nDOB: %s  \nGender: %s  \nNationality: %s ', citizenid, firstname, lastname, birthdate, gender, nationality),
            citizenid = citizenid,
            firstname = firstname,
            lastname = lastname,
            gender = gender,
            birthdate = birthdate,
            nationality = nationality,
        }
    elseif item == "weaponlicense" then
        metadata = {
            type = 'Weapon License',
            description = string.format('CID: %s  \nFirst Name: %s  \nLast Name: %s  \nDOB: %s  \nGender: %s  \nNationality: %s ', citizenid, firstname, lastname, birthdate, gender, nationality),
            citizenid = citizenid,
            firstname = firstname,
            lastname = lastname,
            gender = gender,
            birthdate = birthdate,
            nationality = nationality,
        }
    else
        return DropPlayer(src, 'Attempted exploit abuse')
    end
    if not exports.ox_inventory:AddItem(src, item, 1, metadata) then return end
    TriggerClientEvent('ox_lib:notify', src, { description = ('You have received your %s for $%s'):format(QBCore.Shared.Items[item].label, itemInfo.cost), type = 'success' })
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
        local SchoolPlayer = QBCore.Functions.GetPlayerByCitizenId(citizenid)
        if SchoolPlayer then
            TriggerClientEvent("qb-cityhall:client:sendDriverEmail", SchoolPlayer.PlayerData.source, Player.PlayerData.charinfo)
        else
            local mailData = {
                sender = "Township",
                subject = "Driving lessons request",
                message = "Hello,<br><br>We have just received a message that someone wants to take driving lessons.<br>If you are willing to teach, please contact them:<br>Name: <strong>".. Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. "<br />Phone Number: <strong>"..Player.PlayerData.charinfo.phone.."</strong><br><br>Kind regards,<br>Township Los Santos",
                button = {}
            }
            TriggerEvent("qb-phone:server:sendNewMailToOffline", citizenid, mailData)
        end
    end
    TriggerClientEvent('ox_lib:notify', source, { description = "An email has been sent to driving schools, and you will be contacted automatically", type = 'success' })
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
        return DropPlayer(source, "Attempted exploit abuse")
    end
    Player.Functions.SetJob(job, 0)
    TriggerClientEvent('ox_lib:notify', source, { description = Lang:t('info.new_job', {job = JobInfo.label}), type = 'success' })
end)

RegisterNetEvent('qb-cityhall:server:getIDs', giveStarterItems)

-- Commands

lib.addCommand('drivinglicense', {
    help = 'Give a drivers license to someone',
    params = {
        { name = 'id', help = "ID of a person", type = 'PlayerId' },
    }
}, function(source, args)
    if not args.id then return TriggerClientEvent('ox_lib:notify', source, { description = "Player Not Online", type = 'error' }) end

    local Player = QBCore.Functions.GetPlayer(source)
    local SearchedPlayer = QBCore.Functions.GetPlayer(args.id)
    if SearchedPlayer then
        if not SearchedPlayer.PlayerData.metadata["licences"]["driver"] then
            for i = 1, #Config.DrivingSchools do
                for id = 1, #Config.DrivingSchools[i].instructors do
                    if Config.DrivingSchools[i].instructors[id] == Player.PlayerData.citizenid then
                        SearchedPlayer.PlayerData.metadata["licences"]["driver"] = true
                        SearchedPlayer.Functions.SetMetaData("licences", SearchedPlayer.PlayerData.metadata["licences"])
                        TriggerClientEvent('ox_lib:notify', SearchedPlayer.PlayerData.source, { description = "You have passed! Pick up your drivers license at the town hall", type = 'success' })
                        TriggerClientEvent('ox_lib:notify', source, { description = ("Player with ID %s has been granted access to a driving license"):format(SearchedPlayer.PlayerData.source), type = 'success' })
                        break
                    end
                end
            end
        else
            TriggerClientEvent('ox_lib:notify', source, { description = "Can't give permission for a drivers license, this person already has permission", type = 'error' })
        end
    else
        TriggerClientEvent('ox_lib:notify', source, { description = "Player Not Online", type = 'error' })
    end
end)
