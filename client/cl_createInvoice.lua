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
-- job_aname = Job label
-- date = when was the invoice created
-- date_to_pay = when needs to be the invoice payed
-- paid_date = when was bill payed
-- status = payed or notpayed

function OpenCreateInvoiceMenu()
    local data = {}
    local job = GetJob()
    local jobLabel = GetJobLabel()

    function RefreshInvoiceMenu()
        local options = {}

        -- Predefined invoice option (if any)
        if Config.JobInvoices and Config.JobInvoices[job] and Config.JobInvoices[job].invoices ~= false then
            table.insert(options, {
                title = "📄 Select Predefined Invoice",
                description = "Choose from job-based invoice templates",
                onSelect = function()
                    local items = {}
                    for _, invoice in ipairs(Config.JobInvoices[job].invoices) do
                        local reason, amount = invoice[1], invoice[2]
                        table.insert(items, {
                            title = reason,
                            description = amount and ("$" .. amount) or "Custom amount",
                            onSelect = function()
                                data.reason = reason
                                data.amount = amount or 0
                                data.job = job
                                data.job_label = jobLabel
                                RefreshInvoiceMenu()
                                lib.showContext("createinvoice")
                            end
                        })
                    end

                    lib.registerContext({
                        id = 'select_predefined_invoice',
                        title = 'Predefined Invoices - ' .. job,
                        canClose = true,
                        menu = 'createinvoice',
                        options = items
                    })

                    lib.showContext('select_predefined_invoice')
                end
            })
        end

        table.insert(options, {
            title = "👤 Select Player" .. (data.player and (" ✅ [" .. data.player .. "]") or ""),
            description = "Select player who will receive the bill",
            onSelect = function()
                data.player = "1" -- Replace with actual player selector
                RefreshInvoiceMenu()
                lib.showContext('createinvoice')
            end
        })

        table.insert(options, {
            title = "✏️ Reason" .. (data.reason and (" ✅ [" .. data.reason .. "]") or ""),
            description = "Why is the bill given?",
            onSelect = function()
                local reason = giveInput('Create Invoice', 'Set Reason Of Invoice', {'Set Reason'}, nil, 'input', 'createinvoice')
                if reason then data.reason = reason end
                RefreshInvoiceMenu()
                lib.showContext('createinvoice')
            end
        })

        table.insert(options, {
            title = "💲 Amount" .. (data.amount and (" ✅ [$" .. data.amount .. "]") or ""),
            description = "Amount of the bill",
            onSelect = function()
                local amount = giveInput('Create Invoice', 'Set Price Of Invoice', {'Set Price'}, 0, 'number', 'createinvoice')
                if amount then data.amount = amount end
                RefreshInvoiceMenu()
                lib.showContext('createinvoice')
            end
        })

        table.insert(options, {
            title = "💼 As Job" .. (data.job_label and (" ✅ [" .. data.job_label .. "]") or ""),
            description = "Issue this invoice on behalf of your job",
            onSelect = function()
                local asJob = giveInput('Create Invoice', 'Set Job Of Invoice', {'Set job for invoice as ' .. job}, nil, 'checkbox', 'createinvoice')
                data.job = asJob and job or nil
                RefreshInvoiceMenu()
                lib.showContext('createinvoice')
            end
        })

        table.insert(options, {
            title = "📅 Set Due Date" .. (data.date_to_pay and (" ✅ [" .. data.date_to_pay .. "]") or ""),
            description = "Set the due date for this invoice",
            onSelect = function()
                local date = giveInput('Create Invoice', 'Set Date Of Invoice', {'Set Date'}, true, 'date', 'createinvoice')
                if date then data.date_to_pay = date end
                RefreshInvoiceMenu()
                lib.showContext('createinvoice')
            end
        })

        table.insert(options, {
            title = "✅ Send Invoice",
            description = "Send this invoice to the selected player",
            onSelect = function()
                if not data.player or not data.reason or not data.amount or not data.job or not data.date_to_pay then
                    print("Please fill all fields before sending the invoice.")
                else
                    print("Sending invoice:", json.encode(data))
                    TriggerServerEvent('wn_invoice:createInvoice', data)
                end
            end
        })

        lib.registerContext({
            id = 'createinvoice',
            title = "📋 Create Invoice",
            canClose = true,
            options = options
        })
    end

    RefreshInvoiceMenu()
    lib.showContext('createinvoice')
end