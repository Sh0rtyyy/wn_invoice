lib.locale()

RegisterCommand(Config.CreatebillingCommand, function()
    OpenCreatebillingMenu()
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

function OpenCreatebillingMenu()
    local data = {}
    local job = GetJob()
    local jobLabel = GetJobLabel()

    function RefreshbillingMenu()
        local options = {}

        -- Predefined billing option (if any)
        if Config.Jobbillings and Config.Jobbillings[job] and Config.Jobbillings[job].billings ~= false then
            table.insert(options, {
                title = locale("predefined_billing_title"),
                description = locale("predefined_billing_desc"),
                onSelect = function()
                    local items = {}
                    for _, billing in ipairs(Config.Jobbillings[job].billings) do
                        local reason, amount = billing[1], billing[2]
                        table.insert(items, {
                            title = reason,
                            description = amount and ("💰 $" .. amount) or "✏️ Custom amount",
                            onSelect = function()
                                data.reason = reason
                                data.amount = amount or 0
                                data.job = job
                                data.job_label = jobLabel
                                RefreshbillingMenu()
                                lib.showContext("createbilling")
                            end
                        })
                    end

                    lib.registerContext({
                        id = 'select_predefined_billing',
                        title = locale("predefined_billing_header", job),
                        canClose = true,
                        menu = 'createbilling',
                        options = items
                    })

                    lib.showContext('select_predefined_billing')
                end
            })
        end

        table.insert(options, {
            title = locale("select_player_title", data.player and (" ✅ [" .. data.player .. "]") or ""),
            description = locale("select_player_desc"),
            onSelect = function()
                data.player = "1" -- Replace with actual player selector
                RefreshbillingMenu()
                lib.showContext('createbilling')
            end
        })

        table.insert(options, {
            title = locale("reason_title", data.reason and (" ✅ [" .. data.reason .. "]") or ""),
            description = locale("reason_desc"),
            onSelect = function()
                local reason = giveInput(locale("input_reason_header"), locale("input_reason_label"), locale("input_reason_set"), nil, 'input', 'createbilling')
                if reason then data.reason = reason end
                RefreshbillingMenu()
                lib.showContext('createbilling')
            end
        })

        table.insert(options, {
            title = "💲 Amount" .. (data.amount and (" ✅ [$" .. data.amount .. "]") or ""),
            description = "Specify the amount to be paid",
            onSelect = function()
                local amount = giveInput(locale("input_reason_header"), locale("input_amount_label"), locale("input_amount_set"), 0, 'number', 'createbilling')
                if amount then data.amount = amount end
                RefreshbillingMenu()
                lib.showContext('createbilling')
            end
        })

        table.insert(options, {
            title = "💼 As Job" .. (data.job and (" ✅ [" .. data.job_label .. "]") or ""),
            description = locale("job_desc"),
            onSelect = function()
                local asJob = giveInput(locale("input_reason_header"), locale("input_job_label"), {locale("input_job_checkbox", job)}, nil, 'checkbox', 'createbilling')
                data.job = asJob and job or "Personal"
                data.job_label = asJob and jobLabel or "Personal"
                RefreshbillingMenu()
                lib.showContext('createbilling')
            end
        })

        table.insert(options, {
            title = locale("due_date_title", data.date_to_pay and (" ✅ [" .. data.date_to_pay .. "]") or ""),
            description = locale("due_date_desc"),
            onSelect = function()
                local date = giveInput('Create billing', 'Set Date Of billing', {'Set Date'}, true, 'date', 'createbilling')
                if date then data.date_to_pay = date end
                RefreshbillingMenu()
                lib.showContext('createbilling')
            end
        })

        table.insert(options, {
            title = locale("send_billing_title"),
            description = locale("send_billing_desc"),
            onSelect = function()
                if not data.player or not data.reason or not data.amount or not data.job or not data.date_to_pay then
                    print("Please fill all fields before sending the billing.")
                else
                    print("Sending billing:", json.encode(data))
                    TriggerServerEvent('wn_billing:createbilling', data)
                end
            end
        })

        lib.registerContext({
            id = 'createbilling',
            title = locale("create_billing_title"),
            canClose = true,
            menu = 'billingmenu',
            options = options
        })
    end

    RefreshbillingMenu()
    lib.showContext('createbilling')
end