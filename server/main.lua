local QBCore = exports['qb-core']:GetCoreObject()

local function notify(src, key, nType)
    TriggerClientEvent('QBCore:Notify', src, T(key), nType or 'error')
end

local function hasPermission(src)
    local mode = (Settings.Permission and Settings.Permission.Mode) or 'all'
    if mode == 'all' then return true end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end

    if mode == 'jobs' then
        local job = Player.PlayerData.job and Player.PlayerData.job.name or ''
        for _, j in ipairs(Settings.Permission.Jobs or {}) do
            if j == job then return true end
        end
        return false
    end

    if mode == 'citizenids' then
        local cid = Player.PlayerData.citizenid
        for _, v in ipairs(Settings.Permission.CitizenIds or {}) do
            if v == cid then return true end
        end
        return false
    end

    if mode == 'qbadmin' then
        local commandChecks = {
            'command.admin',
            'command.a',
            'command.staff',
            'command.menuadmin',
            'command.qbadmin'
        }
        for _, ace in ipairs(commandChecks) do
            if IsPlayerAceAllowed(src, ace) then
                return true
            end
        end
        return false
    end

    return false
end

local function distanceOk(src, target)
    local ped1 = GetPlayerPed(src)
    local ped2 = GetPlayerPed(target)
    if not ped1 or ped1 == 0 or not ped2 or ped2 == 0 then return false end
    local c1 = GetEntityCoords(ped1)
    local c2 = GetEntityCoords(ped2)
    local dist = #(c1 - c2)
    return dist <= (Settings.Security.MaxDistance or 5.0)
end

local function sanitizePlate(p)
    if not p then return "" end
    return tostring(p):upper():gsub("%s+", "")
end

local function isValidPlate(plate)
    if not plate or plate == "" then return true end
    local minLen = (Settings.Vehicle and Settings.Vehicle.Plate and Settings.Vehicle.Plate.MinLen) or 4
    local maxLen = (Settings.Vehicle and Settings.Vehicle.Plate and Settings.Vehicle.Plate.MaxLen) or 8
    if #plate < minLen or #plate > maxLen then return false end
    return plate:match("^[A-Z0-9]+$") ~= nil
end

local function getLicense(src)
    local lic = QBCore.Functions.GetIdentifier(src, 'license')
    return lic or ""
end

local lastAction = {}
local function canRun(src)
    local now = os.time()
    local cd = Settings.Security.CooldownSeconds or 2
    if lastAction[src] and (now - lastAction[src]) < cd then
        return false
    end
    lastAction[src] = now
    return true
end

local function randomPlate()
    local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local len = 8
    local out = {}
    for i = 1, len do
        local r = math.random(#charset)
        out[i] = charset:sub(r, r)
    end
    return table.concat(out)
end

local function ensureUniquePlate(plate, cb)
    exports.oxmysql:scalar('SELECT plate FROM player_vehicles WHERE plate = ? LIMIT 1', { plate }, function(res)
        cb(res == nil)
    end)
end

RegisterNetEvent('aa-adminactions:server:requestOpenMenu', function(prefillTargetId)
    local src = source
    if not hasPermission(src) then
        notify(src, 'error.no_perm', 'error')
        return
    end
    TriggerClientEvent('aa-adminactions:client:openMainMenu', src, prefillTargetId)
end)

RegisterNetEvent('aa-adminactions:server:giveMoney', function(mType, targetId, amount)
    local src = source
    if not canRun(src) then notify(src, 'error.cooldown', 'error') return end
    if not hasPermission(src) then notify(src, 'error.no_perm', 'error') return end

    local target = tonumber(targetId)
    local val = tonumber(amount)

    if not target or not val or val < 1 or val > (Settings.Limits.MaxMoneyAmount or 10000000) then
        notify(src, 'error.invalid_amount', 'error')
        return
    end

    local tPlayer = QBCore.Functions.GetPlayer(target)
    if not tPlayer then notify(src, 'error.invalid_target', 'error') return end
    if not distanceOk(src, target) then notify(src, 'error.too_far', 'error') return end

    if mType == 'cash' then
        tPlayer.Functions.AddMoney('cash', val, 'aa-adminactions')
    elseif mType == 'bank' then
        tPlayer.Functions.AddMoney('bank', val, 'aa-adminactions')
    elseif mType == 'black' then
        local itemName = Settings.Money.BlackItemName
        if not itemName or itemName == '' then
            notify(src, 'error.black_not_set', 'error')
            return
        end

        local ok = tPlayer.Functions.AddItem(itemName, val)
        if not ok then
            notify(src, 'error.inv_full', 'error')
            return
        end

        TriggerClientEvent('inventory:client:ItemBox', target, QBCore.Shared.Items[itemName], 'add', val)
    else
        notify(src, 'error.invalid_amount', 'error')
        return
    end

    notify(src, 'success.money_sent', 'success')

    if AAActionsLog then
        local actionLabel = "Give Money"
        if mType == 'cash' then actionLabel = "Give Money (Cash)"
        elseif mType == 'bank' then actionLabel = "Give Money (Bank)"
        elseif mType == 'black' then actionLabel = "Give Money (Black Money)"
        end

        local lines = AAActionsLog.BuildActionsLines(src, target, actionLabel, nil, val, nil, nil, nil, nil)
        AAActionsLog.Info("Admin Actions", lines)
    end
end)

RegisterNetEvent('aa-adminactions:server:giveItem', function(itemName, qty, targetId)
    local src = source
    if not canRun(src) then notify(src, 'error.cooldown', 'error') return end
    if not hasPermission(src) then notify(src, 'error.no_perm', 'error') return end

    local target = tonumber(targetId)
    local amount = tonumber(qty)
    local item = tostring(itemName or '')

    if not target or not amount or amount < 1 or amount > (Settings.Limits.MaxItemAmount or 100000) then
        notify(src, 'error.invalid_amount', 'error')
        return
    end

    if item == '' or not QBCore.Shared.Items[item] then
        notify(src, 'error.invalid_item', 'error')
        return
    end

    local tPlayer = QBCore.Functions.GetPlayer(target)
    if not tPlayer then notify(src, 'error.invalid_target', 'error') return end
    if not distanceOk(src, target) then notify(src, 'error.too_far', 'error') return end

    local ok = tPlayer.Functions.AddItem(item, amount)
    if not ok then
        notify(src, 'error.inv_full', 'error')
        return
    end

    TriggerClientEvent('inventory:client:ItemBox', target, QBCore.Shared.Items[item], 'add', amount)
    notify(src, 'success.item_sent', 'success')

    if AAActionsLog then
        local lines = AAActionsLog.BuildActionsLines(src, target, "Give Item", item, amount, nil, nil, nil, nil)
        AAActionsLog.Info("Admin Actions", lines)
    end
end)

RegisterNetEvent('aa-adminactions:server:giveJob', function(jobName, grade, targetId)
    local src = source
    if not canRun(src) then notify(src, 'error.cooldown', 'error') return end
    if not hasPermission(src) then notify(src, 'error.no_perm', 'error') return end

    local target = tonumber(targetId)
    local job = tostring(jobName or ''):lower()
    local g = tonumber(grade)

    if not target then
        notify(src, 'error.invalid_target', 'error')
        return
    end

    local tPlayer = QBCore.Functions.GetPlayer(target)
    if not tPlayer then notify(src, 'error.invalid_target', 'error') return end
    if not distanceOk(src, target) then notify(src, 'error.too_far', 'error') return end

    local jobs = QBCore.Shared.Jobs or {}
    local jobData = jobs[job]
    if not jobData then
        notify(src, 'error.invalid_job', 'error')
        return
    end

    if g == nil or g < 0 then
        notify(src, 'error.invalid_grade', 'error')
        return
    end

    local grades = jobData.grades or {}
    if grades[tostring(g)] == nil and grades[g] == nil then
        notify(src, 'error.invalid_grade', 'error')
        return
    end

    tPlayer.Functions.SetJob(job, g)
    notify(src, 'success.job_given', 'success')

    if AAActionsLog then
        local lines = AAActionsLog.BuildActionsLines(src, target, "Give Job", nil, nil, nil, nil, job, g)
        AAActionsLog.Info("Admin Actions", lines)
    end
end)

local PendingCar = {}
local PendingByTarget = {}
local ReqId = 0

local function nextReqId()
    ReqId = ReqId + 1
    return ReqId
end

local function clearPending(requestId)
    local req = PendingCar[requestId]
    if req then
        PendingByTarget[req.target] = nil
    end
    PendingCar[requestId] = nil
end

CreateThread(function()
    while true do
        Wait(3000)
        local now = os.time()
        local timeout = Settings.Security.CarRequestTimeoutSeconds or 20
        for id, req in pairs(PendingCar) do
            if (now - req.createdAt) > timeout then
                if req.src then notify(req.src, 'error.request_expired', 'error') end
                clearPending(id)
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
    local src = source

    for id, req in pairs(PendingCar) do
        if req.src == src or req.target == src then
            clearPending(id)
        end
    end

    PendingByTarget[src] = nil
    lastAction[src] = nil
end)

local function finalizeInsert(req, props)
    local giver = req.src
    local target = req.target
    local vehModel = req.model

    local tPlayer = QBCore.Functions.GetPlayer(target)
    if not tPlayer then
        if giver then notify(giver, 'error.invalid_target', 'error') end
        return
    end

    local citizenid = tPlayer.PlayerData.citizenid
    local license = getLicense(target)

    local mods = props or {}
    local plate = sanitizePlate(mods.plate or req.plate)

    if plate == "" or not isValidPlate(plate) then
        if giver then notify(giver, 'error.plate_invalid', 'error') end
        return
    end

    mods.plate = plate

    exports.oxmysql:insert([[
        INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate)
        VALUES (?, ?, ?, ?, ?, ?)
    ]], {
        license,
        citizenid,
        vehModel,
        joaat(vehModel),
        json.encode(mods),
        plate
    }, function(insertId)
        if not insertId then return end

        if giver then notify(giver, 'success.car_sent', 'success') end

        TriggerClientEvent('vehiclekeys:client:SetOwner', target, plate)
        TriggerClientEvent('qb-vehiclekeys:client:AddKeys', target, plate)

        if AAActionsLog and giver then
            local lines = AAActionsLog.BuildActionsLines(giver, target, "Give Car", nil, nil, vehModel, plate, nil, nil)
            AAActionsLog.Info("Admin Actions", lines)
        end
    end)
end

RegisterNetEvent('aa-adminactions:server:giveCarRequest', function(model, targetId, customPlate)
    local src = source
    if not canRun(src) then notify(src, 'error.cooldown', 'error') return end
    if not (Settings.Vehicle and Settings.Vehicle.Enabled) then return end
    if not hasPermission(src) then notify(src, 'error.no_perm', 'error') return end

    local target = tonumber(targetId)
    if not target then notify(src, 'error.invalid_target', 'error') return end

    local tPlayer = QBCore.Functions.GetPlayer(target)
    if not tPlayer then notify(src, 'error.invalid_target', 'error') return end

    if not distanceOk(src, target) then notify(src, 'error.too_far', 'error') return end

    if PendingByTarget[target] then
        notify(src, 'error.request_busy', 'error')
        return
    end

    local vehModel = tostring(model or ''):lower()
    if vehModel == '' then notify(src, 'error.invalid_model', 'error') return end

    local plate = sanitizePlate(customPlate)
    if plate ~= '' and not isValidPlate(plate) then
        notify(src, 'error.plate_invalid', 'error')
        return
    end

    local function proceedWithPlate(finalPlate)
        local requestId = nextReqId()

        local req = {
            id = requestId,
            src = src,
            target = target,
            model = vehModel,
            plate = finalPlate,
            createdAt = os.time()
        }

        PendingCar[requestId] = req
        PendingByTarget[target] = requestId

        TriggerClientEvent('aa-adminactions:client:spawnVehicleForOwnership', target, {
            model = req.model,
            plate = req.plate,
            requestId = requestId
        })
    end

    if plate == '' then
        local function gen()
            local p = randomPlate()
            ensureUniquePlate(p, function(ok)
                if ok then proceedWithPlate(p) else gen() end
            end)
        end
        gen()
        return
    end

    ensureUniquePlate(plate, function(ok)
        if ok then
            proceedWithPlate(plate)
        else
            local function gen2()
                local p = randomPlate()
                ensureUniquePlate(p, function(ok2)
                    if ok2 then proceedWithPlate(p) else gen2() end
                end)
            end
            gen2()
        end
    end)
end)

RegisterNetEvent('aa-adminactions:server:giveCarResult', function(requestId, ok, payload)
    local src = source
    local req = PendingCar[requestId]
    if not req then return end

    if src ~= req.target then
        clearPending(requestId)
        return
    end

    if req.src and not distanceOk(req.src, req.target) then
        notify(req.src, 'error.too_far', 'error')
        clearPending(requestId)
        return
    end

    if not ok or type(payload) ~= 'table' then
        if req.src then
            if payload == "invalid_model" then notify(req.src, 'error.invalid_model', 'error')
            elseif payload == "plate_invalid" then notify(req.src, 'error.plate_invalid', 'error')
            else notify(req.src, 'error.spawn_failed', 'error')
            end
        end
        clearPending(requestId)
        return
    end

    payload.plate = sanitizePlate(payload.plate or req.plate)
    if payload.plate == '' then payload.plate = req.plate end

    ensureUniquePlate(payload.plate, function(uniqueOk)
        if not uniqueOk then
            local function gen3()
                local p = randomPlate()
                ensureUniquePlate(p, function(ok3)
                    if ok3 then
                        payload.plate = p
                        finalizeInsert(req, payload)
                        clearPending(requestId)
                    else
                        gen3()
                    end
                end)
            end
            gen3()
            return
        end

        finalizeInsert(req, payload)
        clearPending(requestId)
    end)
end)
