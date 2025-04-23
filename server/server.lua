lib.callback.register('wn_invoice:requestInvoices', function(request_src)
    if request_src ~= nil then
        local src = request_src
    else
        local src = source
    end
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
    local timestamp = math.floor(invoice_data.date_to_pay / 1000)
    local date_to_pay = os.date(Config.DateFormat, timestamp)
    print("Timestamp (in seconds):", timestamp)
    print("Converted date_to_pay:", date_to_pay)

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

    local date = date_to_pay -- Use the formatted date for the invoice creation date
    print("Date (date_to_pay):", date)

    local paid_date = invoice_data.paid_date or ''
    print("Payed Date:", paid_date)

    local status = invoice_data.status or 'unpaid'
    print("Status:", status)

    -- MySQL query to insert the invoice into the database
    local query = string.format([[ 
        INSERT INTO `wn_invoice` (`identifier`, `source_identifier`, `name`, `source_name`, `reason`, `amount`, `job`, `date`, `date_to_pay`, `paid_date`, `status`)
        VALUES ('%s', '%s', '%s', '%s', '%s', %d, '%s', '%s', '%s', '%s', '%s')
    ]], 
    identifier, source_identifier, name, source_name, reason, amount, job, date, date_to_pay, paid_date, status)

    -- Log the generated query to see what is being executed
    print("Generated SQL query: ", query)

    -- Execute the query using your preferred database connection method
    -- Example for using MySQL (adjust based on your framework and DB connection)
    MySQL.Async.execute(query, {}, function(rowsChanged)
        print("Invoice created successfully, rows affected: ", rowsChanged)
        DiscordLog(webhook, "Invoice Created", 'Invoice with ID ' .. invoice_id .. ' was created for player ' .. playerIdentifier .. ' by ' .. source_identifier .. ' with amount to pay ' .. amount .. ' with reason ' .. reason)
    end)
end)

exports('createInvoice', function(src)
    local src = source
    local invoice_data = data
    print("Creating invoice from source ", src)

    -- Printing the incoming data
    print("data", invoice_data)
    print("data2", json.encode(invoice_data))

    -- Convert timestamp to formatted date
    local timestamp = math.floor(invoice_data.date_to_pay / 1000)
    local date_to_pay = os.date('%Y-%m-%d', timestamp)
    print("Timestamp (in seconds):", timestamp)
    print("Converted date_to_pay:", date_to_pay)

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

    local job = invoice_data.job or ''
    print("Job:", job)

    local date = date_to_pay -- Use the formatted date for the invoice creation date
    print("Date (date_to_pay):", date)

    local paid_date = invoice_data.paid_date or ''
    print("Payed Date:", paid_date)

    local status = invoice_data.status or 'unpaid'
    print("Status:", status)

    -- MySQL query to insert the invoice into the database
    local query = string.format([[ 
        INSERT INTO `wn_invoice` (`identifier`, `source_identifier`, `name`, `source_name`, `reason`, `amount`, `job`, `date`, `date_to_pay`, `paid_date`, `status`)
        VALUES ('%s', '%s', '%s', '%s', '%s', %d, '%s', '%s', '%s', '%s', '%s')
    ]], 
    identifier, source_identifier, name, source_name, reason, amount, job, date, date_to_pay, paid_date, status)

    -- Log the generated query to see what is being executed
    print("Generated SQL query: ", query)

    -- Execute the query using your preferred database connection method
    -- Example for using MySQL (adjust based on your framework and DB connection)
    MySQL.Async.execute(query, {}, function(rowsChanged)
        print("Invoice created successfully, rows affected: ", rowsChanged)
        DiscordLog(webhook, "Invoice Created", 'Invoice with ID ' .. invoice_id .. ' was created for player ' .. playerIdentifier .. ' by ' .. source_identifier .. ' with amount to pay ' .. amount .. ' with reason ' .. reason)
    end)
end)