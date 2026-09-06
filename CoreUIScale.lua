if not game:IsLoaded() then
    game.Loaded:Wait()
end

local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local SCALE = tonumber(getgenv().CoreUIScale) or 0.65
local COMPACT = tonumber(getgenv().CoreUICompact) or 30

SCALE = math.clamp(SCALE, 0.40, 1.00)
COMPACT = math.clamp(COMPACT, 0, 60)

local TAG = "__JoaoCoreUIScale"
local lastLeft
local baseLeftPosition

local function scale(obj)
    if not obj or not obj:IsA("GuiObject") then
        return
    end

    local s = obj:FindFirstChild(TAG)

    if not s then
        s = Instance.new("UIScale")
        s.Name = TAG
        s.Parent = obj
    end

    s.Scale = SCALE
end

local function hideBackpack()
    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    end)

    local robloxGui = CoreGui:FindFirstChild("RobloxGui")

    if robloxGui then
        local backpack = robloxGui:FindFirstChild("Backpack")

        if backpack then
            if backpack:IsA("ScreenGui") then
                backpack.Enabled = false
            elseif backpack:IsA("GuiObject") then
                backpack.Visible = false
            end
        end
    end

    local topContainer = CoreGui:FindFirstChild("TopBarApp")
    local top = topContainer and topContainer:FindFirstChild("TopBarApp")

    if top then
        for _,v in ipairs(top:GetDescendants()) do
            local n = string.lower(v.Name)

            if string.find(n, "backpack", 1, true)
            or string.find(n, "inventory", 1, true) then
                if v:IsA("GuiObject") then
                    v.Visible = false
                end
            end
        end
    end
end

local function applyTopbar()
    local topContainer = CoreGui:FindFirstChild("TopBarApp")

    if not topContainer then
        return
    end

    local top = topContainer:FindFirstChild("TopBarApp")

    if not top then
        return
    end

    local left = top:FindFirstChild("UnibarLeftFrame")
    local menu = left and left:FindFirstChild("UnibarMenu")
    local menuIcon = top:FindFirstChild("MenuIconHolder")

    if menuIcon then
        scale(menuIcon)
    end

    if menu then
        scale(menu)
    end

    if left then
        if left ~= lastLeft then
            lastLeft = left
            baseLeftPosition = left.Position
        end

        if baseLeftPosition then
            left.Position = UDim2.new(
                baseLeftPosition.X.Scale,
                baseLeftPosition.X.Offset - COMPACT,
                baseLeftPosition.Y.Scale,
                baseLeftPosition.Y.Offset
            )
        end
    end
end

local function applyChat()
    local chat = CoreGui:FindFirstChild("ExperienceChat")

    if not chat then
        return
    end

    local app = chat:FindFirstChild("appLayout")

    if app then
        scale(app)
    end
end

local function apply()
    pcall(hideBackpack)
    pcall(applyTopbar)
    pcall(applyChat)
end

task.spawn(function()
    for _ = 1, 30 do
        apply()
        task.wait(0.25)
    end
end)

CoreGui.DescendantAdded:Connect(function()
    task.defer(function()
        task.wait(0.15)
        apply()
    end)
end)

task.spawn(function()
    while task.wait(1) do
        hideBackpack()
        applyTopbar()
    end
end)

print("[CoreUI Scale] " .. math.floor(SCALE * 100) .. "%")