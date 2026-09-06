if not game:IsLoaded() then
    game.Loaded:Wait()
end

local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local SCALE = tonumber(getgenv().CoreUIScale) or 0.65
SCALE = math.clamp(SCALE, 0.40, 1.00)

local OLDTAG = "__JoaoCoreUIScale"
local TAG = "__JoaoCoreUIScaleV2"

local function removeOld()
    for _,v in ipairs(CoreGui:GetDescendants()) do
        if v:IsA("UIScale") and (v.Name == OLDTAG or v.Name == TAG) then
            v:Destroy()
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

local function disableBackpack()
    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    end)

    local topContainer = CoreGui:FindFirstChild("TopBarApp")
    local top = topContainer and topContainer:FindFirstChild("TopBarApp")

    if top then
        for _,v in ipairs(top:GetDescendants()) do
            if v:IsA("GuiObject") then
                local n = string.lower(v.Name)

                if string.find(n, "backpack", 1, true)
                or string.find(n, "inventory", 1, true) then
                    v.Visible = false
                end
            end
        end
    end
end

local function apply()
    for _,v in ipairs(CoreGui:GetDescendants()) do
        if v:IsA("UIScale") and v.Name == OLDTAG then
            v:Destroy()
        end
    end

    disableBackpack()

    local topContainer = CoreGui:FindFirstChild("TopBarApp")
    local top = topContainer and topContainer:FindFirstChild("TopBarApp")

    if top then
        scale(top)
    end

    local chat = CoreGui:FindFirstChild("ExperienceChat")

    if chat then
        scale(chat:FindFirstChild("appLayout"))
    end
end

removeOld()

for _ = 1, 24 do
    pcall(apply)
    task.wait(0.25)
end

CoreGui.DescendantAdded:Connect(function(obj)
    if obj:IsA("UIScale") and obj.Name == OLDTAG then
        task.defer(function()
            pcall(function()
                obj:Destroy()
            end)
        end)
        return
    end

    if obj.Name == "TopBarApp"
    or obj.Name == "ExperienceChat"
    or obj.Name == "appLayout"
    or string.find(string.lower(obj.Name), "backpack", 1, true) then
        task.defer(function()
            task.wait(0.15)
            pcall(apply)
        end)
    end
end)

task.spawn(function()
    while task.wait(1) do
        disableBackpack()
    end
end)

print("[CoreUI Scale V2] " .. tostring(math.floor(SCALE * 100)) .. "%")