local config = require 'config.client'
local sharedConfig = require 'config.shared'
local inRangeCityhall = false
local pedsSpawned = false
local table_clone = table.clone
local blips = {}

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
        a[#a + 1] = n
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

local function openIdentificationMenu(closestCityhall)
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
            description = locale('info.price', id.cost),
            onSelect = function()
                lib.callback.await('qbx_cityhall:server:requestId', false, item, closestCityhall)
                if not config.useTarget and inRangeCityhall then
                    lib.showTextUI(locale('info.open_cityhall'))
                end
            end
        }
    end
    lib.registerContext({
        id = 'cityhall_identity_menu',
        title = locale('info.identity'),
        menu = 'cityhall_menu',
        onExit = function()
            if not config.useTarget and inRangeCityhall then
                lib.showTextUI(locale('info.open_cityhall'))
            end
        end,
        options = identityOptions
    })
    lib.showContext('cityhall_identity_menu')
end

local function openEmploymentMenu()
    local jobOptions = {}
    for job, label in pairsInOrder(sharedConfig.employment.jobs) do
        jobOptions[#jobOptions + 1] = {
            title = label,
            onSelect = function()
                lib.callback.await('qbx_cityhall:server:applyJob', false, job)
                if not config.useTarget and inRangeCityhall then
                    lib.showTextUI(locale('info.open_cityhall'))
                end
            end
        }
    end
    lib.registerContext({
        id = 'cityhall_employment_menu',
        title = locale('info.employment'),
        menu = 'cityhall_menu',
        onExit = function()
            if not config.useTarget and inRangeCityhall then
                lib.showTextUI(locale('info.open_cityhall'))
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
        title = locale('info.identity'),
        description = locale('info.obtain_license_identity'),
        onSelect = function()
            openIdentificationMenu(closestCityhall)
        end
    }

    if sharedConfig.employment.enabled then
        options[#options + 1] = {
            title = locale('info.employment'),
            description = locale('info.select_job'),
            onSelect = openEmploymentMenu
        }
    end

    lib.registerContext({
        id = 'cityhall_menu',
        title = locale('info.cityhall'),
        onExit = function()
            if not config.useTarget and inRangeCityhall then
                lib.showTextUI(locale('info.open_cityhall'))
            end
        end,
        options = options
    })
    lib.showContext('cityhall_menu')
    if not config.useTarget then return end
    inRangeCityhall = false
end

local function createBlip(cityhall)
    local blip = AddBlipForCoord(cityhall.coords.x, cityhall.coords.y, cityhall.coords.z)
    SetBlipSprite(blip, cityhall.blip.sprite or 1)
    SetBlipDisplay(blip, cityhall.blip.display or 4)
    SetBlipScale(blip, cityhall.blip.scale or 1.0)
    SetBlipColour(blip, cityhall.blip.colour or 1)
    SetBlipAsShortRange(blip, cityhall.blip.shortRange or false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(cityhall.blip.label or locale('info.cityhall'))
    EndTextCommandSetBlipName(blip)
    return blip
end

local function deleteBlips()
    if not blips then return end
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
        local cityhall = sharedConfig.cityhalls[i]

        if not cityhall.showBlip or not cityhall.blip then return end

        blips[#blips + 1] = createBlip({blip = cityhall.blip, coords = cityhall.coords})
    end
end

local function spawnPeds()
    if not config.peds or not next(config.peds) or pedsSpawned then return end
    for i = 1, #config.peds do
        local current = config.peds[i]
        current.model = type(current.model) == 'string' and joaat(current.model) or current.model
        lib.requestModel(current.model, 5000)
        local ped = CreatePed(0, current.model, current.coords.x, current.coords.y, current.coords.z, current.coords.w, false, false)
        SetModelAsNoLongerNeeded(current.model)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, current.scenario, 0, true)
        current.pedHandle = ped
        if config.useTarget then
            exports.ox_target:addLocalEntity(ped, {{
                name = 'open_cityhall' .. i,
                icon = 'fa-solid fa-city',
                label = locale('info.target_open_cityhall'),
                distance = 1.5,
                debug = true,
                onSelect = function()
                    inRangeCityhall = true
                    openCityhallMenu()
                end
            }})
        else
            local options = current.zoneOptions
            if options then
                lib.zones.box({
                    name = 'cityhall',
                    coords = current.coords.xyz,
                    size = vec3(2, 2, 3),
                    rotation = current.coords.w,
                    debug = false,
                    onEnter = function()
                        inRangeCityhall = true
                        lib.showTextUI(locale('info.open_cityhall'))
                    end,
                    onExit = function()
                        lib.hideTextUI()
                        inRangeCityhall = false
                    end,
                    inside = function()
                        if IsControlJustPressed(0, 38) then
                            openCityhallMenu()
                            lib.hideTextUI()
                        end
                    end,
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

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    initBlips()
    spawnPeds()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end
    initBlips()
    spawnPeds()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    deleteBlips()
    deletePeds()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    deleteBlips()
    deletePeds()
end)