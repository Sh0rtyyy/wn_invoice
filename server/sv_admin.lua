RegisterCommand(Config.AdminCommand, function()
    local src = souce
    print(args[1])
    print(args[2])
    local invoice = lib.callback.await('wn_invoice:requestInvoices', false, args[1])
    local group = GetPlayerGroup(src)

    if not group == Config.AdminCommandAccess then print('No perms') return end
    TriggerClientEvent('wn_invoice:showPlayersInvoices', src, invoice)
end)