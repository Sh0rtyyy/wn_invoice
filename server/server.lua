lib.callback.register('wn_invoice:requestInvoices', function(source, request_src)
    print("requestInvoices")
    print("request_src", request_src)
    local src = source
    if request_src ~= nil then
        src = request_src
    end
    print("src", src)
    local playerIdentifier = GetIdentifier(src)
    local invoiceData = {}
    local isFetched = false

    MySQL.Async.fetchAll('SELECT * FROM wn_invoice WHERE identifier = @identifier', {
        ['@identifier'] = playerIdentifier
    }, function(result)
        if result then
            invoiceData = result
        end
        isFetched = true
    end)

    while not isFetched do
        Wait(10)
    end

    return invoiceData
end)

exports('requestInvoices', function(src)
    local request_source = src
    local playerIdentifier = GetIdentifier(request_source)
    local invoiceData = {}
    local isFetched = false

    MySQL.Async.fetchAll('SELECT * FROM wn_invoice WHERE identifier = @identifier', {
        ['@identifier'] = playerIdentifier
    }, function(result)
        if result then
            invoiceData = result
        end
        isFetched = true
    end)

    while not isFetched do
        Wait(10)
    end

    return invoiceData
end)

-- DB TABLUKA STRUCTURE
-- id = referencial ID of invoice, for command deletation
-- identifier = user that needs to pay identifier
-- source_identifier = user that gave invoice
-- name = user name that needs to pay identifier
-- source_name = user name that gave invoice
-- reason = why to pay
-- amount = amount to pay
-- job = Job that gave the invoice
-- date = when was the invoice created
-- date_to_pay = when needs to be the invoice payed
-- paid_date = when was bill payed
-- status = payed or notpayed

RegisterNetEvent('wn_invoice:invoicePayed', function(id)
    local src = source
    local playerIdentifier = GetIdentifier(src)
    local invoice_id = id

    print("id", id)
    print("playerIdentifier", playerIdentifier)
    print("invoice_id", invoice_id)

    local invoiceData = nil
    local isFetched = false

    MySQL.Async.fetchAll('SELECT * FROM wn_invoice WHERE identifier = @identifier AND id = @invoice_id', {
        ['@identifier'] = playerIdentifier,
        ['@invoice_id'] = invoice_id
    }, function(result)
        if result and #result > 0 then
            invoiceData = result[1]
        end
        isFetched = true
    end)

    while not isFetched do
        Wait(10)
    end

    print(invoiceData)
    local user_money = GetMoney("bank", invoiceData.amount, src)
    print("user_money", user_money)
    print("invoiceData.amount", invoiceData.amount)
    if not user_money then
        TriggerClientEvent("wn_invoice:sendNotify", src, "error", "Billing", "You dont have enought money")
        return
    end

    if invoiceData and user_money then
        MySQL.Async.execute('UPDATE wn_invoice SET status = @status WHERE identifier = @identifier AND id = @invoice_id', {
            ['@status'] = 'paid',
            ['@identifier'] = playerIdentifier,
            ['@invoice_id'] = invoice_id
        }, function(affectedRows)
            if affectedRows > 0 then
                TriggerClientEvent(src, "success", "Billing", "You successfuly paid invoice #" .. invoice_id)
                RemoveMoney("bank", invoiceData.amount, src)
                if invoiceData.job == "Personal" then
                    local identifier = invoiceData.source_identifier
                    local sender_source = GetPlayerFromIdentifier(identifier)
                    AddMoney("bank", invoiceData.amount, sender_source)
                else
                    local commission = Config.JobInvoices[invoiceData.job].data.commission
                    if commission == false then return end
                    local receive = tonumber(invoiceData.amount)
                    local identifier = invoiceData.source_identifier
                    local sender_source = GetPlayerFromIdentifier(identifier)
                    authorReceive = receive * (commission / 100)
                    receive = receive - authorReceive
                    AddMoney("bank", receive, sender_source)
                    AddSocietyMoney(invoiceData.job, invoiceData.amount)
                end
                print('Invoice ' .. invoice_id .. ' for player ' .. playerIdentifier .. ' marked as paid.')
                DiscordLog(webhook, "Invoice Paid", 'Invoice ' .. invoice_id .. ' for player ' .. playerIdentifier .. ' was paid.')
            else
                print('Failed to update the invoice status.')
            end
        end)
    else
        print('Invoice not found for player ' .. playerIdentifier .. ' with ID ' .. invoice_id)
    end
end)

--[[lib.callback.register('wn_invoice:invoicePayed', function(id)
    local src = source
    local playerIdentifier = GetIdentifier(src)
    local invoice_id = id

    print("id", id)
    print("playerIdentifier", playerIdentifier)
    print("invoice_id", invoice_id)

    local invoiceData = nil
    local isFetched = false

    MySQL.Async.fetchAll('SELECT * FROM wn_invoice WHERE identifier = @identifier AND id = @invoice_id', {
        ['@identifier'] = playerIdentifier,
        ['@invoice_id'] = invoice_id
    }, function(result)
        if result and #result > 0 then
            invoiceData = result[1]
        end
        isFetched = true
    end)

    while not isFetched do
        Wait(10)
    end

    print(invoiceData)
    local user_money = GetMoney("bank", invoiceData.amount, src)
    print("user_money", user_money)
    print("invoiceData.amount", invoiceData.amount)
    if not user_money then print("Not enough money") return end

    if invoiceData then
        MySQL.Async.execute('UPDATE wn_invoice SET status = @status WHERE identifier = @identifier AND id = @invoice_id', {
            ['@status'] = 'paid',
            ['@identifier'] = playerIdentifier,
            ['@invoice_id'] = invoice_id
        }, function(affectedRows)
            if affectedRows > 0 then
                RemoveMoney("bank", invoiceData.amount, src)
                print('Invoice ' .. invoice_id .. ' for player ' .. playerIdentifier .. ' marked as paid.')
                DiscordLog(webhook, "INvoice Paid", 'Invoice ' .. invoice_id .. ' for player ' .. playerIdentifier .. ' was paid.')

            else
                print('Failed to update the invoice status.')
            end
        end)
    else
        print('Invoice not found for player ' .. playerIdentifier .. ' with ID ' .. invoice_id)
    end
end)]]

RegisterNetEvent('wn_invoice:createInvoice', function(data)
    local src = source
    local invoice_data = data
    print("Creating invoice from source ", src)

    -- Printing the incoming data
    print("data", invoice_data)
    print("data2", json.encode(invoice_data))

    -- Convert timestamp to formatted date
    local date_to_pay = invoice_data.date_to_pay
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

    local reason = invoice_data.reason or 'No reason provided'
    print("Reason:", reason)

    local amount = invoice_data.amount or 0
    print("Amount:", amount)

    local job = invoice_data.job or 'Personal'
    print("Job:", job)

    local jobLabel = invoice_data.job_label or 'Personal'
    print("jobLabel:", jobLabel)

    local date = date_to_pay -- Use the formatted date for the invoice creation date
    print("Date (date_to_pay):", date)

    local paid_date = invoice_data.paid_date or ''
    print("Payed Date:", paid_date)

    local status = invoice_data.status or 'unpaid'
    print("Status:", status)

    -- MySQL query to insert the invoice into the database
    local query = [[ 
        INSERT INTO `wn_invoice` 
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
            print("Invoice created with ID:", insertId)

            TriggerClientEvent("success", src, "Billing", "You successfully created invoice #" .. insertId)
            TriggerClientEvent("success", data.player, "Billing", "You've received an invoice")

            DiscordLog(webhook, "Invoice Created", ('Invoice with ID %s was created for player %s by %s with amount $%s for reason: %s'):format(
                insertId, identifier, source_identifier, amount, reason
            ))
        else
            print("❌ Failed to insert invoice or retrieve ID.")
        end
    end)
end)

exports('createInvoice', function(src, data)
    local src = source
    local invoice_data = data
    print("Creating invoice from source ", src)

    -- Printing the incoming data
    print("data", invoice_data)
    print("data2", json.encode(invoice_data))

    -- Convert timestamp to formatted date
    local date_to_pay = invoice_data.date_to_pay
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

    local reason = invoice_data.reason or 'No reason provided'
    print("Reason:", reason)

    local amount = invoice_data.amount or 0
    print("Amount:", amount)

    local job = invoice_data.job or 'Personal'
    print("Job:", job)

    local jobLabel = invoice_data.job_label or 'Personal'
    print("jobLabel:", jobLabel)

    local date = date_to_pay -- Use the formatted date for the invoice creation date
    print("Date (date_to_pay):", date)

    local paid_date = invoice_data.paid_date or ''
    print("Payed Date:", paid_date)

    local status = invoice_data.status or 'unpaid'
    print("Status:", status)

    -- MySQL query to insert the invoice into the database
    local query = [[ 
        INSERT INTO `wn_invoice` 
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
            print("Invoice created with ID:", insertId)

            TriggerClientEvent("success", src, "Billing", "You successfully created invoice #" .. insertId)
            TriggerClientEvent("success", data.player, "Billing", "You've received an invoice")

            DiscordLog(webhook, "Invoice Created", ('Invoice with ID %s was created for player %s by %s with amount $%s for reason: %s'):format(
                insertId, identifier, source_identifier, amount, reason
            ))
        else
            print("❌ Failed to insert invoice or retrieve ID.")
        end
    end)
end)