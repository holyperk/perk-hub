--[[
    PERK HUB LOADER
    KeyAuth -> GitHub Raw -> PERK HUB MAIN

    App:
      Name: perk hub
      Owner ID: N2xiEClavP
      Version: 1.0
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local APP_NAME = "perk hub"
local OWNER_ID = "N2xiEClavP"
local VERSION = "1.0"
local KEYAUTH_API = "https://keyauth.win/api/1.3/"
local SCRIPT_URL = "https://raw.githubusercontent.com/holyperk/perk-hub/main/main.lua"
local KEY_FOLDER = "PerkHub"
local KEY_FILE = KEY_FOLDER .. "/license.key"

local Request = (syn and syn.request) or (http and http.request) or http_request or request
if not Request then
    return
end

local function New(className, props, parent)
    local obj = Instance.new(className)
    for key, value in pairs(props or {}) do
        obj[key] = value
    end
    if parent then
        obj.Parent = parent
    end
    return obj
end

local function Corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
    return c
end

local function Stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
    return s
end

local C = {
    Background = Color3.fromRGB(9, 8, 11),
    Card = Color3.fromRGB(16, 14, 20),
    Card2 = Color3.fromRGB(20, 17, 24),
    Border = Color3.fromRGB(40, 33, 45),
    Pink = Color3.fromRGB(232, 70, 151),
    PinkBright = Color3.fromRGB(255, 103, 180),
    PinkDark = Color3.fromRGB(120, 34, 78),
    Text = Color3.fromRGB(245, 242, 247),
    SubText = Color3.fromRGB(161, 153, 166),
    Muted = Color3.fromRGB(102, 96, 108),
    Green = Color3.fromRGB(85, 214, 135),
    Red = Color3.fromRGB(230, 75, 90),
    Yellow = Color3.fromRGB(238, 196, 77)
}

local function GetHWID()
    local hwid = ""
    pcall(function()
        hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    return type(hwid) == "string" and hwid or ""
end

local function UrlEncode(value)
    return HttpService:UrlEncode(tostring(value or ""))
end

local function KeyAuthRequest(params)
    local query = {}
    for key, value in pairs(params) do
        query[#query + 1] = UrlEncode(key) .. "=" .. UrlEncode(value)
    end

    local ok, response = pcall(function()
        return Request({
            Url = KEYAUTH_API .. "?" .. table.concat(query, "&"),
            Method = "GET",
            Headers = {
                ["Accept"] = "application/json"
            }
        })
    end)

    if not ok then
        return false, tostring(response)
    end

    if type(response) ~= "table" then
        return false, "Invalid HTTP response"
    end

    local body = response.Body or response.body
    if type(body) ~= "string" or body == "" then
        return false, "Empty KeyAuth response"
    end

    local decodedOk, decoded = pcall(function()
        return HttpService:JSONDecode(body)
    end)

    if not decodedOk or type(decoded) ~= "table" then
        return false, "Invalid KeyAuth JSON response"
    end

    return true, decoded
end

local function EnsureKeyFolder()
    if not makefolder then
        return
    end

    pcall(function()
        if not isfolder(KEY_FOLDER) then
            makefolder(KEY_FOLDER)
        end
    end)
end

local function LoadSavedKey()
    if not isfile or not readfile then
        return ""
    end

    if not isfile(KEY_FILE) then
        return ""
    end

    local ok, value = pcall(readfile, KEY_FILE)
    if not ok or type(value) ~= "string" then
        return ""
    end

    return value:gsub("^%s+", ""):gsub("%s+$", "")
end

local function SaveKey(value)
    if not writefile then
        return
    end

    EnsureKeyFolder()

    pcall(function()
        writefile(KEY_FILE, value)
    end)
end

local function CreateLogin()
    local gui = New("ScreenGui", {
        Name = "PerkHubLoader",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, CoreGui)

    local backdrop = New("Frame", {
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.32,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1)
    }, gui)

    local window = New("Frame", {
        BackgroundColor3 = C.Background,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 25),
        Size = UDim2.fromOffset(410, 270)
    }, gui)
    Corner(window, 10)
    Stroke(window, C.Border, 1, 0.05)

    local grad = New("UIGradient", {
        Color = ColorSequence.new(
            Color3.fromRGB(18, 14, 22),
            Color3.fromRGB(9, 8, 11)
        ),
        Rotation = 90
    }, window)

    local title = New("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "PERK HUB",
        TextColor3 = C.Text,
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        Position = UDim2.fromOffset(20, 16),
        Size = UDim2.new(1, -40, 0, 25)
    }, window)

    local subtitle = New("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "License authentication",
        TextColor3 = C.Muted,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        Position = UDim2.fromOffset(20, 42),
        Size = UDim2.new(1, -40, 0, 18)
    }, window)

    local line = New("Frame", {
        BackgroundColor3 = C.Pink,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(20, 66),
        Size = UDim2.new(1, -40, 0, 1)
    }, window)
    local lineGradient = New("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.PinkDark),
            ColorSequenceKeypoint.new(0.5, C.PinkBright),
            ColorSequenceKeypoint.new(1, C.PinkDark)
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.2, 0.15),
            NumberSequenceKeypoint.new(0.8, 0.15),
            NumberSequenceKeypoint.new(1, 1)
        })
    }, line)

    local keyLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "License key",
        TextColor3 = C.SubText,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(20, 84),
        Size = UDim2.new(1, -40, 0, 18)
    }, window)

    local keyBox = New("TextBox", {
        BackgroundColor3 = C.Card2,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        PlaceholderText = "XXXX-XXXX-XXXX-XXXX",
        PlaceholderColor3 = C.Muted,
        Text = LoadSavedKey(),
        TextColor3 = C.Text,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(20, 108),
        Size = UDim2.new(1, -40, 0, 42)
    }, window)
    Corner(keyBox, 7)
    Stroke(keyBox, C.Border, 1, 0.15)

    local login = New("TextButton", {
        BackgroundColor3 = C.PinkDark,
        BorderSizePixel = 0,
        Text = "LOGIN",
        TextColor3 = C.PinkBright,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Position = UDim2.fromOffset(20, 158),
        Size = UDim2.new(1, -40, 0, 38)
    }, window)
    Corner(login, 7)
    Stroke(login, C.PinkDark, 1, 0.15)

    local savedKey = LoadSavedKey()

    local status = New("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = savedKey ~= "" and "Status: saved key loaded — press LOGIN" or "Status: waiting for key",
        TextColor3 = C.Muted,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        Position = UDim2.fromOffset(20, 205),
        Size = UDim2.new(1, -40, 0, 20)
    }, window)

    local version = New("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "PERK HUB • v" .. VERSION,
        TextColor3 = C.Muted,
        TextSize = 8,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        Position = UDim2.fromOffset(20, 232),
        Size = UDim2.new(1, -40, 0, 18)
    }, window)

    local closed = false
    local accepted = false
    local busy = false

    local function SetStatus(text, color)
        status.Text = "Status: " .. tostring(text)
        status.TextColor3 = color or C.Muted
    end

    local function Finish(ok)
        accepted = ok
        if gui and gui.Parent then
            gui:Destroy()
        end
    end

    local function TryLogin()
        if busy or closed then
            return
        end

        local key = keyBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if key == "" then
            SetStatus("enter a license key", C.Yellow)
            return
        end

        busy = true
        login.Text = "CHECKING..."
        login.BackgroundColor3 = C.Card2
        login.TextColor3 = C.SubText
        SetStatus("connecting to KeyAuth...", C.SubText)

        local initOk, init = KeyAuthRequest({
            type = "init",
            ver = VERSION,
            name = APP_NAME,
            ownerid = OWNER_ID,
            hash = "undefined",
            token = "undefined",
            thash = "undefined"
        })

        if not initOk or init.success ~= true then
            busy = false
            login.Text = "LOGIN"
            login.BackgroundColor3 = C.PinkDark
            login.TextColor3 = C.PinkBright
            SetStatus(initOk and (init.message or "initialization failed") or init, C.Red)
            return
        end

        local sessionId = init.sessionid
        SetStatus("validating license...", C.SubText)

        local loginOk, result = KeyAuthRequest({
            type = "license",
            key = key,
            sessionid = sessionId or "",
            name = APP_NAME,
            ownerid = OWNER_ID,
            hwid = GetHWID()
        })

        if not loginOk or result.success ~= true then
            busy = false
            login.Text = "LOGIN"
            login.BackgroundColor3 = C.PinkDark
            login.TextColor3 = C.PinkBright
            SetStatus(loginOk and (result.message or "invalid license") or result, C.Red)
            return
        end

        SaveKey(key)
        SetStatus("license accepted", C.Green)
        login.Text = "LOADING..."

        local ok, response = pcall(function()
            return Request({
                Url = SCRIPT_URL,
                Method = "GET",
                Headers = {
                    ["Accept"] = "text/plain"
                }
            })
        end)

        if not ok or type(response) ~= "table" then
            busy = false
            login.Text = "LOGIN"
            login.BackgroundColor3 = C.PinkDark
            login.TextColor3 = C.PinkBright
            SetStatus("failed to contact server", C.Red)
            return
        end

        local body = response.Body or response.body or ""
        local statusCode = tonumber(
            response.StatusCode
            or response.statusCode
            or response.Status
            or response.status
            or response.status_code
        )

        if statusCode and statusCode ~= 200 then
            local message = tostring(body ~= "" and body or ("HTTP " .. tostring(statusCode)))
            if #message > 90 then
                message = message:sub(1, 90) .. "..."
            end
            busy = false
            login.Text = "LOGIN"
            login.BackgroundColor3 = C.PinkDark
            login.TextColor3 = C.PinkBright
            SetStatus(message, C.Red)
            return
        end

        if type(body) ~= "string" or body == "" then
            busy = false
            login.Text = "LOGIN"
            login.BackgroundColor3 = C.PinkDark
            login.TextColor3 = C.PinkBright
            SetStatus("server returned no script", C.Red)
            return
        end

        Finish(true)

        task.wait(0.1)

        local loader, compileError = loadstring(body)
        if not loader then
            return
        end

        local runOk, runError = pcall(loader)
        if not runOk then
        end
    end

    login.MouseEnter:Connect(function()
        if not busy then
            TweenService:Create(login, TweenInfo.new(0.12), {
                BackgroundColor3 = C.PinkDark,
                TextColor3 = C.PinkBright
            }):Play()
        end
    end)

    login.MouseLeave:Connect(function()
        if not busy then
            TweenService:Create(login, TweenInfo.new(0.12), {
                BackgroundColor3 = C.PinkDark,
                TextColor3 = C.PinkBright
            }):Play()
        end
    end)

    login.MouseButton1Click:Connect(TryLogin)

    keyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            TryLogin()
        end
    end)

    local inputConnection
    inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if closed or not gui.Parent then
            if inputConnection then
                inputConnection:Disconnect()
            end
            return
        end

        if processed then
            return
        end

        if input.UserInputType == Enum.UserInputType.Keyboard and
            (input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter) then
            TryLogin()
        end
    end)

    TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()

    return function()
        while not accepted and not closed do
            task.wait(0.05)
        end
        if inputConnection then
            pcall(function() inputConnection:Disconnect() end)
        end
        return accepted
    end
end

local ok = CreateLogin()()
if not ok then
    return
end
