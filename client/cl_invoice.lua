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
        print(jobName)
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

    lib.registerContext({
        id = 'preinvoicemenu',
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
                    OpenInvoiceMenu(invoices, "payed")
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

    lib.showContext('preinvoicemenu')
end

function OpenInvoiceMenu(data, invoice_status)
    local invoices = data
    local invoice_status = invoice_status
    local status = "green"
    local context_title = "Paid Invoices"
    local options = {}

    for _, data in ipairs(invoices) do
        print("invoice_status", invoice_status)
        print("data.status", data.status)
        if invoice_status ~= data.status then print("Not right status") return end
        if data.status == "unpaid" then
            status = "red"
            context_title = "Unpaid Invoices"
        end
        table.insert(options, {
            title = "Invoice #" .. data.id .. " - " .. data.amount .. "$ | Due by " .. data.date_to_pay,
            description = string.upper(data.status),
            icon = 'file-invoice',
            colorScheme = status,
            progress = 100,
            onSelect = function()
                -- Optional: Handle selection, like showing full details or pay option
                print("Selected invoice ID: " .. data.id)
                local payed = OpenInvoice(data, data.status)
                if payed == nil then OpenPreInvoiceMenu() end
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
        title = context_title,
        canClose = true,
        menu = 'preinvoicemenu',
        onBack = function()
            print('Went back!')
        end,
        options = options
    })

    lib.showContext('invoices_menu')
end

function OpenInvoice(data, status)
    local payed = false
    local desc = "Invoice desc:  \n  " .. data.reason .. "  \n  " .. "  \n  Issued by: " .. data.source_name
    if data.job ~= nil then
        desc = "Invoice desc:  \n  " .. data.reason .. "  \n  " .. "  \n  Issued by: " .. data.job .. "  \n  " .. data.source_name
    end

    if status == "payed" then
        lib.alertDialog({
            header = "Invoice #" .. data.id .. " - $" .. data.amount,
            content = desc,
            centered = true,
            cancel = false
        })
    else
        payed = lib.alertDialog({
            header = "Invoice #" .. data.id .. " - $" .. data.amount,
            content = desc,
            centered = true,
            labels = {
                confirm = "Pay"
            },
            cancel = true
        })
        print("payed", payed)
    end

    print("payed 2", payed)
    return payed
end