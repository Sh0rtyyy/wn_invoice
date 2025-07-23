lib.locale()

RegisterNetEvent('wn_billing:showPlayersbillings')
AddEventHandler('wn_billing:showPlayersbillings', function(data, player)
    OpenPrebillingMenuAdmin(data, player)
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
-- job_aname = Job label
-- date = when was the billing created
-- date_to_pay = when needs to be the billing payed
-- paid_date = when was bill payed
-- status = payed or notpayed

function OpenPrebillingMenuAdmin(data, player)
    local billings = data
    local id = player
    --print("Opening Pre billing Menu Admin for player " .. id)
    --print(json.encode(billings))

    lib.registerContext({
        id = 'prebillingmenuadmin',
        title = locale("billing_options_title", id),
        canClose = true,
        options = {
           {
                title = locale("view_paid_title"),
                description = locale("view_paid_desc"),
                progress = 100,
                colorScheme = "green",
                onSelect = function()
                    OpenbillingMenuAdmin(billings, "paid")
                end
            },
            {
                title = locale("view_unpaid_title"),
                description = locale("view_unpaid_desc"),
                progress = 100,
                colorScheme = "red",
                onSelect = function()
                    OpenbillingMenuAdmin(billings, "unpaid")
                end
            }
        }
    })

    lib.showContext('prebillingmenuadmin')
end

function OpenbillingMenuAdmin(data, billing_status)
    local billings = data
    local statusColor = billing_status == "paid" and "green" or "red"
    local context_title = billing_status == "paid" and locale("paid_title") or locale("unpaid_title")
    local options = {}

    for _, entry in ipairs(billings) do
        if billing_status == entry.status then
            table.insert(options, {
                title = locale("billing_entry_title", entry.id, entry.amount, entry.date_to_pay),
                description = locale("billing_entry_desc"),
                colorScheme = statusColor,
                progress = 100,
                onSelect = function()
                    SeeDetailsAdmin(entry)
                end
            })
        end
    end

    lib.registerContext({
        id = 'billings_menu_admin',
        title = context_title,
        canClose = true,
        menu = 'prebillingmenuadmin',
        onBack = function()
            --print('Went back!')
        end,
        options = options
    })

    lib.showContext('billings_menu_admin')
end

-- DB TABLUKA STRUCTURE
-- id = referencial ID of billing, for command deletation
-- identifier = user that needs to pay identifier
-- source_identifier = user that gave billing
-- name = user name that needs to pay identifier
-- source_name = user name that gave billing
-- reason = why to pay
-- amount = amount to pay
-- job = Job that gave the billing
-- job_aname = Job label
-- date = when was the billing created
-- date_to_pay = when needs to be the billing payed
-- paid_date = when was bill payed
-- status = payed or notpayed

function SeeDetailsAdmin(data)
    lib.registerContext({
        id = 'SeeDetailsAdmin',
        title = "📄 Billing Details - #" .. data.id,
        menu = 'prebillingmenuadmin',
        canClose = true,
        options = {
            {
                title = "🛠️ Admin Actions",
                onSelect = function()
                    WhatToDo(data)
                end
            },
            { title = "🧾 User Identifier: " .. data.identifier },
            { title = "📤 Sender Identifier: " .. data.source_identifier },
            { title = "👤 User Name: " .. data.name },
            { title = "👮 Sender Name: " .. data.source_name },
            { title = "📝 Reason: " .. data.reason },
            { title = "💰 Amount: $" .. data.amount },
            { title = "🏢 Job: " .. data.job_label },
            { title = "📅 Created On: " .. data.date },
            { title = "⏰ Due Date: " .. data.date_to_pay },
            { title = "📌 Status: " .. string.upper(data.status) }
        }
    })

    lib.showContext('SeeDetailsAdmin')
end

function WhatToDo(data)
    lib.registerContext({
        id = 'WhatToDo',
        title = "🛠️ Admin Billing Actions",
        canClose = true,
        options = {
            {
                title = "🗑️ Delete Billing",
                description = "Remove this billing record ❗",
                progress = 100,
                colorScheme = "red",
                onSelect = function()
                    TriggerServerEvent('wn_billing:adminAction', data, "delete")
                end
            },
            {
                title = "✅ Mark as Paid",
                description = "Set billing status to PAID ✅",
                progress = 100,
                colorScheme = "green",
                onSelect = function()
                    TriggerServerEvent('wn_billing:adminAction', data, "paid")
                end
            }
        }
    })

    lib.showContext('WhatToDo')
end