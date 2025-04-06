
RegisterCommand(Config.CreateInvoiceCommand, function()
    OpenCreateInvoiceMenu()
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

local function OpenCreateInvoiceMenu()
    lib.registerContext({
        id = 'createinvoice',
        title = "Create invoice",
        canClose = true,
        options = {
            {
                title = locale('reputation'),
                description = locale('reputation_d', xp),
                icon = 'star',
                readOnly = true,
                iconColor = 'yellow',
                colorScheme = 'lime',
                progress = xp,
            },
        }
    })
    
    lib.showContext('acceptPayment')
end