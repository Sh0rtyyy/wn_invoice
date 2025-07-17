Config = {}

Config.Locale = 'en'
Config.Framework = "ESX" -- ESX or qbcore
Config.EnableDebug = true -- Enable/Disable prints and showing box of ox_target
Config.PoliceJobs =  {"police", "sheriff"} -- Name of the job for script
Config.Notify = "ox_lib" -- ox_lib, qbcore or ESX
Config.SearchDuration = 6000 -- How long will the player search the pleace.

Config.billingCommand = "billing"
Config.billingKeyBind = "F5" -- or false3
Config.CreatebillingCommand = "createbilling"
Config.Unemployedbillings = false

Config.AdminCommand = "billingadmin"
Config.AdminCommandAccess = {"admin"}

Config.DateFormat = '%Y-%m-%d'

Config.Jobbillings = {
    police = {
        data = {
            job = "police",
            commission = 10
        },
        billings = {
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
        billings = {
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
        billings = false
    },
}