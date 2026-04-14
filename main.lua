local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local HttpService = game:GetService("HttpService")

---------------------------------------------------
-- WINDOW
---------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "ANDRE ULTRA HUB",
    LoadingTitle = "Remote Spy System",
    LoadingSubtitle = "Discord Logger",
    ConfigurationSaving = {Enabled = false}
})

local RemoteTab = Window:CreateTab("Remote Spy")

---------------------------------------------------
-- STATE
---------------------------------------------------
local spying = false
local logs = {}
local maxLogs = 50

local filterType = "All"
local searchText = ""

local webhookURL = ""
local autoUpload = false
local uploadDelay = 30

---------------------------------------------------
-- UI INPUT WEBHOOK
---------------------------------------------------
RemoteTab:CreateInput({
    Name = "Discord Webhook URL",
    PlaceholderText = "Paste webhook here",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        webhookURL = Text
        Rayfield:Notify({
            Title = "Webhook Set",
            Content = "Webhook berhasil disimpan",
            Duration = 2
        })
    end
})

---------------------------------------------------
-- CONTROLS
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
    Name = "Search Remote",
    PlaceholderText = "Damage / Buy / etc",
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
            Title = "Logs",
            Content = "Cleared",
            Duration = 2
        })
    end
})

---------------------------------------------------
-- DISCORD SEND
---------------------------------------------------
local function sendToDiscord()
    if webhookURL == "" then
        Rayfield:Notify({
            Title = "Error",
            Content = "Webhook belum diisi!",
            Duration = 3
        })
        return
    end

    local content = table.concat(logs, "\n")

    if #content > 1900 then
        content = string.sub(content, 1, 1900) .. "\n... (cut)"
    end

    local data = {
        ["content"] = "📡 **Remote Spy Log**\n```\n" .. content .. "\n```"
    }

    request({
        Url = webhookURL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode(data)
    })

    Rayfield:Notify({
        Title = "Discord",
        Content = "Log terkirim!",
        Duration = 2
    })
end

---------------------------------------------------
-- AUTO UPLOAD
---------------------------------------------------
RemoteTab:CreateToggle({
    Name = "Auto Upload Discord",
    CurrentValue = false,
    Callback = function(Value)
        autoUpload = Value

        task.spawn(function()
            while autoUpload do
                task.wait(uploadDelay)
                if autoUpload then
                    sendToDiscord()
                end
            end
        end)
    end
})

RemoteTab:CreateInput({
    Name = "Upload Delay (detik)",
    PlaceholderText = "30",
    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            uploadDelay = num
        end
    end
})

RemoteTab:CreateButton({
    Name = "Upload Now",
    Callback = function()
        sendToDiscord()
    end
})

---------------------------------------------------
-- LOG FUNCTION
---------------------------------------------------
local function AddLog(remoteName, method, args)

    if filterType ~= "All" and method ~= filterType then return end
    if searchText ~= "" and not string.find(remoteName:lower(), searchText) then return end

    local text = remoteName .. " ("..method..")"

    for i,v in pairs(args) do
        text = text .. "\n["..i.."]: "..tostring(v)
    end

    if #logs >= maxLogs then
        table.remove(logs, 1)
    end

    table.insert(logs, text)

    RemoteTab:CreateButton({
        Name = text,
        Callback = function()
            setclipboard(text)
            Rayfield:Notify({
                Title = "Copied",
                Content = "Remote copied",
                Duration = 2
            })
        end
    })
end

---------------------------------------------------
-- HOOK REMOTE
---------------------------------------------------
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if spying and (method == "FireServer" or method == "InvokeServer") then
        AddLog(self.Name, method, args)
    end

    return old(self, ...)
end)

setreadonly(mt, true)

---------------------------------------------------
-- START NOTIF
---------------------------------------------------
Rayfield:Notify({
    Title = "Remote Spy",
    Content = "Loaded Successfully",
    Duration = 5
})
