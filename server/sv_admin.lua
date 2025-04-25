RegisterCommand(Config.AdminCommand, function()
    local src = souce
    print(args[1])
    print(args[2])
    local invoice = lib.callback.await('wn_invoice:requestInvoices', false, args[1])
    local group = GetPlayerGroup(src)

    if group ~= Config.AdminCommandAccess then return end
    TriggerClientEvent('wn_invoice:showPlayersInvoices', src, invoice, args[1])
end)

RegisterNetEvent('wn_invoice:adminAction', function(action, data)
    local src = source
    local group = GetPlayerGroup(src)

    if group ~= Config.AdminCommandAccess then
        KickCheater(src, "Tried to exploit admin action")
        DiscordLog(webhook, "Invoice Exploit", GetPlayerName(src) .. " tried to use admin action without an admin perms")
        return
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