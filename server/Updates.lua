if not Config or not Config.CheckForUpdates then
    return
end

local REPO = "abu-atab/aa-adminactions"

local function GetCurrentVersion()
    local res = GetCurrentResourceName()
    local v = GetResourceMetadata(res, "version", 0)
    return v and v:match("%d+%.%d+%.%d+") or nil
end

local function IsOutdated(current, latest)
    local function split(v)
        local a,b,c = v:match("(%d+)%.(%d+)%.(%d+)")
        return tonumber(a), tonumber(b), tonumber(c)
    end

    local c1,c2,c3 = split(current)
    local l1,l2,l3 = split(latest)

    if c1 ~= l1 then return c1 < l1 end
    if c2 ~= l2 then return c2 < l2 end
    if c3 ~= l3 then return c3 < l3 end
    return false
end

CreateThread(function()
    Wait(1500)

    local currentVersion = GetCurrentVersion()
    if not currentVersion then return end

    local url = ("https://api.github.com/repos/%s/releases/latest"):format(REPO)

    PerformHttpRequest(url, function(code, body)
        if code ~= 200 or not body then return end

        local ok, data = pcall(json.decode, body)
        if not ok or not data or data.prerelease then return end

        local latest = data.tag_name and data.tag_name:match("%d+%.%d+%.%d+")
        if not latest then return end

        if IsOutdated(currentVersion, latest) then
            print("^1[aa-adminactions]^7 Outdated version!")
            print("^1Current:^7 " .. currentVersion)
            print("^2Latest:^7 " .. latest)
            print("^3Update:^7 " .. (data.html_url or "N/A"))
        else
            print("^2[aa-adminactions]^7 Running latest version (" .. currentVersion .. ")")
        end
    end, "GET", "", {
        ["User-Agent"] = "FiveM-Version-Checker"
    })
end)
