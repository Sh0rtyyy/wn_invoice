local PlayerData = {}
local PlayerJob = nil
local CurrentShopBlips = {}
lib.locale()

if Config.Framework == "ESX" then
    ESX = exports["es_extended"]:getSharedObject()

    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(xPlayer)
        PlayerData = xPlayer
        PlayerJob = PlayerData.job
        Wait(2000)
    end)

    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(job)
        PlayerData.job = job
        PlayerJob = job
        Wait(500)
    end)

elseif Config.Framework == "qbcore" then
    QBCore = exports['qb-core']:GetCoreObject()

    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        PlayerData = QBCore.Functions.GetPlayerData()
    end)

    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
        PlayerData.job = JobInfo
    end)

    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
        PlayerData = {}
    end)

elseif Config.Framework == "qbox" then
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        PlayerData = QBCore.Functions.GetPlayerData()
    end)

    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
        PlayerData.job = JobInfo
    end)

end

function Notify(type, title, text, icon, time)
    if Config.Notify == "ESX" then
        ESX.ShowNotification(text)
    elseif Config.Notify == "ox_lib" then
        if type == "success" then
            lib.notify({
                title = title,
                duration = time,
                description = text,
                type = "success"
            })
        elseif type == "inform" then
            lib.notify({
                title = title,
                duration = time,
                description = text,
                type = "inform"
            })
        elseif type == "error" then
            lib.notify({
                title = title,
                duration = time,
                description = text,
                type = "error"
            })
        end
    elseif Config.Notify == "qbcore" then
        if type == "success" then
            QBCore.Functions.Notify(text, "success")
        elseif type == "info" then
            QBCore.Functions.Notify(text, "primary")
        elseif type == "error" then
            QBCore.Functions.Notify(text, "error")
        end
    end
end

function GetJob()
    if Config.Framework == "ESX" then
        if ESX.GetPlayerData().job then
            return ESX.GetPlayerData().job.name
        else
            return false
        end
    elseif Config.Framework == "qbcore" then
        if QBCore.Functions.GetPlayerData().job then
            return QBCore.Functions.GetPlayerData().job.name
        else
            return false
        end
    elseif Config.Framework == "qbox" then
        if QBX.PlayerData.job then
            return QBX.PlayerData.job.name
        else
            return false
        end
    end
end

function GetJobGrade()
    if Config.Framework == "ESX" then
        if ESX.GetPlayerData().job then
            return ESX.GetPlayerData().job.grade
        else
            return false
        end
    elseif Config.Framework == "qbcore" then
        if QBCore.Functions.GetPlayerData().job then
            return QBCore.Functions.GetPlayerData().job.grade
        else
            return false
        end
    elseif Config.Framework == "qbox" then
        if QBX.PlayerData.job then
            return QBX.PlayerData.job.grade
        else
            return false
        end
    end
end

function Dispatch(coords)
    if Config.Dispatch == "cd_dispatch" then
        local data = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = Config.PoliceJobs,
            coords = coords,
            title = "10-90 - ATM Robbery",
            message = "Somebody here is hacking an ATM !",
            flash = 0,
            unique_id = tostring(math.random(0000000, 9999999)),
            blip = {
                sprite = 40,
                scale = 1.2,
                colour = 1,
                flashes = false,
                text = text,
                time = (5 * 60 * 1000),
                sound = 1,
            }
        })
    elseif Config.Dispatch == "linden_outlawalert" then
        local data = { displayCode = "10-90", description = "House Robbery", isImportant = 1, recipientList = Config.PoliceJobs, length = '10000', infoM = 'fa-info-circle', info = "Alarm has turned on at the residence" }
        local dispatchData = { dispatchData = data, caller = 'alarm', coords = coords }
        TriggerServerEvent('wf-alerts:svNotify', dispatchData)
    elseif Config.Dispatch == "ps-disptach" then
        exports["ps-dispatch"]:CustomAlert({
            coords = coords,
            message = "House Robbery",
            dispatchCode = "10-90",
            description = "Alarm has turned on at the residence",
            radius = 0,
            sprite = 40,
            color = 1,
            scale = 1.2,
            length = 3,
        })
    elseif Config.Dispatch == "core-dispatch" then
        for k, v in pairs(Config.PoliceJobs) do
            exports['core_dispatch']:addCall("10-90", "Alarm has turned on at the residence", {
                }, {coords.xyz}, v, 10000, 11, 5 
            )
        end
    elseif Config.Dispatch == "qs-dispatch" then
        TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
            job = Config.PoliceJobs,
            callLocation = coords,
            callCode = { code = '<CALL CODE>', snippet = '<CALL SNIPPED: 10-90>' },
            message = "10-90 - House Robbery",
            flashes = false, -- you can set to true if you need call flashing sirens...
            image = "URL", -- Url for image to attach to the call
            --you can use the getSSURL export to get this url
            blip = {
                sprite = 40,
                scale = 1.2,
                colour = 1,
                flashes = false, -- blip flashes
                text = '10-90 - House Robbery', -- blip text
                time = (1 * 60000), --blip fadeout time (1 * 60000) = 1 minute
            },
            otherData = {
               {
                   text = 'Alarm has turned on at the residence', -- text of the other data item (can add more than one)
                   icon = 'fas fa-user-secret', -- icon font awesome https://fontawesome.com/icons/
               }
             }
        })
    end
end

function SelectPlayer(returnmenu)
    local choosenPlayer = nil
    local players = GetActivePlayers()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local closePlayers = {}
    local title = "Vyber hráče"
    if newTitle then
        title = newTitle
    end
    for k, v in pairs(players) do
        if v ~= PlayerId() then -- Check if v is not the same as the local player's ID
            local dist = #(GetEntityCoords(GetPlayerPed(v)) - pedCoords)
            if dist < 4 and dist > -1 then
                table.insert(closePlayers, {label = 'Hráč č. '..k, args = {id = v}})
            end
        end
    end
	if not closePlayers[1] then 
        lib.notify({
            title = 'Inventář',
            description = 'Nikdo není poblíž',
            icon = 'fa-solid fa-hand-holding-hand',
            duration = 5000,
            type = 'error'
        })
    return nil end

    local currentlyHoveredPlayer = closePlayers[1].args.id


    local id = math.random(1, 99999)
    lib.registerMenu({
        id = 'chose_player'..id,
        title = title,
        position = 'top-right',
        onSideScroll = function(selected, scrollIndex, args)
            currentlyHoveredPlayer = args.id
        end,
        onSelected = function(selected, scrollIndex, args)
            currentlyHoveredPlayer = args.id
        end,
        onClose = function()
            choosenPlayer = false
        end,
        options = closePlayers
    }, function(selected, scrollIndex, args)
        choosenPlayer = args.id
    end)

    lib.showMenu('chose_player'..id)
    Citizen.CreateThread(function()
        while true do
            Wait(0)
            DrawMarker(21, GetEntityCoords(GetPlayerPed(currentlyHoveredPlayer)) + vector3(0.0, 0.0, 1.0), 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255,255,255, 100, false, false, 2, true, false, false, false)
            if choosenPlayer ~= nil then return end
        end
    end)
    while choosenPlayer == nil do
        Wait(500)
    end
    if returnmenu ~= nil then
        lib.showContext(returnmenu)
    end
    return choosenPlayer
end

function giveInput(dialog_name, title, rownames, default, type, returnmenu)
    local input = lib.inputDialog(dialog_name, {
        {type = type, label = title, description = rownames, default = default, format = "DD/MM/YYYY"},
    })
 
    if not input then return end
    print(json.encode(input[1]))
    if returnmenu ~= nil then
        lib.showContext(returnmenu)
    end
    return input[1]
end

function table.contains(table, value)
    for _, v in ipairs(table) do
        print("v", v)
        print("value", value)
        if v == value then
            return true
        end
    end
    return false
end