local webhook = "https://discord.com/api/webhooks/1250184705182007419/aoG7RN98Z52JYIVZ5jI2DyQO_2Upv1GqisucTEC2v52A-1Gp-8zlWzUJiXqRuXTag1T7"

if Config.Framework == "ESX" then
    ESX = exports["es_extended"]:getSharedObject()
    RegisterUsable = ESX.RegisterUsableItem
elseif Config.Framework == "qbcore" then
    QBCore = nil
    QBCore = exports['qb-core']:GetCoreObject()
    RegisterUsable = QBCore.Functions.CreateUseableItem
end

function CheckJob(source, job)
    local src = source
    local jobToCheck = job

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer.job.name == jobToCheck then
            return true
        else
            return false
        end
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayerData()
        if xPlayer.job.name == jobToCheck then
            return true
        else
            return false
        end
    elseif Config.Framework == "qbox" then
        local xPlayer = exports.qbx_core:GetPlayer(source)
        if xPlayer.PlayerData.job.name == jobToCheck then
            return true
        else
            return false
        end
    end
end

function GetIdentifier(source)
    local src = source

    -- TODO: Zkontrolovať
    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer.getIdentifier(src)
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetIdentifier(src)
        return xPlayer.PlayerData.citizenid
    elseif Config.Framework == "qbox" then
        local xPlayer = exports.qbx_core:GetPlayer(src)
        return xPlayer.PlayerData.citizenid
    end
end

function GetName(source)
    local src = source

    -- TODO: Zkontrolovať
    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer.getName()
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetIdentifier(src)
        return xPlayer.PlayerData.firstname .. " " .. xPlayer.PlayerData.lastname
    elseif Config.Framework == "qbox" then
        local xPlayer = exports.qbx_core:GetPlayer(src)
        return xPlayer.PlayerData.firstname .. " " .. xPlayer.PlayerData.lastname
    end
end

function GetPlayerFromIdentifier(identifier)
    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
        return xPlayer
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayerFromIdentifier(identifier)
        return xPlayer
    elseif Config.Framework == "qbox" then
        local xPlayer = exports.qbx_core:GetPlayerFromIdentifier(identifier)
        return xPlayer
    end
end

function AddSocietyMoney(job, amount)
    if Config.Framework == "ESX" then
        TriggerEvent('esx_society:getSociety', job, function(society)
            TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function(account)
                if account then
                    AddLog("function", {
                        name = "AddJobMoney",
                        data = {job = job, amount = amount},
                        status = "ok"
                    })

                    account.addMoney(amount)
                else
                    AddLog("function", {
                        name = "AddJobMoney",
                        data = {job = job, amount = amount},
                        status = "error",
                        error = "account is nil"
                    })
                end
            end)
        end)
    elseif Config.Framework == "qbcore" then
        

    elseif Config.Framework == "qbox" then
        
        
    end
end

function GetCops()
    local cops = 0

    if Config.Framework == "ESX" then
        for _, src in pairs(ESX.GetPlayers()) do
            local xPlayer = ESX.GetPlayerFromId(src)
            for _, job in pairs(Config.PoliceJobs) do
                if xPlayer and xPlayer.getJob() and xPlayer.getJob().name == job then
                    cops = cops + 1
                end
            end
        end
        return cops
    elseif Config.Framework == "qbcore" then
        local Player = QBCore.Functions.GetPlayers()
        for i = 1, #Player do
            local Player = QBCore.Functions.GetPlayer(Player[i])
            for _, job in pairs(Config.PoliceJobs) do
                if Player.PlayerData.job.name == job then
                    cops = cops + 1
                end
            end
        end
        return cops
    end
end

function GetPlayerGroup(source)
    local src = source
    local player_group = "user"

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        player_group = xPlayer.getGroup()
    elseif Config.Framwork == "qbcore" then
        player_group = QBCore.Functions.GetPermission(src)
    elseif Config.Framework == "qbox" then
        local player_group = exports.qbx_core:GetPermission(src)
    end

    return player_group
end

function CheckDistance(source, TargetCoords)
    local src = source

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
	    local coords = xPlayer.getCoords(true)
        local distance = #(coords - TargetCoords)
        if distance < 10 then
            return true
        else
            return false
        end
    elseif Config.Framework == "qbcore" then
        local coords = GetEntityCoords(GetPlayerPed(src))
        local distance = #(coords - TargetCoords)
        if distance < 10 then
            return true
        else
            return false
        end
    end
end

function CheckDistancePlayers(source, TargetSource)
    local src = source
    local tSrc = TargetSource

    local coords = GetEntityCoords(GetPlayerPed(src))
    local tCoords = GetEntityCoords(GetPlayerPed(TargetSource))
    local distance = #(coords - tCoords)
    if distance < 10 then
        return true
    else
        return false
    end
end

function GetItem(name, count, source)
    local src = source
    local itemName = name
    local itemCount = count

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer.getInventoryItem(itemName).count >= itemCount then
            return true
        else
            return false
        end
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        if xPlayer.Functions.GetItemByName(itemName) ~= nil then
            if xPlayer.Functions.GetItemByName(itemName).amount >= itemCount then
                return true
            else
                return false
            end
        else
            return false
        end
    elseif Config.Framework == "qbox" then
        local amount = exports.ox_inventory:Search(source, 'count', itemName)
        if amount >= itemCount then
            return true
        else
            return false
        end
    end
end

function AddItem(name, count, source)
    local src = source
    local itemName = name
    local itemCount = count

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.addInventoryItem(itemName, itemCount)
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        xPlayer.Functions.AddItem(itemName, itemCount, nil, nil)
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[itemName], "add", itemCount)
    elseif Config.Framework == "qbox" then
        exports.ox_inventory:AddItem(src, itemName, itemCount)
    end
end

function RemoveItem(name, count, source)
    local src = source

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.removeInventoryItem(name, count)
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        xPlayer.Functions.RemoveItem(name, count, nil, nil)
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[name], "remove", count)
    elseif Config.Framework == "qbox" then
        exports.ox_inventory:RemoveItem(src, itemName, itemCount)
    end
end

function AddMoney(type, count, source)
    local src = source
    local moneyType = type
    local moneyAmount = count

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.addAccountMoney(moneyType, moneyAmount)
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        if moneyType == "money" then
            moneyType = "cash"
        end
        xPlayer.Functions.AddMoney(moneyType, moneyAmount)
    elseif Config.Framework == "qbox" then
        if moneyType == "money" then
            moneyType = "cash"
        end
        exports.qbx_core:AddMoney(src, moneyType, moneyAmount)
    end
end

function RemoveMoney(type, count, source)
    local src = source
    local moneyType = type
    local moneyAmount = count

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.removeAccountMoney(moneyType, moneyAmount)
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        if moneyType == "money" then
            moneyType = "cash"
        end
        xPlayer.Functions.RemoveMoney(moneyType, moneyAmount)
    elseif Config.Framework == "qbox" then
        if moneyType == "money" then
            moneyType = "cash"
        end
        exports.qbx_core:RemoveMoney(src, moneyType, moneyAmount)
    end
end

function GetMoney(type, count, source)
    local src = source
    local moneyType = type
    local moneyAmount = count

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if moneyType == "money" then
            if xPlayer.getMoney() >= moneyAmount then
                return true
            else
                return false
            end
        elseif moneyType == "bank" then
            if xPlayer.getAccount('bank').money >= moneyAmount then
                return true
            else
                return false
            end
        end
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        if moneyType == "money" then
            moneyType = "cash"
        end
        local playerMoney = xPlayer.Functions.GetMoney(moneyType)
        if playerMoney >= moneyAmount then
            return true
        else
            return false
        end
    elseif Config.Framework == "qbox" then
        local playerMoney = exports.qbx_core:GetMoney(src, moneyType)
        if playermoney >= moneyAmount then
            return true
        else
            return false
        end
    end
end

function KickCheater(src, message)
	print("Cheater ".. src .. " " .. message)
    DropPlayer(src, message)
end

function DiscordLog(name,message,color)
    local embeds = {
        {
            ["title"] = name,
            ["description"] = message,
            ["type"] = "rich",
            ["color"] = 56108,
            ["footer"] = {
                ["text"] = "wn_atmrobbery " .. os.date('%H:%M - %d. %m. %Y', os.time()),
            },
        }
    }

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({ username = name, embeds = embeds }), { ['Content-Type'] = 'application/json' })
end
