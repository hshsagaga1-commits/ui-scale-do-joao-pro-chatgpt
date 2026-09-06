if not game:IsLoaded() then
    game.Loaded:Wait()
end

local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local SCALE = tonumber(getgenv().CoreUIScale) or 0.65
local GAP = tonumber(getgenv().CoreUIGap) or 7

SCALE = math.clamp(SCALE, 0.40, 1.00)

local TAG = "__JoaoCoreUIScaleV3"

local function clearOld()
    for _,v in ipairs(CoreGui:GetDescendants()) do
        if v:IsA("UIScale") then
            if v.Name == "__JoaoCoreUIScale"
            or v.Name == "__JoaoCoreUIScaleV2"
            or v.Name == TAG then
                v:Destroy()
            end
        end
    end
end

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

local function containsWord(text)
    text = string.lower(text or "")

    return string.find(text, "backpack", 1, true)
        or string.find(text, "inventory", 1, true)
        or string.find(text, "equipment", 1, true)
        or string.find(text, "shop", 1, true)
        or string.find(text, "store", 1, true)
end

local function signature(obj)
    local result = obj.Name

    for _,v in ipairs(obj:GetDescendants()) do
        result = result .. " " .. v.Name

        if v:IsA("ImageButton") or v:IsA("ImageLabel") then
            result = result .. " " .. tostring(v.Image)
        end

        if v:IsA("TextButton") or v:IsA("TextLabel") then
            result = result .. " " .. tostring(v.Text)
        end
    end

    return string.lower(result)
end

local function hideBackpack()
    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    end)

    local robloxGui = CoreGui:FindFirstChild("RobloxGui")

    if robloxGui then
        local backpack = robloxGui:FindFirstChild("Backpack")

        if backpack then
            if backpack:IsA("GuiObject") then
                backpack.Visible = false
            elseif backpack:IsA("ScreenGui") then
                backpack.Enabled = false
            end
        end
    end

    local topContainer = CoreGui:FindFirstChild("TopBarApp")
    local top = topContainer and topContainer:FindFirstChild("TopBarApp")

    if top then
        for _,v in ipairs(top:GetDescendants()) do
            local extra = v.Name

            if v:IsA("ImageButton") or v:IsA("ImageLabel") then
                extra = extra .. " " .. tostring(v.Image)
            end

            if containsWord(extra) then
                local target = v
                local current = v

                while current and current ~= top do
                    if current:IsA("GuiButton") then
                        target = current
                        break
                    end

                    current = current.Parent
                end

                if target:IsA("GuiObject") then
                    target.Visible = false
                end
            end
        end
    end
end

local function hideGameBag()
    for _,v in ipairs(PlayerGui:GetDescendants()) do
        if v:IsA("GuiButton") and v.Visible then
            local pos = v.AbsolutePosition
            local size = v.AbsoluteSize

            if pos.Y < 150
            and size.X >= 25
            and size.X <= 150
            and size.Y >= 25
            and size.Y <= 150 then

                local sig = signature(v)

                if containsWord(sig) then
                    v.Visible = false
                end
            end
        end
    end
end

local function getTop()
    local container = CoreGui:FindFirstChild("TopBarApp")

    if not container then
        return
    end

    local top = container:FindFirstChild("TopBarApp")

    if not top then
        return
    end

    local left = top:FindFirstChild("UnibarLeftFrame")
    local menu = left and left:FindFirstChild("UnibarMenu")
    local icon = top:FindFirstChild("MenuIconHolder")

    return top, left, menu, icon
end

local function compact()
    local top, left, menu, icon = getTop()

    if not top or not left or not menu or not icon then
        return
    end

    scale(icon)
    scale(menu)

    RunService.Heartbeat:Wait()
    RunService.Heartbeat:Wait()

    if not menu.Parent or not icon.Parent then
        return
    end

    local iconPos = icon.AbsolutePosition
    local iconSize = icon.AbsoluteSize

    local menuPos = menu.AbsolutePosition
    local menuSize = menu.AbsoluteSize

    local desiredX = iconPos.X + iconSize.X + GAP
    local desiredY = iconPos.Y + (iconSize.Y / 2) - (menuSize.Y / 2)

    local dx = desiredX - menuPos.X
    local dy = desiredY - menuPos.Y

    if math.abs(dx) < 500 and math.abs(dy) < 200 then
        local p = left.Position

        left.Position = UDim2.new(
            p.X.Scale,
            p.X.Offset + dx,
            p.Y.Scale,
            p.Y.Offset + dy
        )
    end
end

local function apply()
    pcall(hideBackpack)
    pcall(hideGameBag)
    pcall(compact)

    local chat = CoreGui:FindFirstChild("ExperienceChat")

    if chat then
        local app = chat:FindFirstChild("appLayout")

        if app then
            scale(app)
        end
    end
end

clearOld()

task.spawn(function()
    for _ = 1, 40 do
        apply()
        task.wait(0.25)
    end
end)

CoreGui.DescendantAdded:Connect(function()
    task.defer(function()
        task.wait(0.1)
        apply()
    end)
end)

PlayerGui.DescendantAdded:Connect(function()
    task.defer(function()
        task.wait(0.1)
        hideGameBag()
    end)
end)

task.spawn(function()
    while task.wait(1) do
        apply()
    end
end)

print("[CoreUI Scale V3] " .. math.floor(SCALE * 100) .. "%")