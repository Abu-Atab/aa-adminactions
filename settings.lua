Settings = {
    Locale = 'en', -- 'en' or 'ar'

    CheckForUpdates = true,

    Command = 'actionsmenu',

    Target = {
        Enabled = true,
        Distance = 3.0
    },

    Security = {
        MaxDistance = 5.0,
        CooldownSeconds = 2,
        CarRequestTimeoutSeconds = 20
    },

    Money = {
        AllowCash = true,
        AllowBank = true,
        AllowBlack = true,
        BlackItemName = 'markedbills'
    },

    Limits = {
        MaxMoneyAmount = 10000000,
        MaxItemAmount  = 100000
    },

    Permission = {
        Mode = 'qbadmin', -- 'all' | 'jobs' | 'qbadmin' | 'citizenids'

        Jobs = { 'police', 'ambulance' },
        QBAdminPerms = { 'god', 'admin' },
        CitizenIds = { 'ABC12345' }
    },

    Vehicle = {
        Enabled = true,
        
        Plate = {
            MinLen = 4,
            MaxLen = 8
        },

        Spawn = {
            Enabled = true,
            SpawnDistance = 4.0
        }
    },

    Logging = {
        Enabled = true,
        Webhook = "YOUR_WEBHOOK_HERE"
    }
}
