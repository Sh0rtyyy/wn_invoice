RegisterNetEvent('wn_invoice:showPlayersInvoices')
AddEventHandler('wn_invoice:showPlayersInvoices', function(data, player)
    OpenPreInvoiceMenuAdmin(data, player)
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

function OpenPreInvoiceMenuAdmin(data, player)
    local invoices = data
    local id = player
    print("Opening Pre Invoice Menu Admin for player " .. id)
    print(json.encode(invoices))

    lib.registerContext({
        id = 'preinvoicemenuadmin',
        title = "Invoice Menu for player " .. id,
        canClose = true,
        options = {
            {
                title = "Open paid invoices",
                description = "Open paid invoices",
                progress = 100,
                colorScheme = "green",
                icon = 'star',
                onSelect = function()
                    OpenInvoiceMenuAdmin(invoices, "payed")
                end
            },
            {
                title = "Open unpaid invoices",
                description =  "Open unpaid invoices",
                progress = 100,
                colorScheme = "red",
                icon = 'star',
                onSelect = function()
                    OpenInvoiceMenuAdmin(invoices, "unpaid")
                end
            }
        }
    })

    lib.showContext('preinvoicemenuadmin')
end

function OpenInvoiceMenuAdmin(data, invoice_status)
    local invoices = data
    local invoice_status = invoice_status
    local status = "green"
    local context_title = "Paid Invoices"
    local options = {}

    for _, data in ipairs(invoices) do
        print("invoice_status", invoice_status)
        print("data.status", data.status)
        if invoice_status == data.status then
            print("Shown invoice ", invoice_status, data.status)
            if data.status == "unpaid" then
                status = "red"
                context_title = "Unpaid Invoices"
            end
            table.insert(options, {
                title = "Invoice #" .. data.id .. " - " .. data.amount .. "$ | Due by " .. data.date_to_pay,
                description = "See details",
                icon = 'file-invoice',
                colorScheme = status,
                progress = 100,
                onSelect = function()
                    SeeDetails(data)
                end
            })
        end
    end

    -- Register and show the context menu
    lib.registerContext({
        id = 'invoices_menu_admin',
        title = context_title,
        canClose = true,
        menu = 'preinvoicemenuadmin',
        onBack = function()
            print('Went back!')
        end,
        options = options
    })

    lib.showContext('invoices_menu_admin')
end

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

local function SeeDetailsAdmin(data)
    lib.registerContext({
        id = 'SeeDetailsAdmin',
        title = "Details for invoice " .. data.id,
        menu = 'preinvoicemenuadmin',
        canClose = true,
        options = {
            {
                title = "Admin Actions",
                onSelect = function()
                    WhatToDo(data)
                end
            },
            {
                title = "User Identifier: " .. data.identifier
            },
            {
                title = "Sender Identifier: " .. data.source_identifier
            },
            {
                title = "User Name: " .. data.name
            },
            {
                title = "Sender Name: " .. data.source_name
            },
            {
                title = "Reason: " .. data.reason
            },
            {
                title = "Amount: " .. data.amount
            },
            {
                title = "Job: " .. data.job
            },
            {
                title = "Creation Date: " .. data.date
            },
            {
                title = "Due Day: " .. data.date_to_pay
            },
            {
                title = "Status: " .. data.status
            },
        }
    })

    lib.showContext('SeeDetailsAdmin')
end

function WhatToDo(data)
    lib.registerContext({
        id = 'WhatToDo',
        title = "What to do with invoice",
        canClose = true,
        options = {
            {
                title = "Delete Invoice",
                description = "Open paid invoices",
                progress = 100,
                colorScheme = "green",
                icon = 'star',
                onSelect = function()
                    TriggerServerEvent('wn_invoice:adminAction', data, "delete")
                    wtd = "delete"
                end
            },
            {
                title = "Mark as paid",
                description =  "Open unpaid invoices",
                progress = 100,
                colorScheme = "red",
                icon = 'star',
                onSelect = function()
                    TriggerServerEvent('wn_invoice:adminAction', data, "paid")
                end
            }
        }
    })

    lib.showContext('WhatToDo')
end