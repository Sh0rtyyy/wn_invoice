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
-- paid_date = when was bill payed
-- status = payed or notpayed

function OpenCreateInvoiceMenu()
    local data = {}
    local job = GetJob()

    lib.registerContext({
        id = 'createinvoice',
        title = "Create invoice",
        canClose = true,
        options = {
            {
                title = "Select player",
                description = "Select player which you want create bill to",
                onSelect = function()
                    local reiidkason = giveInput('Create Invoice', 'Set Reason Of Invoice', {'Set Reason'}, nil, 'input', 'createinvoice')
                    --local player = SelectPlayer('createinvoice')
                    data.player = "1"
                end
            },
            {
                title = "Reason",
                description = "Why is bill given",
                onSelect = function()
                    local reason = giveInput('Create Invoice', 'Set Reason Of Invoice', {'Set Reason'}, nil, 'input', 'createinvoice')
                    data.reason = reason
                end
            },
            {
                title = "Amount",
                description = "Amount of the bill",
                onSelect = function()
                    local amount = giveInput('Create Invoice', 'Set Price Of Invoice', {'Set Price'}, 0, 'number', 'createinvoice')
                    data.amount = amount
                end
            },
            {
                title = "As Job",
                description = "Give Invoice as job",
                onSelect = function()
                    local job = giveInput('Create Invoice', 'Set Job Of Invoice', {'Set Job for invoice as ' .. job}, nil, 'checkbox', 'createinvoice')
                    data.job = job
                end
            },
            {
                title = "Set Date",
                description = "Set Date",
                onSelect = function()
                    local date_to_pay = giveInput('Create Invoice', 'Set Date Of Invoice', {'Set Date'}, true, 'date', 'createinvoice')
                    data.date_to_pay = date_to_pay
                end
            },
            {
                title = "Send Invoice",
                description = "Send Invoice",
                onSelect = function()
                    --if not data.player or not data.reason or not data.amount or not data.job or not data.date_to_pay then
                    print("data.player", data.player)
                    print(json.encode(data))
                    if not data.reason or not data.amount or not (data.job ~= nil) or not data.date_to_pay then

                        -- Notify user that they need to fill all fields
                        print("Please fill all fields before sending the invoice.")
                    else
                        -- Proceed to send the invoice if all fields are filled
                        print(json.encode(data))
                        TriggerServerEvent('wn_invoice:createInvoice', data)
                        --lib.callback.await('wn_invoice:createInvoice', false, data)
                    end
                end
            },
        }
    })

    lib.showContext('createinvoice')
end