local QBCore = exports['qb-core']:GetCoreObject()

local lastUse = 0

local function notify(msgKey, nType)
    QBCore.Functions.Notify(T(msgKey), nType or 'error')
end

local function cooldownOk()
    local now = GetGameTimer()
    local cdMs = (Settings.Security.CooldownSeconds or 2) * 1000
    if (now - lastUse) < cdMs then
        notify('error.cooldown', 'error')
        return false
    end
    lastUse = now
    return true
end

local function getServerIdFromEntity(ent)
    if not ent or ent == 0 then return nil end
    if not IsEntityAPed(ent) then return nil end
    local ply = NetworkGetPlayerIndexFromPed(ent)
    if not ply or ply == -1 then return nil end
    return GetPlayerServerId(ply)
end

local function openMainMenu(prefillTargetId)
    if not cooldownOk() then return end

    local options = {
        {
            title = T('ui.give_money'),
            icon = 'hand-holding-dollar',
            onSelect = function()
                TriggerEvent('aa-adminactions:client:openMoney', prefillTargetId)
            end
        },
        {
            title = T('ui.give_items'),
            icon = 'box-open',
            onSelect = function()
                TriggerEvent('aa-adminactions:client:openItems', prefillTargetId)
            end
        },
        {
            title = T('ui.give_job'),
            icon = 'id-badge',
            onSelect = function()
                TriggerEvent('aa-adminactions:client:openJob', prefillTargetId)
            end
        }
    }

    if Settings.Vehicle and Settings.Vehicle.Enabled then
        options[#options+1] = {
            title = T('ui.give_car'),
            icon = 'car',
            onSelect = function()
                TriggerEvent('aa-adminactions:client:openCar', prefillTargetId)
            end
        }
    end

    lib.registerContext({
        id = 'aa_pay_main',
        title = T('ui.menu_title'),
        options = options
    })

    lib.showContext('aa_pay_main')
end

RegisterNetEvent('aa-adminactions:client:openMainMenu', function(prefillTargetId)
    openMainMenu(prefillTargetId)
end)

local function buildMoneyTypes()
    local opts = {}
    if Settings.Money.AllowCash then
        opts[#opts+1] = { label = T('ui.money_cash'), value = 'cash' }
    end
    if Settings.Money.AllowBank then
        opts[#opts+1] = { label = T('ui.money_bank'), value = 'bank' }
    end
    if Settings.Money.AllowBlack then
        opts[#opts+1] = { label = T('ui.money_black'), value = 'black' }
    end
    return opts
end

RegisterNetEvent('aa-adminactions:client:openMoney', function(prefillTargetId)
    local moneyTypes = buildMoneyTypes()

    local input = lib.inputDialog(T('ui.money_title'), {
        { type = 'select', label = T('ui.money_type'), options = moneyTypes, required = true },
        { type = 'number', label = T('ui.target_id'), required = true, default = prefillTargetId and tonumber(prefillTargetId) or nil, min = 1 },
        { type = 'number', label = T('ui.amount'), required = true, min = 1, max = Settings.Limits.MaxMoneyAmount or 10000000 }
    })

    if not input then return end
    TriggerServerEvent('aa-adminactions:server:giveMoney', input[1], tonumber(input[2]), tonumber(input[3]))
end)

local function getAllItemsOptions()
    local items = QBCore.Shared.Items or {}
    local options = {}

    for name, data in pairs(items) do
        local label = data.label or name
        options[#options+1] = { label = string.format('%s (%s)', label, name), value = name }
    end

    table.sort(options, function(a, b)
        return a.label:lower() < b.label:lower()
    end)

    return options
end

RegisterNetEvent('aa-adminactions:client:openItems', function(prefillTargetId)
    local options = getAllItemsOptions()

    local input = lib.inputDialog(T('ui.items_title'), {
        { type = 'select', label = T('ui.item_select'), options = options, required = true, searchable = true },
        { type = 'number', label = T('ui.quantity'), required = true, min = 1, max = Settings.Limits.MaxItemAmount or 100000 },
        { type = 'number', label = T('ui.target_id'), required = true, default = prefillTargetId and tonumber(prefillTargetId) or nil, min = 1 }
    })

    if not input then return end
    TriggerServerEvent('aa-adminactions:server:giveItem', tostring(input[1]), tonumber(input[2]), tonumber(input[3]))
end)

local function getAllJobsOptions()
    local jobs = QBCore.Shared.Jobs or {}
    local options = {}

    for name, data in pairs(jobs) do
        local label = (data and data.label) and data.label or name
        options[#options+1] = { label = string.format('%s (%s)', label, name), value = name }
    end

    table.sort(options, function(a, b)
        return a.label:lower() < b.label:lower()
    end)

    return options
end

RegisterNetEvent('aa-adminactions:client:openJob', function(prefillTargetId)
    local jobsOptions = getAllJobsOptions()

    local input = lib.inputDialog(T('ui.job_title'), {
        { type = 'select', label = T('ui.job_select'), options = jobsOptions, required = true, searchable = true },
        { type = 'number', label = T('ui.job_grade'), required = true, min = 0, max = 50 },
        { type = 'number', label = T('ui.target_id'), required = true, default = prefillTargetId and tonumber(prefillTargetId) or nil, min = 1 }
    })

    if not input then return end
    TriggerServerEvent('aa-adminactions:server:giveJob', tostring(input[1]), tonumber(input[2]), tonumber(input[3]))
end)

RegisterNetEvent('aa-adminactions:client:openCar', function(prefillTargetId)
    local input = lib.inputDialog(T('ui.car_title'), {
        { type = 'input',  label = T('ui.car_model'), required = true, min = 2, max = 30 },
        { type = 'number', label = T('ui.target_id'), required = true, default = prefillTargetId and tonumber(prefillTargetId) or nil, min = 1 },
        { type = 'input',  label = T('ui.custom_plate'), required = false,
          min = (Settings.Vehicle.Plate.MinLen or 4), max = (Settings.Vehicle.Plate.MaxLen or 8) }
    })

    if not input then return end

    local model = tostring(input[1] or ""):lower()
    local targetId = tonumber(input[2])

    local plate = tostring(input[3] or ""):upper():gsub("%s+", "")
    if plate == "" then plate = nil end

    TriggerServerEvent('aa-adminactions:server:giveCarRequest', model, targetId, plate)
end)

local function plateOk(plate)
    if not plate or plate == "" then return true end
    local minLen = (Settings.Vehicle.Plate and Settings.Vehicle.Plate.MinLen) or 4
    local maxLen = (Settings.Vehicle.Plate and Settings.Vehicle.Plate.MaxLen) or 8
    if #plate < minLen or #plate > maxLen then return false end
    return plate:match("^[A-Z0-9]+$") ~= nil
end

RegisterNetEvent('aa-adminactions:client:spawnVehicleForOwnership', function(data)
    local model = tostring(data.model or ""):lower()
    local plate = tostring(data.plate or ""):upper():gsub("%s+", "")
    local requestId = data.requestId

    local hash = joaat(model)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        TriggerServerEvent('aa-adminactions:server:giveCarResult', requestId, false, "invalid_model")
        return
    end

    if plate ~= "" and not plateOk(plate) then
        TriggerServerEvent('aa-adminactions:server:giveCarResult', requestId, false, "plate_invalid")
        return
    end

    lib.requestModel(hash, 5000)

    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local dist = (Settings.Vehicle and Settings.Vehicle.SpawnDistance) or 4.0
    local spawn = vector3(pcoords.x + forward.x * dist, pcoords.y + forward.y * dist, pcoords.z)

    local heading = GetEntityHeading(ped)
    local veh = CreateVehicle(hash, spawn.x, spawn.y, spawn.z, heading, true, false)
    if not DoesEntityExist(veh) then
        SetModelAsNoLongerNeeded(hash)
        TriggerServerEvent('aa-adminactions:server:giveCarResult', requestId, false, "spawn_failed")
        return
    end

    SetVehicleOnGroundProperly(veh)
    SetEntityAsMissionEntity(veh, true, true)

    if plate ~= "" then
        SetVehicleNumberPlateText(veh, plate)
    end

    local props = QBCore.Functions.GetVehicleProperties(veh)
    if not props then
        DeleteEntity(veh)
        SetModelAsNoLongerNeeded(hash)
        TriggerServerEvent('aa-adminactions:server:giveCarResult', requestId, false, "spawn_failed")
        return
    end

    props.plate = GetVehicleNumberPlateText(veh)
    SetModelAsNoLongerNeeded(hash)

    TriggerServerEvent('aa-adminactions:server:giveCarResult', requestId, true, props)

    TriggerEvent('vehiclekeys:client:SetOwner', props.plate)
    TriggerEvent('qb-vehiclekeys:client:AddKeys', props.plate)
end)

RegisterCommand(Settings.Command, function()
    TriggerServerEvent('aa-adminactions:server:requestOpenMenu', nil)
end, false)
