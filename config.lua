Config = {}

Config.Locale = 'en'
Config.Framework = "ESX" -- ESX or qbcore
Config.EnableDebug = true -- Enable/Disable prints and showing box of ox_target
Config.PoliceJobs =  {"police", "sheriff"} -- Name of the job for script
Config.Notify = "ox_lib" -- ox_lib, qbcore or ESX
Config.SearchDuration = 6000 -- How long will the player search the pleace.

Config.InvoiceCommand = "invoice"
Config.InvoiceKeyBind = "F5" -- or false3
Config.CreateInvoiceCommand = "createinvoice"
Config.UnemployedInvoices = false

Config.AdminCommand = "invoiceadmin"
Config.AdminCommandAccess = {"admin"}

Config.DateFormat = '%Y-%m-%d'

Config.JobInvoices = {
    police = {
        data = {
            job = "police",
            commission = 10
        },
        invoices = {
            {"Big speed", 500},
            {"Theft", 500},
            {"Red Light", 500}
        },
    },
    sheriff = {
        data = {
            job = "sheriff",
            commission = 20
        },
        invoices = {
            {"Big speed", 500},
            {"Theft", 500},
            {"Red Light", 500}
        },
    },
    mechanic = {
        data = {
            job = "mechanic",
            commission = 0,
        },
        invoices = false
    },
}