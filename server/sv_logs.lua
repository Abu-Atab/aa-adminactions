local QBCore = exports['qb-core']:GetCoreObject()

AAActionsLog = {}

local function getSafeName(src)
    if not src or src == 0 then return "CONSOLE" end
    return GetPlayerName(src) or ("Player_" .. tostring(src))
end

local function getCharName(Player)
    if not Player or not Player.PlayerData or not Player.PlayerData.charinfo then
        return "UNKNOWN"
    end
    local c = Player.PlayerData.charinfo
    local first = tostring(c.firstname or "Unknown")
    local last  = tostring(c.lastname or "")
    return (first .. " " .. last):gsub("%s+$", "")
end

local function initLogger()
    if not (Settings and Settings.Logging and Settings.Logging.Enabled) then return end
    if GetResourceState("aa-log_lib") ~= "started" then return end

    pcall(function()
        exports['aa-log_lib']:setConfig({
            enabled         = true,
            level           = "INFO",
            discord_webhook = (Settings.Logging and Settings.Logging.Webhook or "") or "",
            resourceName    = GetCurrentResourceName(),
            show_header     = true
        })
    end)
end

local function buildMessage(title, lines)
    local out = ""
    for _, l in ipairs(lines or {}) do
        out = out .. tostring(l) .. "\n"
    end
    return string.format("**%s**\n```yaml\n%s```", title, out)
end

CreateThread(function()
    Wait(800)
    initLogger()
end)

function AAActionsLog.Info(title, yamlLines)
    if not (Settings and Settings.Logging and Settings.Logging.Enabled) then return end
    if GetResourceState("aa-log_lib") ~= "started" then return end
    exports['aa-log_lib']:info(buildMessage(title, yamlLines), {})
end

function AAActionsLog.DisplayName(src)
    if not src or src == 0 then
        return "CONSOLE"
    end

    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player and Player.PlayerData and Player.PlayerData.citizenid or "UNKNOWN"
    local pname = getSafeName(src)
    local cname = getCharName(Player)

    local finalName = (cname ~= "UNKNOWN" and cname ~= "") and cname or pname
    return string.format("%s (CID: %s | ID: %s)", finalName, cid, tostring(src))
end

function AAActionsLog.BuildActionsLines(adminSrc, playerSrc, action, itemName, amount, code, plate, job, grade)
    local lines = {}

    lines[#lines+1] = ("Admin: %s"):format(AAActionsLog.DisplayName(adminSrc))
    lines[#lines+1] = ("Player: %s"):format(AAActionsLog.DisplayName(playerSrc))
    lines[#lines+1] = ("Action: %s"):format(tostring(action or "UNKNOWN"))

    if itemName and itemName ~= "" then
        lines[#lines+1] = ("Item Name: %s"):format(tostring(itemName))
    end

    if amount ~= nil then
        lines[#lines+1] = ("Amount: %s"):format(tostring(amount))
    end

    if code and code ~= "" then
        lines[#lines+1] = ("Code: %s"):format(tostring(code))
    end

    if plate and plate ~= "" then
        lines[#lines+1] = ("Plate: %s"):format(tostring(plate))
    end

    if job and job ~= "" then
        lines[#lines+1] = ("Job: %s"):format(tostring(job))
    end

    if grade ~= nil then
        lines[#lines+1] = ("Grade: %s"):format(tostring(grade))
    end

    return lines
end
