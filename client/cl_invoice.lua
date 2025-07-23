lib.locale()

RegisterCommand(Config.billingCommand, function()
    local job = GetJob()
    local grade = GetJobGrade()

    local option = {
        {
            title = locale("view_your_billings_title"),
            description = locale("view_your_billings_desc"),
            onSelect = function()
                OpenPrebillingMenu()
            end
        },
        {
            title = locale("view_created_title"),
            description = locale("view_created_desc"),
            onSelect = function()
                OpenCreateedbillingMenu()
            end
        },
    }

    if Config.Unemployedbillings or (Config.Jobbillings[job] and Config.Jobbillings[job].data.job == job) then

        option = {
            {
                title = locale("view_your_billings_title"),
                description = locale("view_your_billings_desc"),
                onSelect = function()
                    OpenPrebillingMenu()
                end
            },
            {
                title = locale("create_billing_title"),
                description = locale("create_billing_desc"),
                onSelect = function()
                    OpenCreatebillingMenu()
                end
            },
            {
                title = locale("view_created_title"),
                description = locale("view_created_desc"),
                onSelect = function()
                    OpenCreateedbillingMenu()
                end
            },
            {
                title = locale("view_company_title"),
                description = locale("view_company_desc"),
                onSelect = function()
                    OpenCompanybillingMenu()
                end
            },
        }
    end

    -- Registering the billing menu context
    lib.registerContext({
        id = 'billingmenu',
        title = locale("billing_menu_title"),
        canClose = true,
        options = option
    })

    lib.showContext('billingmenu')
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

function OpenPrebillingMenu()
    --print("Opening Pre billing Menu")
    local billings = lib.callback.await('wn_billing:requestbillings', false)
    --print(json.encode(billings))

    lib.registerContext({
        id = 'prebillingmenu',
        title = locale("my_billings_title"),
        menu = 'billingmenu',
        canClose = true,
        options = {
            {
                title = locale("view_paid_title"),
                description = locale("view_paid_desc"),
                progress = 100,
                colorScheme = "green",
                onSelect = function()
                    OpenbillingMenu(billings, "paid")
                end
            },
            {
                title = locale("view_unpaid_title"),
                description = locale("view_unpaid_desc"),
                progress = 100,
                colorScheme = "red",
                onSelect = function()
                    OpenbillingMenu(billings, "unpaid")
                end
            }
        }
    })

    lib.showContext('prebillingmenu')
end

function OpenbillingMenu(data, billing_status)
    local billings = data
    local statusColor = billing_status == "paid" and "green" or "red"
    local context_title = billing_status == "paid" and locale("paid_title") or locale("unpaid_title")
    local options = {}

    for _, data in ipairs(billings) do
        if billing_status == data.status then
            --print("Shown billing ", billing_status, data.status)

            local billing_title
            if data.status == "unpaid" then
                billing_title = locale("billing_unpaid_title", data.id, data.amount, data.date_to_pay)
            else
                billing_title = locale("billing_paid_title", data.id, data.amount, data.paid_date)
            end

            table.insert(options, {
                title = billing_title,
                description = locale("billing_details_desc"),
                colorScheme = statusColor,
                progress = 100,
                onSelect = function()
                    SeeDetails(data, 'billings_menu')
                end
            })
        end
    end

    -- Register and show the context menu
    lib.registerContext({
        id = 'billings_menu',
        title = context_title,
        canClose = true,
        menu = 'prebillingmenu',
        options = options
    })

    lib.showContext('billings_menu')
end

function SeeDetails(data, returnmenu)
    local return_menu = returnmenu
    local options = {
        { title = locale("billed_player", data.name) },
        { title = locale("issued_by", data.source_name) },
        { title = locale("billing_reason", data.reason) },
        { title = locale("billing_amount", data.amount) },
        { title = locale("billing_job", data.job_label) },
        { title = locale("billing_created", data.date) },
        { title = locale("billing_due", data.date_to_pay) },
        { title = locale("billing_status", string.upper(data.status)) }
    }

    -- Add "Pay billing" option only if status is NOT "paid"
    if string.lower(data.status) ~= "paid" then
        table.insert(options, {
            title = locale("pay_now"),
            onSelect = function()
                local payed = Openbilling(data, data.status)
                if payed == nil then OpenPrebillingMenu() end
                --print("payed", payed)
                if payed == "confirm" then
                    --print("billing payed", data.id)
                    TriggerServerEvent('wn_billing:billingPayed', data.id)
                end
            end
        })
    end

    lib.registerContext({
        id = 'SeeDetails',
        title = locale("billing_details_title", data.id),
        menu = return_menu,
        canClose = true,
        options = options
    })

    lib.showContext('SeeDetails')
end

function Openbilling(data, status)
    local paid = false
    local desc = locale("billing_dialog_desc",
        data.reason,
        (data.job ~= nil and (data.job_label .. " - ") or "") .. data.source_name
    )

    if status == "paid" then
        lib.alertDialog({
            header = locale("billing_dialog_title", data.id, data.amount),
            content = desc,
            centered = true,
            cancel = false
        })
    else
        paid = lib.alertDialog({
             header = locale("billing_dialog_title", data.id, data.amount),
            content = desc,
            centered = true,
            labels = {
                confirm = locale("billing_dialog_pay")
            },
            cancel = true
        })
    end

    return paid
end

-------------- CREATED BILINGS --------------

function OpenCreateedbillingMenu()
    local billings = lib.callback.await('wn_billing:requestbillings', false, nil, "created")
    local statusColor = billing_status == "paid" and "green" or "red"
    local context_title = billing_status == "paid" and locale("paid_title") or locale("unpaid_title")
    local options = {}

    --print(json.encode(billings))

    for _, data in ipairs(billings) do
        local billing_title
        local statusColor = data.status == "paid" and "green" or "red"

        if data.status == "unpaid" then
            billing_title = locale("billing_unpaid_title", data.id, data.amount, data.date_to_pay)
        else
            billing_title = locale("billing_paid_title", data.id, data.amount, data.paid_date)
        end

        table.insert(options, {
            title = billing_title,
            description = locale("billing_details_desc"),
            colorScheme = statusColor,
            progress = 100,
            onSelect = function()
                SeeDetails(data, "created_billings_menu")
            end
        })
    end

    -- Register and show the context menu
    lib.registerContext({
        id = 'created_billings_menu',
        title = locale("created_title"),
        canClose = true,
        menu = 'billingmenu',
        options = options
    })

    lib.showContext('created_billings_menu')
end

-------------- COMPANY BILINGS --------------

function OpenCompanybillingMenu()
    local billings = lib.callback.await('wn_billing:requestbillings', false, nil, "company")
    local statusColor = billing_status == "paid" and "green" or "red"
    local context_title = billing_status == "paid" and locale("paid_title") or locale("unpaid_title")
    local options = {}

    --print(json.encode(billings))

    for _, data in ipairs(billings) do
        local billing_title
        local statusColor = data.status == "paid" and "green" or "red"

        if data.status == "unpaid" then
            billing_title = locale("billing_unpaid_title", data.id, data.amount, data.date_to_pay)
        else
            billing_title = locale("billing_paid_title", data.id, data.amount, data.paid_date)
        end

        table.insert(options, {
            title = billing_title,
            description = locale("billing_details_desc"),
            colorScheme = statusColor,
            progress = 100,
            onSelect = function()
                SeeDetails(data, "created_billings_menu")
            end
        })
    end

    -- Register and show the context menu
    lib.registerContext({
        id = 'created_billings_menu',
        title = locale("company_title"),
        canClose = true,
        menu = 'billingmenu',
        options = options
    })

    lib.showContext('created_billings_menu')
end