
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "ANDRE ULTRA HUB",
    LoadingTitle = "Andre Hub",
    LoadingSubtitle = "Remote Spy",
    ConfigurationSaving = {Enabled = false}
})

-- TAB
local RemoteTab = Window:CreateTab("Remote Spy")

-- STATE
local spying = false
local logs = {}
local maxLogs = 50 -- ANTI LAG LIMIT

-- FILTER
local filterType = "All" -- All / FireServer / InvokeServer
local searchText = ""

---------------------------------------------------
-- 🔘 CONTROLS
---------------------------------------------------

RemoteTab:CreateToggle({
    Name = "Enable Spy",
    CurrentValue = false,
    Callback = function(Value)
        spying = Value
    end
})

RemoteTab:CreateDropdown({
    Name = "Filter Type",
    Options = {"All","FireServer","InvokeServer"},
    CurrentOption = "All",
    Callback = function(Option)
        filterType = Option
    end
})

RemoteTab:CreateInput({
    Name = "Search Remote Name",
    PlaceholderText = "contoh: Damage / Buy",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        searchText = Text:lower()
    end
})

RemoteTab:CreateButton({
    Name = "Clear Logs",
    Callback = function()
        logs = {}
        Rayfield:Notify({
            Title = "Remote Spy",
            Content = "Logs Cleared",
            Duration = 3
        })
    end
})

---------------------------------------------------
-- 🔍 FUNCTION ADD LOG (ANTI LAG + FILTER)
---------------------------------------------------

local function AddLog(remoteName, method, args)
    -- FILTER TYPE
    if filterType ~= "All" and method ~= filterType then
        return
    end

    -- SEARCH FILTER
    if searchText ~= "" and not string.find(remoteName:lower(), searchText) then
        return
    end

    local text = remoteName .. " ("..method..")"

    for i,v in pairs(args) do
        text = text .. "\n["..i.."]: ".. tostring(v)
    end

    -- LIMIT LOG (ANTI LAG)
    if #logs >= maxLogs then
        table.remove(logs, 1)
    end

    table.insert(logs, text)

    -- UI BUTTON
    RemoteTab:CreateButton({
        Name = text,
        Callback = function()
            setclipboard(text)
            Rayfield:Notify({
                Title = "Copied",
                Content = remoteName,
                Duration = 2
            })
        end
    })
end

---------------------------------------------------
-- 🔗 HOOK REMOTE
---------------------------------------------------

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if spying and (method == "FireServer" or method == "InvokeServer") then
        AddLog(self.Name, method, args)

        Rayfield:Notify({
            Title = "Remote Detected",
            Content = self.Name,
            Duration = 1
        })
    end

    return old(self, ...)
end)

setreadonly(mt, true)

---------------------------------------------------
-- 🔔 NOTIF AWAL
---------------------------------------------------

Rayfield:Notify({
    Title = "Andre Hub",
    Content = "Remote Spy Loaded!",
    Duration = 5
})
