lib.locale()

lib.callback.register('wn_billing:requestbillings', function(source, request_src)
    print("requestbillings")
    print("request_src", request_src)
    local src = source
    if request_src ~= nil then
        src = request_src
    end
    print("src", src)
    local playerIdentifier = GetIdentifier(src)
    local billingData = {}
    local isFetched = false

    MySQL.Async.fetchAll('SELECT * FROM wn_billing WHERE identifier = @identifier', {
        ['@identifier'] = playerIdentifier
    }, function(result)
        if result then
            billingData = result
        end
        isFetched = true
    end)

    while not isFetched do
        Wait(10)
    end

    return billingData
end)

exports('requestbillings', function(src)
    local request_source = src
    local playerIdentifier = GetIdentifier(request_source)
    local billingData = {}
    local isFetched = false

    MySQL.Async.fetchAll('SELECT * FROM wn_billing WHERE identifier = @identifier', {
        ['@identifier'] = playerIdentifier
    }, function(result)
        if result then
            billingData = result
        end
        isFetched = true
    end)

    while not isFetched do
        Wait(10)
    end

    return billingData
end)

-- DB TABLUKA STRUCTURE
-- id = referencial ID of billing, for command deletation
-- identifier = user that needs to pay identifier
-- source_identifier = user that gave billing
-- name = user name that needs to pay identifier
-- source_name = user name that gave billing
-- reason = why to pay
-- amount = amount to pay
-- job = Job that gave the billing
-- date = when was the billing created
-- date_to_pay = when needs to be the billing payed
-- paid_date = when was bill payed
-- status = payed or notpayed

RegisterNetEvent('wn_billing:billingPayed', function(id)
    local src = source
    local playerIdentifier = GetIdentifier(src)
    local billing_id = id

    print("id", id)
    print("playerIdentifier", playerIdentifier)
    print("billing_id", billing_id)

    local billingData = nil
    local isFetched = false

    MySQL.Async.fetchAll('SELECT * FROM wn_billing WHERE identifier = @identifier AND id = @billing_id', {
        ['@identifier'] = playerIdentifier,
        ['@billing_id'] = billing_id
    }, function(result)
        if result and #result > 0 then
            billingData = result[1]
        end
        isFetched = true
    end)

    while not isFetched do
        Wait(10)
    end

    print(billingData)
    local user_money = GetMoney("bank", billingData.amount, src)
    print("user_money", user_money)
    print("billingData.amount", billingData.amount)
    if not user_money then
            TriggerClientEvent("wn_billing:sendNotify", src, "error", locale("billing"), locale("not_enough_money"))
        return
    end

    if billingData and user_money then
        local paidDate = os.date("%d/%m/%Y")

        MySQL.Async.execute('UPDATE wn_billing SET status = @status, paid_date = @paid_date WHERE identifier = @identifier AND id = @billing_id', {
            ['@status'] = 'paid',
            ['@paid_date'] = paidDate,
            ['@identifier'] = playerIdentifier,
            ['@billing_id'] = billing_id
        }, function(affectedRows)
            if affectedRows > 0 then
                TriggerClientEvent("wn_billing:sendNotify", src, "success", locale("billing"), locale("billing_paid_success", billing_id))
                RemoveMoney("bank", billingData.amount, src)
                if billingData.job == "Personal" then
                    local identifier = billingData.source_identifier
                    local sender_source = GetPlayerFromIdentifier(identifier)
                    print("sender_source", sender_source)
                    AddMoneyIdentifier("bank", billingData.amount, sender_source)
                else
                    local commission = Config.Jobbillings[billingData.job].data.commission
                    if commission == false then return end
                    local receive = tonumber(billingData.amount)
                    local identifier = billingData.source_identifier
                    local sender_source = GetPlayerFromIdentifier(identifier)
                    authorReceive = receive * (commission / 100)
                    receive = authorReceive
                    print("receive", receive)
                    print("sender_source", sender_source)
                    AddMoneyIdentifier("bank", receive, sender_source)
                    AddSocietyMoney(billingData.job, billingData.amount)
                end
                print('billing ' .. billing_id .. ' for player ' .. playerIdentifier .. ' marked as paid.')
                DiscordLog("🧾 Billing Paid", (
                    "📌 Billing ID: **%s**\n" ..
                    "👤 Sender Identifier: **%s**\n" ..
                    "📛 Sender Name: **%s**\n" ..
                    "👤 Receiving Identifier: **%s**\n" ..
                    "📛 Receiving Name: **%s**\n" ..
                    "💰 Amount: **$%s**\n" ..
                    "📝 Reason: **%s**\n" ..
                    "🧑‍💼 Job: **%s (%s)**\n" ..
                    "📅 Date Issued: **%s**\n" ..
                    "📅 Due Date: **%s\n**" ..
                    "📅 Paid Date: **%s\n**" ..
                    "📌 Status: **PAID**"
                ):format(
                    billing_id,
                    billingData.source_identifier,
                    billingData.source_name,
                    playerIdentifier,
                    billingData.name,
                    billingData.amount,
                    billingData.reason,
                    billingData.job_label,
                    billingData.job,
                    billingData.date,
                    billingData.date_to_pay,
                    paidDate
                ))
            else
                print('Failed to update the billing status.')
            end
        end)
    else
        print('billing not found for player ' .. playerIdentifier .. ' with ID ' .. billing_id)
    end
end)

--[[lib.callback.register('wn_billing:billingPayed', function(id)
    local src = source
    local playerIdentifier = GetIdentifier(src)
    local billing_id = id

    print("id", id)
    print("playerIdentifier", playerIdentifier)
    print("billing_id", billing_id)

    local billingData = nil
    local isFetched = false

    MySQL.Async.fetchAll('SELECT * FROM wn_billing WHERE identifier = @identifier AND id = @billing_id', {
        ['@identifier'] = playerIdentifier,
        ['@billing_id'] = billing_id
    }, function(result)
        if result and #result > 0 then
            billingData = result[1]
        end
        isFetched = true
    end)

    while not isFetched do
        Wait(10)
    end

    print(billingData)
    local user_money = GetMoney("bank", billingData.amount, src)
    print("user_money", user_money)
    print("billingData.amount", billingData.amount)
    if not user_money then print("Not enough money") return end

    if billingData then
        MySQL.Async.execute('UPDATE wn_billing SET status = @status WHERE identifier = @identifier AND id = @billing_id', {
            ['@status'] = 'paid',
            ['@identifier'] = playerIdentifier,
            ['@billing_id'] = billing_id
        }, function(affectedRows)
            if affectedRows > 0 then
                RemoveMoney("bank", billingData.amount, src)
                print('billing ' .. billing_id .. ' for player ' .. playerIdentifier .. ' marked as paid.')
                DiscordLog(webhook, "billing Paid", 'billing ' .. billing_id .. ' for player ' .. playerIdentifier .. ' was paid.')

            else
                print('Failed to update the billing status.')
            end
        end)
    else
        print('billing not found for player ' .. playerIdentifier .. ' with ID ' .. billing_id)
    end
end)]]

RegisterNetEvent('wn_billing:createbilling', function(data)
    local src = source
    local billing_data = data
    print("Creating billing from source ", src)

    -- Printing the incoming data
    print("data", billing_data)
    print("data2", json.encode(billing_data))

    -- Convert timestamp to formatted date
    local date_to_pay = billing_data.date_to_pay
    print("date_to_pay:", date_to_pay)

    -- Prepare the data to be inserted into the database
    local identifier = GetIdentifier(data.player)
    print("Player Identifier:", identifier)
    
    local source_identifier = GetIdentifier(src)
    print("Source Identifier:", source_identifier)
    
    local name = GetName(data.player)
    print("Player Name:", name)
    
    local source_name = GetName(src)
    print("Source Name:", source_name)

    local reason = billing_data.reason or 'No reason provided'
    print("Reason:", reason)

    local amount = billing_data.amount or 0
    print("Amount:", amount)

    local job = billing_data.job or 'Personal'
    print("Job:", job)

    local jobLabel = billing_data.job_label or 'Personal'
    print("jobLabel:", jobLabel)

    local date = date_to_pay -- Use the formatted date for the billing creation date
    print("Date (date_to_pay):", date)

    local paid_date = billing_data.paid_date or ''
    print("Payed Date:", paid_date)

    local status = billing_data.status or 'unpaid'
    print("Status:", status)

    -- MySQL query to insert the billing into the database
    local query = [[ 
        INSERT INTO `wn_billing` 
        (`identifier`, `source_identifier`, `name`, `source_name`, `reason`, `amount`, `job`, `job_label`, `date`, `date_to_pay`, `paid_date`, `status`)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]]

    local values = {
        identifier,
        source_identifier,
        name,
        source_name,
        reason,
        amount,
        job,
        jobLabel,
        date,
        date_to_pay,
        paid_date,
        status
    }

    MySQL.insert(query, values, function(insertId)
        if insertId and insertId > 0 then
            print("billing created with ID:", insertId)

            TriggerClientEvent("wn_billing:sendNotify", src, "success", locale("Billing"), locale("billing_created_success_sender", insertId))
            TriggerClientEvent("wn_billing:sendNotify", data.player, "info", locale("Billing"), locale("billing_created_success_receiver"))

            DiscordLog("🧾 Billing Created", (
                "📌 Billing ID: **%s**\n" ..
                "👤 Sender Identifier: **%s**\n" ..
                "📛 Sender Name: **%s**\n" ..
                "👤 Receiving Identifier: **%s**\n" ..
                "📛 Receiving Name: **%s**\n" ..
                "💰 Amount: **$%s**\n" ..
                "📝 Reason: **%s**\n" ..
                "🧑‍💼 Job: **%s (%s)**\n" ..
                "📅 Date Issued: **%s**\n" ..
                "📅 Due Date: **%s**"
            ):format(
                insertId,
                source_identifier,
                source_name,
                identifier,
                name,
                amount,
                reason,
                jobLabel,
                job,
                date,
                date_to_pay
            ))
        else
            print("❌ Failed to insert billing or retrieve ID.")
        end
    end)
end)

exports('createbilling', function(src, data)
    local src = source
    local billing_data = data
    print("Creating billing from source ", src)

    -- Printing the incoming data
    print("data", billing_data)
    print("data2", json.encode(billing_data))

    -- Convert timestamp to formatted date
    local date_to_pay = billing_data.date_to_pay
    print("date_to_pay:", date_to_pay)

    -- Prepare the data to be inserted into the database
    local identifier = GetIdentifier(data.player)
    print("Player Identifier:", identifier)
    
    local source_identifier = GetIdentifier(src)
    print("Source Identifier:", source_identifier)
    
    local name = GetName(data.player)
    print("Player Name:", name)
    
    local source_name = GetName(src)
    print("Source Name:", source_name)

    local reason = billing_data.reason or 'No reason provided'
    print("Reason:", reason)

    local amount = billing_data.amount or 0
    print("Amount:", amount)

    local job = billing_data.job or 'Personal'
    print("Job:", job)

    local jobLabel = billing_data.job_label or 'Personal'
    print("jobLabel:", jobLabel)

    local date = date_to_pay -- Use the formatted date for the billing creation date
    print("Date (date_to_pay):", date)

    local paid_date = billing_data.paid_date or ''
    print("Payed Date:", paid_date)

    local status = billing_data.status or 'unpaid'
    print("Status:", status)

    -- MySQL query to insert the billing into the database
    local query = [[ 
        INSERT INTO `wn_billing` 
        (`identifier`, `source_identifier`, `name`, `source_name`, `reason`, `amount`, `job`, `job_label`, `date`, `date_to_pay`, `paid_date`, `status`)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]]

    local values = {
        identifier,
        source_identifier,
        name,
        source_name,
        reason,
        amount,
        job,
        jobLabel,
        date,
        date_to_pay,
        paid_date,
        status
    }

    MySQL.insert(query, values, function(insertId)
        if insertId and insertId > 0 then
            print("billing created with ID:", insertId)

            TriggerClientEvent("success", src, "Billing", "You successfully created billing #" .. insertId)
            TriggerClientEvent("success", data.player, "Billing", "You've received an billing")

            DiscordLog(webhook, "billing Created", ('billing with ID %s was created for player %s by %s with amount $%s for reason: %s'):format(
                insertId, identifier, source_identifier, amount, reason
            ))
        else
            print("❌ Failed to insert billing or retrieve ID.")
        end
    end)
end)