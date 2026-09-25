local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local VERSION = "1.0"
local SCRIPT_URL = "https://perk-hub-api.mefistovmisha.workers.dev/script"
local LOADER_TOKEN = 'sW82a5Wx6roMJEAxbPaxZXKFRDU9ekL9lZ3YgcuF60A'
local KEY_FOLDER = "PerkHub"
local KEY_FILE = KEY_FOLDER .. "/license.key"

local Request = (syn and syn.request) or (http and http.request) or http_request or request
if not Request then return end

local function New(className, props, parent)
    local obj = Instance.new(className)
    for key, value in pairs(props or {}) do obj[key] = value end
    if parent then obj.Parent = parent end
    return obj
end

local function Corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

local function Stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
end

local C = {
    Background = Color3.fromRGB(9, 8, 11),
    Card2 = Color3.fromRGB(20, 17, 24),
    Border = Color3.fromRGB(40, 33, 45),
    PinkDark = Color3.fromRGB(120, 34, 78),
    PinkBright = Color3.fromRGB(255, 103, 180),
    Pink = Color3.fromRGB(232, 70, 151),
    Text = Color3.fromRGB(245, 242, 247),
    SubText = Color3.fromRGB(161, 153, 166),
    Muted = Color3.fromRGB(102, 96, 108),
    Green = Color3.fromRGB(85, 214, 135),
    Red = Color3.fromRGB(230, 75, 90),
    Yellow = Color3.fromRGB(238, 196, 77)
}

local function GetHWID()
    local hwid = ""
    pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)
    return type(hwid) == "string" and hwid or ""
end

local function EnsureKeyFolder()
    if not makefolder then return end
    pcall(function()
        if not isfolder(KEY_FOLDER) then makefolder(KEY_FOLDER) end
    end)
end

local function LoadSavedKey()
    if not isfile or not readfile or not isfile(KEY_FILE) then return "" end
    local ok, value = pcall(readfile, KEY_FILE)
    if not ok or type(value) ~= "string" then return "" end
    return value:gsub("^%s+", ""):gsub("%s+$", "")
end

local function SaveKey(value)
    if not writefile then return end
    EnsureKeyFolder()
    pcall(function() writefile(KEY_FILE, value) end)
end

local function RequestAuth(key)
    local query = table.concat({
        "type=init",
        "ver=1.0",
        "name=" .. HttpService:UrlEncode("perk hub"),
        "ownerid=" .. HttpService:UrlEncode("N2xiEClavP"),
        "hash=undefined",
        "token=undefined",
        "thash=undefined"
    }, "&")

    local okInit, initResp = pcall(function()
        return Request({
            Url = "https://keyauth.win/api/1.3/?" .. query,
            Method = "GET",
            Headers = { ["Accept"] = "application/json" }
        })
    end)
    if not okInit or type(initResp) ~= "table" then
        return false, "KeyAuth connection failed"
    end
    local initBody = initResp.Body or initResp.body or ""
    local okJson, init = pcall(function() return HttpService:JSONDecode(initBody) end)
    if not okJson or type(init) ~= "table" or init.success ~= true then
        return false, (type(init) == "table" and init.message) or "KeyAuth initialization failed"
    end

    local params = table.concat({
        "type=license",
        "key=" .. HttpService:UrlEncode(key),
        "sessionid=" .. HttpService:UrlEncode(init.sessionid or ""),
        "name=" .. HttpService:UrlEncode("perk hub"),
        "ownerid=" .. HttpService:UrlEncode("N2xiEClavP"),
        "hwid=" .. HttpService:UrlEncode(GetHWID())
    }, "&")

    local okLogin, loginResp = pcall(function()
        return Request({
            Url = "https://keyauth.win/api/1.3/?" .. params,
            Method = "GET",
            Headers = { ["Accept"] = "application/json" }
        })
    end)
    if not okLogin or type(loginResp) ~= "table" then
        return false, "KeyAuth connection failed"
    end

    local loginBody = loginResp.Body or loginResp.body or ""
    local okLoginJson, loginData = pcall(function() return HttpService:JSONDecode(loginBody) end)
    if not okLoginJson or type(loginData) ~= "table" or loginData.success ~= true then
        return false, (type(loginData) == "table" and loginData.message) or "KeyAuth license rejected"
    end

    local okScript, scriptResp = pcall(function()
        return Request({
            Url = SCRIPT_URL .. "?loader=" .. HttpService:UrlEncode(LOADER_TOKEN),
            Method = "GET",
            Headers = {
                ["X-Perk-Loader"] = LOADER_TOKEN,
                ["Accept"] = "text/plain"
            }
        })
    end)
    if not okScript or type(scriptResp) ~= "table" then
        return false, "failed to download PERK HUB"
    end

    local body = scriptResp.Body or scriptResp.body or ""
    local status = tonumber(scriptResp.StatusCode or scriptResp.Status or scriptResp.statusCode or scriptResp.status or 0)
    if status ~= 0 and status ~= 200 then
        return false, "server denied the script (HTTP " .. tostring(status) .. ")"
    end
    if body == "" then
        return false, "server returned an empty script"
    end

    return true, body
end

local function CreateLogin()
    pcall(function()
        local old = CoreGui:FindFirstChild("PerkHubLoader")
        if old then old:Destroy() end
    end)

    local gui = New("ScreenGui", {
        Name = "PerkHubLoader",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, CoreGui)

    New("Frame", {
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.32,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1,1)
    }, gui)

    local window = New("Frame", {
        BackgroundColor3 = C.Background,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0,0.5,25),
        Size = UDim2.fromOffset(410,270)
    }, gui)
    Corner(window,10); Stroke(window,C.Border,1,0.05)

    New("UIGradient", {
        Color = ColorSequence.new(Color3.fromRGB(18,14,22), Color3.fromRGB(9,8,11)),
        Rotation = 90
    }, window)

    New("TextLabel", {
        BackgroundTransparency = 1, Text = "PERK HUB", TextColor3 = C.Text,
        TextSize = 17, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center,
        Position = UDim2.fromOffset(20,16), Size = UDim2.new(1,-40,0,25)
    }, window)

    New("TextLabel", {
        BackgroundTransparency = 1, Text = "License authentication", TextColor3 = C.Muted,
        TextSize = 9, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Center,
        Position = UDim2.fromOffset(20,42), Size = UDim2.new(1,-40,0,18)
    }, window)

    local line = New("Frame", {
        BackgroundColor3 = C.Pink, BorderSizePixel = 0,
        Position = UDim2.fromOffset(20,66), Size = UDim2.new(1,-40,0,1)
    }, window)
    New("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,C.PinkDark),
            ColorSequenceKeypoint.new(0.5,C.PinkBright),
            ColorSequenceKeypoint.new(1,C.PinkDark)
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,1),
            NumberSequenceKeypoint.new(0.2,0.15),
            NumberSequenceKeypoint.new(0.8,0.15),
            NumberSequenceKeypoint.new(1,1)
        })
    }, line)

    New("TextLabel", {
        BackgroundTransparency = 1, Text = "License key", TextColor3 = C.SubText,
        TextSize = 10, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(20,84), Size = UDim2.new(1,-40,0,18)
    }, window)

    local savedKey = LoadSavedKey()
    local keyBox = New("TextBox", {
        BackgroundColor3 = C.Card2, BorderSizePixel = 0,
        ClearTextOnFocus = false, PlaceholderText = "XXXX-XXXX-XXXX-XXXX",
        PlaceholderColor3 = C.Muted, Text = savedKey, TextColor3 = C.Text,
        TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(20,108), Size = UDim2.new(1,-40,0,42)
    }, window)
    Corner(keyBox,7); Stroke(keyBox,C.Border,1,0.15)

    local login = New("TextButton", {
        BackgroundColor3 = C.PinkDark, BorderSizePixel = 0, Text = "LOGIN",
        TextColor3 = C.PinkBright, TextSize = 10, Font = Enum.Font.GothamBold,
        AutoButtonColor = false, Position = UDim2.fromOffset(20,158), Size = UDim2.new(1,-40,0,38)
    }, window)
    Corner(login,7); Stroke(login,C.PinkDark,1,0.15)

    local status = New("TextLabel", {
        BackgroundTransparency = 1,
        Text = savedKey ~= "" and "Status: saved key loaded — press LOGIN" or "Status: waiting for key",
        TextColor3 = C.Muted, TextSize = 9, Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        Position = UDim2.fromOffset(20,205), Size = UDim2.new(1,-40,0,20)
    }, window)

    New("TextLabel", {
        BackgroundTransparency = 1, Text = "PERK HUB • v" .. VERSION,
        TextColor3 = C.Muted, TextSize = 8, Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        Position = UDim2.fromOffset(20,232), Size = UDim2.new(1,-40,0,18)
    }, window)

    local closed, accepted, busy = false, false, false
    local function SetStatus(text, color)
        status.Text = "Status: " .. tostring(text)
        status.TextColor3 = color or C.Muted
    end

    local function TryLogin()
        if busy or closed then return end
        local key = keyBox.Text:gsub("^%s+",""):gsub("%s+$","")
        if key == "" then SetStatus("enter a license key",C.Yellow); return end
        busy = true
        login.Text = "CHECKING..."; login.BackgroundColor3 = C.Card2; login.TextColor3 = C.SubText
        SetStatus("validating license...",C.SubText)

        local ok, result = RequestAuth(key)
        if not ok then
            busy = false; login.Text = "LOGIN"; login.BackgroundColor3 = C.PinkDark; login.TextColor3 = C.PinkBright
            SetStatus(result,C.Red)
            return
        end

        SaveKey(key)
        login.Text = "LOADING..."
        SetStatus("license accepted",C.Green)
        accepted = true
        if gui and gui.Parent then gui:Destroy() end
        task.wait(0.1)
        local runner = loadstring(result)
        if runner then pcall(runner) end
    end

    login.MouseButton1Click:Connect(TryLogin)
    keyBox.FocusLost:Connect(function(enterPressed) if enterPressed then TryLogin() end end)

    local inputConnection
    inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if closed or not gui.Parent then
            if inputConnection then inputConnection:Disconnect() end
            return
        end
        if processed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and (input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter) then
            TryLogin()
        end
    end)

    local scale = New("UIScale", { Scale = 0.82 }, window)
    TweenService:Create(scale,TweenInfo.new(0.34,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()

    return function()
        while not accepted and not closed do task.wait(0.05) end
        if inputConnection then pcall(function() inputConnection:Disconnect() end) end
        return accepted
    end
end

if not CreateLogin()() then return end
