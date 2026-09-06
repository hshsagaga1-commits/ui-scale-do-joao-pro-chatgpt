local URL="https://raw.githubusercontent.com/panchooo677/Nynyn-/refs/heads/main/README.md"
local src=game:HttpGet(URL)

local function rep(old,new,name)
    local a,b=string.find(src,old,1,true)
    if not a then
        error("Patch failed: "..name)
    end
    src=string.sub(src,1,a-1)..new..string.sub(src,b+1)
end

rep(
[[    return keyStr .. trait
end]],
[[    if obj:IsDescendantOf(CoreGui) then
        keyStr = "CORE_" .. keyStr
    end
    return keyStr .. trait
end]],
"key"
)

rep(
[[local function ScanSingleObject(obj)
    if obj:IsA("GuiObject") and not obj:IsDescendantOf(TargetParent) then
        local key = GetKey(obj)
        if RuleMap[key] then KnownTrackedObjects[obj] = key end
    end
end

local function ForceScanUI()
    pcall(function()
        for _, obj in ipairs(PlayerGui:GetDescendants()) do
            ScanSingleObject(obj)
        end
    end)
end

local descAddedConn = PlayerGui.DescendantAdded:Connect(function(obj)
    if not next(RuleMap) then return end
    task.defer(function() ScanSingleObject(obj) end)
end)
table.insert(Connections, descAddedConn)]],
[[local function IsEditorObject(obj)
    local current=obj
    while current do
        if current.Name=="PerfectUIManager_UI" or current.Name=="PerfectUIManager_Shield" then
            return true
        end
        current=current.Parent
    end
    return false
end

local function ScanSingleObject(obj)
    if obj:IsA("GuiObject") and not IsEditorObject(obj) then
        local key=GetKey(obj)
        if RuleMap[key] then
            KnownTrackedObjects[obj]=key
        end
    end
end

local function ForceScanUI()
    pcall(function()
        for _,obj in ipairs(PlayerGui:GetDescendants()) do
            ScanSingleObject(obj)
        end
        for _,obj in ipairs(CoreGui:GetDescendants()) do
            ScanSingleObject(obj)
        end
    end)
end

local descAddedConn=PlayerGui.DescendantAdded:Connect(function(obj)
    if not next(RuleMap) then return end
    task.defer(function()
        ScanSingleObject(obj)
    end)
end)
table.insert(Connections,descAddedConn)

local coreDescAddedConn=CoreGui.DescendantAdded:Connect(function(obj)
    if not next(RuleMap) then return end
    task.defer(function()
        ScanSingleObject(obj)
    end)
end)
table.insert(Connections,coreDescAddedConn)]],
"scanner"
)

local helperMarker=[[
-- ==========================================
-- 60FPS RENDER LOOP (Zero Lag version)
-- ==========================================]]

local helpers=[[
local CORE_SCALE_TAG="__PerfectUI_CoreScale"

local function EnsureCoreScale(obj)
    if not obj or not obj:IsA("GuiObject") then
        return nil
    end
    local s=obj:FindFirstChild(CORE_SCALE_TAG)
    if not s then
        s=Instance.new("UIScale")
        s.Name=CORE_SCALE_TAG
        s.Scale=1
        s.Parent=obj
    end
    return s
end

local function GetCoreScale(obj)
    local s=obj and obj:FindFirstChild(CORE_SCALE_TAG)
    return s and s.Scale or 1
end

local function FindCoreAncestor(obj,name)
    local current=obj
    while current and current~=CoreGui do
        if current.Name==name then
            return current
        end
        current=current.Parent
    end
    return nil
end

local function HasUILayout(parent)
    if not parent then return false end
    return parent:FindFirstChildWhichIsA("UIListLayout")
        or parent:FindFirstChildWhichIsA("UIGridLayout")
        or parent:FindFirstChildWhichIsA("UITableLayout")
        or parent:FindFirstChildWhichIsA("UIPageLayout")
end

local function NormalizeCoreTarget(obj)
    if not obj or not obj:IsA("GuiObject") then
        return obj
    end

    local holder=FindCoreAncestor(obj,"MenuIconHolder")
    if holder and holder:IsA("GuiObject") then
        pcall(function()
            holder.ClipsDescendants=false
        end)
        local trigger=holder:FindFirstChild("TriggerPoint")
        if trigger and trigger:IsA("GuiObject") then
            pcall(function()
                trigger.ClipsDescendants=false
            end)
            local hit=trigger:FindFirstChild("IconHitArea")
            if hit and hit:IsA("GuiObject") then
                return hit
            end
        end
        return holder
    end

    local unibar=FindCoreAncestor(obj,"UnibarMenu")
    if unibar and unibar:IsA("GuiObject") then
        return unibar
    end

    local target=obj
    local guard=0
    while target
        and target.Parent
        and target.Parent:IsA("GuiObject")
        and HasUILayout(target.Parent)
        and guard<8 do
        target=target.Parent
        guard=guard+1
    end
    return target
end

local function AddGuiResults(out,seen,root,x,y)
    local ok,list=pcall(function()
        return root:GetGuiObjectsAtPosition(x,y)
    end)
    if ok and type(list)=="table" then
        for _,gui in ipairs(list) do
            if gui:IsA("GuiObject")
                and not gui:IsDescendantOf(EditorGui)
                and not gui:IsDescendantOf(ShieldGui)
                and not seen[gui] then
                seen[gui]=true
                table.insert(out,gui)
            end
        end
        return true
    end
    return false
end

local function GetAllGuiObjectsAtPosition(x,y)
    local out={}
    local seen={}

    local gotCore=AddGuiResults(out,seen,CoreGui,x,y)

    if not gotCore then
        local fallback={}
        for _,gui in ipairs(CoreGui:GetDescendants()) do
            if gui:IsA("GuiObject")
                and gui.Visible
                and not gui:IsDescendantOf(EditorGui)
                and not gui:IsDescendantOf(ShieldGui) then
                local p=gui.AbsolutePosition
                local s=gui.AbsoluteSize
                if s.X>0 and s.Y>0
                    and x>=p.X and x<=p.X+s.X
                    and y>=p.Y and y<=p.Y+s.Y then
                    table.insert(fallback,gui)
                end
            end
        end
        table.sort(fallback,function(a,b)
            if a.ZIndex==b.ZIndex then
                return #a:GetFullName()>#b:GetFullName()
            end
            return a.ZIndex>b.ZIndex
        end)
        for _,gui in ipairs(fallback) do
            if not seen[gui] then
                seen[gui]=true
                table.insert(out,gui)
            end
        end
    end

    AddGuiResults(out,seen,PlayerGui,x,y)

    return out
end

]]

rep(helperMarker,helpers..helperMarker,"helpers")

rep(
[[                    local layout = parent:FindFirstChildWhichIsA("UILayout") or parent:FindFirstChildWhichIsA("UIGridStyleLayout")
                    if layout then]],
[[                    local layout = parent:FindFirstChildWhichIsA("UILayout") or parent:FindFirstChildWhichIsA("UIGridStyleLayout")
                    if layout and not obj:IsDescendantOf(CoreGui) then]],
"layout"
)

rep(
[[                    if obj.Position ~= rule.Position then obj.Position = rule.Position end
                    if rule.SizeModified and obj.Size ~= rule.Size then obj.Size = rule.Size end]],
[[                    if obj.Position ~= rule.Position then obj.Position = rule.Position end
                    if obj:IsDescendantOf(CoreGui) and rule.CoreScale then
                        local coreScale=EnsureCoreScale(obj)
                        if coreScale and coreScale.Scale~=rule.CoreScale then
                            coreScale.Scale=rule.CoreScale
                        end
                    elseif rule.SizeModified and obj.Size ~= rule.Size then
                        obj.Size = rule.Size
                    end]],
"enforce"
)

rep(
[[                Size = UDim2.new(unpack(savedData.Size)),
                SizeModified = savedData.SizeModified or false ]],
[[                Size = UDim2.new(unpack(savedData.Size)),
                SizeModified = savedData.SizeModified or false,
                CoreScale = savedData.CoreScale ]],
"load-core-scale"
)

rep(
[[                            if OriginalSizes[key] then
                                obj.Size = OriginalSizes[key]
                            end
                        end
                        KnownTrackedObjects[obj] = nil]],
[[                            if OriginalSizes[key] then
                                obj.Size = OriginalSizes[key]
                            end
                            local coreScale=obj:FindFirstChild(CORE_SCALE_TAG)
                            if coreScale then
                                coreScale:Destroy()
                            end
                        end
                        KnownTrackedObjects[obj] = nil]],
"restore-core-scale"
)

local oldModify=[[
local function ModifySize(increment)
    if SelectedElement and #SelectedCluster > 0 then
        for _, el in ipairs(SelectedCluster) do
            local key = GetKey(el)

            local currentVisualSize = el.Size
            if currentVisualSize == UDim2.new(0,0,0,0) then
                currentVisualSize = UDim2.new(0, el.AbsoluteSize.X, 0, el.AbsoluteSize.Y)
            end

            if not RuleMap[key] then 
                RuleMap[key] = { Name = el.Name, IsDeleted = false, Position = GetSafeVisualPosition(el), Size = currentVisualSize, SizeModified = false } 
            end

            RuleMap[key].SizeModified = true 
            local s = RuleMap[key].Size
            local newSize = UDim2.new(s.X.Scale, s.X.Offset + increment, s.Y.Scale, s.Y.Offset + increment)
            RuleMap[key].Size = newSize
            el.Size = newSize
        end
    end
end]]

local newModify=[[
local function ModifySize(increment)
    if SelectedElement and #SelectedCluster>0 then
        for _,el in ipairs(SelectedCluster) do
            local key=GetKey(el)
            local currentVisualSize=el.Size
            if currentVisualSize==UDim2.new(0,0,0,0) then
                currentVisualSize=UDim2.new(0,el.AbsoluteSize.X,0,el.AbsoluteSize.Y)
            end

            if not RuleMap[key] then
                RuleMap[key]={
                    Name=el.Name,
                    IsDeleted=false,
                    Position=GetSafeVisualPosition(el),
                    Size=currentVisualSize,
                    SizeModified=false
                }
            end

            if el:IsDescendantOf(CoreGui) then
                local s=EnsureCoreScale(el)
                if s then
                    local step=increment>0 and 0.05 or -0.05
                    s.Scale=math.clamp(s.Scale+step,0.25,2.5)
                    RuleMap[key].CoreScale=s.Scale
                    RuleMap[key].SizeModified=false
                end
            else
                RuleMap[key].SizeModified=true
                local s=RuleMap[key].Size
                local newSize=UDim2.new(
                    s.X.Scale,
                    s.X.Offset+increment,
                    s.Y.Scale,
                    s.Y.Offset+increment
                )
                RuleMap[key].Size=newSize
                el.Size=newSize
            end
        end
    end
end]]

rep(oldModify,newModify,"modify-size")

rep(
[[                SizeModified = rule.SizeModified or false
            }]],
[[                SizeModified = rule.SizeModified or false,
                CoreScale = rule.CoreScale
            }]],
"save-core-scale"
)

rep(
[[        local success, elementsAtTap = pcall(function() return PlayerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y) end)
        local validElement = nil
        if success and elementsAtTap then validElement = GetPerfectTarget(elementsAtTap, game.Workspace.CurrentCamera.ViewportSize) end]],
[[        local success,elementsAtTap=pcall(function()
            return GetAllGuiObjectsAtPosition(input.Position.X,input.Position.Y)
        end)
        local validElement=nil
        if success and elementsAtTap then
            validElement=GetPerfectTarget(elementsAtTap,game.Workspace.CurrentCamera.ViewportSize)
        end
        if validElement and validElement:IsDescendantOf(CoreGui) then
            validElement=NormalizeCoreTarget(validElement)
        end]],
"tap"
)

rep(
[[            SelectedElement = validElement
            SelectedCluster = GetCluster(validElement) ]],
[[            SelectedElement=validElement
            if validElement:IsDescendantOf(CoreGui) then
                SelectedCluster={validElement}
            else
                SelectedCluster=GetCluster(validElement)
            end ]],
"cluster"
)

local fn,err=loadstring(src)
if not fn then
    error(err)
end
fn()
