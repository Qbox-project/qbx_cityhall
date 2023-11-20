local config = require 'config.client'
local sharedConfig = require 'config.shared'

local inRangeCityhall = false
local inRangeDrivingSchool = false
local pedsSpawned = false
local table_clone = table.clone
local blips = {}

-- Functions

local function getClosestHall()
    local playerCoords = GetEntityCoords(cache.ped)
    local distance = #(playerCoords - sharedConfig.cityhalls[1].coords)
    local closest = 1
    for i = 1, #sharedConfig.cityhalls do
        local hall = sharedConfig.cityhalls[i]
        local dist = #(playerCoords - hall.coords)
        if dist < distance then
            distance = dist
            closest = i
        end
    end
    return closest
end

local function pairsInOrder(object, _)
    local a = {}
    for n in pairs(object) do
        a[#a +1] = n
    end
    table.sort(a, _)
    local i = 0
    local iterator = function()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], object[a[i]]
        end
    end
    return iterator
end

local function openCityhallIdentityMenu(closestCityhall)
    local licensesMeta = QBX.PlayerData.metadata.licences
    local availableLicenses = table_clone(sharedConfig.cityhalls[closestCityhall].licenses)
    for license in pairs(availableLicenses) do
        if license and not licensesMeta[license] then
            availableLicenses[license] = nil
        end
    end
    local identityOptions = {}
    for item, id in pairsInOrder(availableLicenses) do
        identityOptions[#identityOptions + 1] = {
            title = id.label,
            description = Lang:t('info.price', {cost = id.cost}),
            onSelect = function()
                TriggerServerEvent('qb-cityhall:server:requestId', item, closestCityhall)
                if not config.useTarget and inRangeCityhall then
                    lib.showTextUI(Lang:t('info.open_cityhall'))
                end
            end
        }
    end
    lib.registerContext({
        id = 'cityhall_identity_menu',
        title = Lang:t('info.identity'),
        menu = 'cityhall_menu',
        onExit = function()
            if not config.useTarget and inRangeCityhall then
                lib.showTextUI(Lang:t('info.open_cityhall'))
            end
        end,
        options = identityOptions
    })
    lib.showContext('cityhall_identity_menu')
end

local function openCityhallEmploymentMenu()
    local jobOptions = {}
    for job, label in pairsInOrder(sharedConfig.employment.jobs) do
        jobOptions[#jobOptions + 1] = {
            title = label,
            onSelect = function()
                TriggerServerEvent('qb-cityhall:server:ApplyJob', job)
                if not config.useTarget and inRangeCityhall then
                    lib.showTextUI(Lang:t('info.open_cityhall'))
                end
            end
        }
    end
    lib.registerContext({
        id = 'cityhall_employment_menu',
        title = Lang:t('info.employment'),
        menu = 'cityhall_menu',
        onExit = function()
            if not config.useTarget and inRangeCityhall then
                lib.showTextUI(Lang:t('info.open_cityhall'))
            end
        end,
        options = jobOptions
    })
    lib.showContext('cityhall_employment_menu')
end

local function openCityhallMenu()
    local closestCityhall = getClosestHall()
    local options = {}
    
    options[#options + 1] = {
        title = Lang:t('info.identity'),
        description = Lang:t('info.obtain_license_identity'),
        onSelect = function()
            openCityhallIdentityMenu(closestCityhall)
        end
    }

    if sharedConfig.employment.enabled then
        options[#options + 1] = {
            title = Lang:t('info.employment'),
            description = Lang:t('info.select_job'),
            onSelect = function()
                openCityhallEmploymentMenu()
            end
        }
    end

    lib.registerContext({
        id = 'cityhall_menu',
        title = Lang:t('info.city_hall'),
        onExit = function()
            if not config.useTarget and inRangeCityhall then
                lib.showTextUI(Lang:t('info.open_cityhall'))
            end
        end,
        options = options
    })
    lib.showContext('cityhall_menu')
    if not config.useTarget then return end
    inRangeCityhall = false
end

local function createBlip(options)
    if not options.coords or type(options.coords) ~= 'table' and type(options.coords) ~= 'vector3' then return error(('createBlip() expected coords in a vector3 or table but received %s'):format(options.coords)) end
    local blip = AddBlipForCoord(options.coords.x, options.coords.y, options.coords.z)
    SetBlipSprite(blip, options.sprite or 1)
    SetBlipDisplay(blip, options.display or 4)
    SetBlipScale(blip, options.scale or 1.0)
    SetBlipColour(blip, options.colour or 1)
    SetBlipAsShortRange(blip, options.shortRange or false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(options.title or 'No Title Given')
    EndTextCommandSetBlipName(blip)
    return blip
end

local function deleteBlips()
    if not next(blips) then return end
    for i = 1, #blips do
        local blip = blips[i]
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    blips = {}
end

local function initBlips()
    for i = 1, #sharedConfig.cityhalls do
        local hall = sharedConfig.cityhalls[i]
        if hall.showBlip then
            blips[#blips + 1] = createBlip({
                coords = hall.coords,
                sprite = hall.blipData.sprite,
                display = hall.blipData.display,
                scale = hall.blipData.scale,
                colour = hall.blipData.colour,
                shortRange = true,
                title = hall.blipData.title
            })
        end
    end
    for i = 1, #sharedConfig.drivingSchools do
        local school = sharedConfig.drivingSchools[i]
        if school.showBlip then
            blips[#blips + 1] = createBlip({
                coords = school.coords,
                sprite = school.blipData.sprite,
                display = school.blipData.display,
                scale = school.blipData.scale,
                colour = school.blipData.colour,
                shortRange = true,
                title = school.blipData.title
            })
        end
    end
end

local function spawnPeds()
    if not config.peds or not next(config.peds) or pedsSpawned then return end
    for i = 1, #config.peds do
        local current = config.peds[i]
        current.model = type(current.model) == 'string' and joaat(current.model) or current.model
        lib.requestModel(current.model)
        local ped = CreatePed(0, current.model, current.coords.x, current.coords.y, current.coords.z, current.coords.w, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, current.scenario, true, true)
        current.pedHandle = ped
        if config.useTarget then
            if current.drivingschool then
                exports.ox_target:addLocalEntity(ped, { {
                    name = 'take_driving_test' .. i,
                    icon = 'fa-solid fa-car-side',
                    label = Lang:t('info.take_lessons'),
                    distance = 1.5,
                    onSelect = function()
                        TriggerServerEvent('qb-cityhall:server:sendDriverTest')
                    end
                } })
            elseif current.cityhall then
                exports.ox_target:addLocalEntity(ped, { {
                    name = 'open_cityhall' .. i,
                    icon = 'fa-solid fa-city',
                    label = Lang:t('info.target_open_cityhall'),
                    distance = 1.5,
                    debug = true,
                    onSelect = function()
                        inRangeCityhall = true
                        openCityhallMenu()
                    end
                } })
            end
        else
            local options = current.zoneOptions
            if options then
                local function onEnterZone(zone)
                    if LocalPlayer.state.isLoggedIn then
                        if current.drivingschool and zone.name == 'driving_school' then
                            inRangeDrivingSchool = true
                            lib.showTextUI(Lang:t('info.e_take_lessons'))
                            CreateThread(function()
                                while inRangeDrivingSchool do
                                    Wait(0)
                                    if IsControlJustPressed(0, 38) then
                                        TriggerServerEvent('qb-cityhall:server:sendDriverTest')
                                        Wait(500)
                                        lib.hideTextUI()
                                    end
                                end
                            end)
                        elseif current.cityhall and zone.name == 'cityhall' then
                            inRangeCityhall = true
                            lib.showTextUI(Lang:t('info.open_cityhall'))
                            CreateThread(function()
                                while inRangeCityhall do
                                    Wait(0)
                                    if IsControlJustPressed(0, 38) then
                                        openCityhallMenu()
                                        Wait(500)
                                        lib.hideTextUI()
                                    end
                                end
                            end)
                        end
                    end
                end

                local function onExitZone(zone)
                    if (zone.name == 'driving_school') or (zone.name == 'cityhall') then
                        lib.hideTextUI()
                        if current.drivingschool then
                            inRangeDrivingSchool = false
                        elseif current.cityhall then
                            inRangeCityhall = false
                        end
                    end
                end

                lib.zones.box({
                    name = current.drivingschool and 'driving_school' or 'cityhall',
                    coords = current.coords.xyz,
                    size = vec3(2, 2, 3),
                    rotation = current.coords.w,
                    debug = false,
                    onEnter = onEnterZone,
                    onExit = onExitZone
                })
            end
        end
    end
    pedsSpawned = true
end

local function deletePeds()
    if not config.peds or not next(config.peds) or not pedsSpawned then return end
    for i = 1, #config.peds do
        local current = config.peds[i]
        if current.pedHandle then
            DeletePed(current.pedHandle)
        end
    end
end

-- Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    initBlips()
    spawnPeds()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    deleteBlips()
    deletePeds()
end)

RegisterNetEvent('qb-cityhall:client:getIds', function()
    TriggerServerEvent('qb-cityhall:server:getIDs')
end)

RegisterNetEvent('qb-cityhall:client:sendDriverEmail', function(charinfo)
    SetTimeout(math.random(2500, 4000), function()
        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = Lang:t('email.sender'),
            subject = Lang:t('email.subject'),
            message = Lang:t('email.message', {firstname = charinfo.firstname, lastname = charinfo.lastname, phone = charinfo.phone}),
            button = {}
        })
    end)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    deleteBlips()
    deletePeds()
end)