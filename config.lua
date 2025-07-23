Config = {}

Config.Locale = 'en'
Config.Framework = "ESX" -- ESX or qbcore
Config.EnableDebug = true -- Enable/Disable prints and showing box of ox_target
Config.Notify = "ox_lib" -- ox_lib, qbcore or ESX

Config.billingCommand = "billing"
Config.CreatebillingCommand = "createbilling"
Config.Unemployedbillings = true

Config.AdminCommand = "billingadmin"
Config.AdminCommandAccess = {"admin"}

Config.DateFormat = '%Y-%m-%d'

Config.Jobbillings = {
    police = {
        data = {
            job = "police",
            viewAccess = {"boss", "underboss"},
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
            viewAccess = {"all"},
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
            viewAccess = false,
            commission = 0,
        },
        billings = false
    },
}