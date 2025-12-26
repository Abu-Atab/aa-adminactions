Settings = {
    Locale = 'en', -- 'en' or 'ar'

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
        Webhook = "https://discord.com/api/webhooks/1448630313319399496/5bLW4CEu_8PpK1tu9ZQ3q1QRiT_HdD772v3WnywYY1oHCewstYKFWgyZNHu9x6DGJVGl"
    }
}
