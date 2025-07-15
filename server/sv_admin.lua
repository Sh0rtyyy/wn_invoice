RegisterCommand(Config.AdminCommand, function(source, args, rawCommand)
    local src = source
    local argumnt = args[1]
    local invoice = GetInvoiceAdmin(argumnt)
    local group = GetPlayerGroup(src)

    print(group)
    print(json.encode(invoice))
    for i, v in ipairs(Config.AdminCommandAccess) do
        if group ~= v then return end
        print(group)
        TriggerClientEvent('wn_invoice:showPlayersInvoices', src, invoice, args[1])
    end
end)

RegisterNetEvent('wn_invoice:adminAction', function(action, data)
    local src = source
    local group = GetPlayerGroup(src)

    for i, v in ipairs(Config.AdminCommandAccess) do
        if group ~= v then
            KickCheater(src, "Tried to exploit admin action")
            DiscordLog(webhook, "Invoice Exploit", GetPlayerName(src) .. " tried to use admin action without an admin perms")
            return
        end
    end

    local invoice_id = data.id -- Make sure the client sends invoice ID in `data`

    if action == "delete" then
        -- Delete invoice from DB
        MySQL.Async.execute("DELETE FROM `wn_invoice` WHERE `id` = @id", {
            ['@id'] = invoice_id
        }, function(affectedRows)
            print("Invoice deleted, rows affected: ", affectedRows)
        end)

        DiscordLog(webhook, "Invoice Deleted", 'Invoice ' .. invoice_id .. ' was deleted by admin ' .. GetPlayerName(src))
    elseif action == "paid" then
        -- Update invoice to mark as paid
        local currentDate = os.date(Config.DateFormat)
        MySQL.Async.execute([[
            UPDATE `wn_invoice`
            SET `status` = 'paid', `paid_date` = @paid_date
            WHERE `id` = @id
        ]], {
            ['@id'] = invoice_id,
            ['@paid_date'] = currentDate
        }, function(affectedRows)
            print("Invoice marked as paid, rows affected: ", affectedRows)
            DiscordLog(webhook, "Invoice Paid", 'Invoice ' .. invoice_id .. ' was marked as paid by admin ' .. GetPlayerName(src))
        end)

    else
        print("Unknown action: ", action)
    end
end)

function GetInvoiceAdmin(source)
    local src = source
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
end