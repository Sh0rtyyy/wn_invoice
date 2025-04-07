RegisterCommand(Config.InvoiceCommand, function()
    local job = GetJob()
    local grade = GetJobGrade()
    print(job .. " " .. grade)
    
    local option = {
        {
            title = "Open your invoices",
            description = "View and issue available invoices",
            icon = 'star',
            onSelect = function()
                OpenPreInvoiceMenu()
            end
        },
    }

    if Config.UnemployedInvoices or (Config.JobInvoices[job] and Config.JobInvoices[job].data.job == job) then
        local jobName = Config.JobInvoices[job].data.job
        print(jobName)  -- This will print the job associated with that entry
        option = {
            {
                title = "Open your invoices",
                description = "View and issue available invoices",
                icon = 'star',
                onSelect = function()
                    OpenPreInvoiceMenu()
                end
            },
            {
                title = "Create invoice",
                description = "Create invoice",
                icon = 'star',
                onSelect = function()
                    OpenCreateInvoiceMenu()
                end
            },
        }
    end

    -- Registering the invoice menu context
    lib.registerContext({
        id = 'invoicemenu',
        title = "Invoice Menu",
        canClose = true,
        options = option
    })

    lib.showContext('invoicemenu')
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

function OpenPreInvoiceMenu()
    print("Opening Pre Invoice Menu")
    local invoices = lib.callback.await('wn_invoice:requestInvoices', false)
    print(json.encode(invoices))

    -- Correctly defining the options for the Pre Invoice Menu
    lib.registerContext({
        id = 'zdar',
        title = "Invoice Menu",
        canClose = true,
        options = {
            {
                title = "Open paid invoices",
                description = "Open paid invoices",
                progress = 100,
                colorScheme = "green",
                icon = 'star',
                onSelect = function()
                    OpenInvoiceMenu(invoices, "paid")
                end
            },
            {
                title = "Open unpaid invoices",
                description =  "Open unpaid invoices",
                progress = 100,
                colorScheme = "red",
                icon = 'star',
                onSelect = function()
                    OpenInvoiceMenu(invoices, "unpaid")
                end
            }
        }
    })
    
    -- Show the context menu for Pre Invoice Menu
    lib.showContext('zdar')
end

function OpenInvoiceMenu(data, invoice_status)
    local invoices = data
    local invoice_status = invoice_status
    local status = "green"
    local options = {}

    for _, data in ipairs(invoices) do
        if not data.status == invoice_status then return end
        if data.status == "unpaid" then
            status = "red"
        end
        table.insert(options, {
            title = "Invoice #" .. data.id .. " - " .. data.amount .. "$",
            description = string.upper(data.status),
            icon = 'file-invoice',
            colorScheme = status,
            progress = 100,
            onSelect = function()
                -- Optional: Handle selection, like showing full details or pay option
                print("Selected invoice ID: " .. data.id)
                local payed = OpenInvoice(data)
                print("payed", payed)
                if payed == "confirm" then
                    print("Invoice payed", data.id)
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

function OpenInvoice(data)
    local desc = "Invoice desc:  \n  " .. data.reason .. "  \n  " .. "  \n  Issued by: " .. data.source_name
    if data.job ~= nil then
        desc = "Invoice desc:  \n  " .. data.reason .. "  \n  " .. "  \n  Issued by: " .. data.job .. "  \n  " .. data.source_name
    end

    local payed = lib.alertDialog({
        header = "Invoice #" .. data.id .. " - $" .. data.amount,
        content = desc,
        centered = true,
        labels = {
            confirm = "Pay"
        },
        cancel = true
    })

    return payed
end