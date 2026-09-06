if not game:IsLoaded() then
    game.Loaded:Wait()
end

local CoreGui = game:GetService("CoreGui")
local SCALE = tonumber(getgenv().CoreUIScale) or 0.65
SCALE = math.clamp(SCALE, 0.40, 1.00)

local TAG = "__JoaoCoreUIScale"

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

local function apply()
    local topContainer = CoreGui:FindFirstChild("TopBarApp")
    local top = topContainer and topContainer:FindFirstChild("TopBarApp")

    if top then
        local left = top:FindFirstChild("UnibarLeftFrame")
        local menu = left and left:FindFirstChild("UnibarMenu")
        local menuIcon = top:FindFirstChild("MenuIconHolder")

        scale(menu)
        scale(menuIcon)
    end

    local experienceChat = CoreGui:FindFirstChild("ExperienceChat")

    if experienceChat then
        scale(experienceChat:FindFirstChild("appLayout"))
    end

    local robloxGui = CoreGui:FindFirstChild("RobloxGui")

    if robloxGui then
        local backpack = robloxGui:FindFirstChild("Backpack")

        if backpack then
            scale(backpack:FindFirstChild("Hotbar"))
            scale(backpack:FindFirstChild("Inventory"))
        end
    end
end

for _ = 1, 24 do
    pcall(apply)
    task.wait(0.25)
end

CoreGui.DescendantAdded:Connect(function(obj)
    if obj.Name == "TopBarApp"
    or obj.Name == "UnibarMenu"
    or obj.Name == "MenuIconHolder"
    or obj.Name == "appLayout"
    or obj.Name == "Backpack" then
        task.defer(function()
            task.wait(0.15)
            pcall(apply)
        end)
    end
end)

print("[CoreUI Scale] " .. tostring(math.floor(SCALE * 100)) .. "%")