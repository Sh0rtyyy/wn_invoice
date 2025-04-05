Config = {}


Config.Locale = 'en'
Config.Framework = "ESX" -- ESX or qbcore
Config.EnableDebug = true -- Enable/Disable prints and showing box of ox_target
Config.PoliceJobs =  {"police", "sheriff"} -- Name of the job for script
Config.Notify = "ox_lib" -- ox_lib, qbcore or ESX
Config.SearchDuration = 6000 -- How long will the player search the pleace

Config.InvoiceCommand = "invoice"
Config.InvoiceKeyBind = "F5" -- or false3
Config.CreateInvoiceCommand = "createinvoice",
Config.UnemployedInvoices = false

Config.JobInvoices = {
    police = {
        data = {
            job = "police",
            grades = {0,1,2,3,4,5,6,7,8},
            comission = 10
        },
        invoices = {
            {"Big speed", 500},
            {"Theft", 500},
            {"Red Light", 500},
            {"Custom"}
        },
    },
    sheriff = {
        data = {
            job = "sheriff",
            grades = "all",
            comission = 20
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
            grades = "all",
            comission = 0,
        },
        invoices = {
            {"Custom"}
        },
    },
},