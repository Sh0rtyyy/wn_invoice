RegisterCommand(Config.InvoiceCommand, function()
    OpenInvoiceMenu()
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
-- payed_date = when was bill payed
-- status = payed or notpayed

local function OpenInvoiceMenu()
    local invoices = lib.callback.await('wn_invoice:requestInvoices', false)
    local status = "green"
    local options = {}

    for _, data in ipairs(invoices) do
        if data.status == "unpaid" then
            status = "red"
        end
        table.insert(options, {
            title = "Invoice #" .. data.id .. " - $" .. data.amount,
            description = data.status,
            icon = 'file-invoice',
            colorScheme = status,
            progress = 100,
            onSelect = function()
                -- Optional: Handle selection, like showing full details or pay option
                print("Selected invoice ID: " .. data.id)
                local payed = OpenInvoice(data)
                if payed then
                    lib.callback.await('wn_invoice:invoicePayed', false, data.id)
                end
            end
        })
    end

    -- Register and show the context menu
    lib.registerContext({
        id = 'invoices_menu',
        title = "Your Invoices",
        canClose = true,
        options = options
    })

    lib.showContext('invoices_menu')
end

local function OpenInvoice(data)
    local desc = data.reson .. "  \n  " .. data.source_name
    if data.job ~= nil then
        desc = data.reson .. "  \n  " .. data.job .. "  \n  " .. data.source_name
    end

    local payed = lib.alertDialog({
        header = "Invoice #" .. data.id .. " - $" .. data.amount,,
        content = desc,
        centered = true,
        labels = {
            confirm = "Pay"
        }
        cancel = true
    })

    return payed
end