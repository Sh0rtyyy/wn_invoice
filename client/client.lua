RegisterCommand(Config.InvoiceCommand, function()
    OpenInvoiceMenu()
end)

-- DB TABLUKA STRUCTURE
-- id = referencial ID of invoice, for command deletation
-- identifier = user that needs to pay identifier
-- source_identifier = user that gave invoice
-- reason = why to pay
-- amount = amount to pay
-- job = Job that gave the invoice
-- date = when was the invoice created
-- date_to_pay = when needs to be the invoice payed
-- payed_date = when was bill payed
-- status = payed or notpayed

local function OpenInvoiceMenu() 
    local invoices = lib.callback.await('wn_invoice:requestInvoices', false)
    local options = {}

    for _, data in ipairs(invoices) do
        table.insert(options, {
            title = "Invoice #" .. data.id .. " - $" .. data.amount,
            description = data.status,
            icon = 'file-invoice',
            iconColor = 'orange',
            colorScheme = 'yellow',
            onSelect = function()
                -- Optional: Handle selection, like showing full details or pay option
                OpenInvoice(data)
                print("Selected invoice ID: " .. data.id)
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

    lib.alertDialog({
        header = "Invoice #" .. data.id .. " - $" .. data.amount,,
        content = data.reason,
        centered = true,
        labels = {
            confirm = "Pay"
        }
        cancel = false
    })
end