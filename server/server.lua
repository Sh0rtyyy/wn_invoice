lib.callback.register('wn_invoice:requestInvoices', function()
    local src = source
    local playerIdentifier = GetIdentifier(src)
    local invoiceData = {}
    local isFetched = false

    MySQL.Async.fetchAll('SELECT * FROM wn_invoice WHERE identifier = @identifier', {
        ['@identifier'] = playerIdentifier
    }, function(result)
        if result then
            invoiceData = result
        end
        isFetched = true
    end)

    while not isFetched do
        Wait(10)
    end

    return invoiceData
end)

lib.callback.register('wn_invoice:invoicePayed', function(id)
    local src = source
    local playerIdentifier = GetIdentifier(src)
    local invoice_id = id

    local invoiceData = nil
    local isFetched = false

    MySQL.Async.fetchAll('SELECT * FROM wn_invoice WHERE identifier = @identifier AND id = @invoice_id', {
        ['@identifier'] = playerIdentifier,
        ['@invoice_id'] = invoice_id
    }, function(result)
        if result and #result > 0 then
            invoiceData = result[1]
        end
        isFetched = true
    end)

    while not isFetched do
        Wait(10)
    end

    print("user_money", user_money)
    print("invoiceData.amount", invoiceData.amount)

    local user_money = GetMoney("bank", invoiceData.amount, src)
    if not user_money then print("Not enough money") return end

    if invoiceData then
        MySQL.Async.execute('UPDATE wn_invoice SET status = @status WHERE identifier = @identifier AND id = @invoice_id', {
            ['@status'] = 'payed',
            ['@identifier'] = playerIdentifier,
            ['@invoice_id'] = invoice_id
        }, function(affectedRows)
            if affectedRows > 0 then
                RemoveMoney("bank", invoiceData.amount, src)
                print('Invoice ' .. invoice_id .. ' for player ' .. playerIdentifier .. ' marked as payed.')
            else
                print('Failed to update the invoice status.')
            end
        end)
    else
        print('Invoice not found for player ' .. playerIdentifier .. ' with ID ' .. invoice_id)
    end
end)

lib.callback.register('wn_invoice:createInvoice', function(data)
    local src = source
    local playerIdentifier = GetIdentifier(src)
    local timestamp = math.floor(date.date_to_pay / 1000)
    local date_to_pay = os.date('%Y-%m-%d %H:%M:%S', timestamp)

end)