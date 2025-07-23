lib.locale()

RegisterCommand(Config.AdminCommand, function(source, args, rawCommand)
    local src = source
    local argumnt = args[1]
    local billing = GetbillingAdmin(argumnt)
    local group = GetPlayerGroup(src)

    --print(group)
    --print(json.encode(billing))
    for i, v in ipairs(Config.AdminCommandAccess) do
        if group ~= v then return end
        --print(group)
        TriggerClientEvent('wn_billing:showPlayersbillings', src, billing, args[1])
    end
end)

RegisterNetEvent('wn_billing:adminAction', function(data, action)
    local src = source
    local group = GetPlayerGroup(src)

    for i, v in ipairs(Config.AdminCommandAccess) do
        if group ~= v then
            KickCheater(src, "Tried to exploit admin action")
            DiscordLog(webhook, "Billing Exploit", GetPlayerName(src) .. " tried to use admin action without an admin perms")
            return
        end
    end

    local billing_id = data.id -- Make sure the client sends billing ID in `data`

    if action == "delete" then
        -- Delete billing from DB
        MySQL.Async.execute("DELETE FROM `wn_billing` WHERE `id` = @id", {
            ['@id'] = billing_id
        }, function(affectedRows)
            --print("billing deleted, rows affected: ", affectedRows)
        end)

        DiscordLog("🧾 Billing Deleted by Admin", (
            "📌 Billing ID: **%s**\n" ..
            "🧑‍💼 Admin: **%s**\n"
        ):format(
            billing_id,
            GetPlayerName(src)
        ))
    elseif action == "paid" then
        -- Update billing to mark as paid
        local currentDate = os.date(Config.DateFormat)
        MySQL.Async.execute([[
            UPDATE `wn_billing`
            SET `status` = 'paid', `paid_date` = @paid_date
            WHERE `id` = @id
        ]], {
            ['@id'] = billing_id,
            ['@paid_date'] = currentDate
        }, function(affectedRows)
            --print("billing marked as paid, rows affected: ", affectedRows)
            DiscordLog("🧾 Billing Paid by Admin", (
                "📌 Billing ID: **%s**\n" ..
                "🧑‍💼 Admin: **%s**\n"
            ):format(
                billing_id,
                GetPlayerName(src)
            ))
        end)

    else
        print("Unknown action: ", action)
    end
end)

function GetbillingAdmin(source)
    local src = source
    --print("src", src)
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
end