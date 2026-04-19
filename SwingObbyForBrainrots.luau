local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local char = LocalPlayer.Character
local HRP = char:FindFirstChild("HumanoidRootPart")

local MovementConnection = nil
local MovementRunning = false

local NoDetectBox = {
    RightCornerFront = Vector3.new(293.60, -10.02, -73.48),
    RightCornerBack  = Vector3.new(293.10, -9.82, 37.96),
    LeftCornerFront  = Vector3.new(-257.40, -10.02, -73.55),
    LeftCornerBack   = Vector3.new(-256.90, -9.82, 37.96)
}

local ActiveBrainrots = game.Workspace.ActiveBrainrots

print("Total objects in ActiveBrainrots:", #ActiveBrainrots:GetChildren())

local brainrotModels = {}
local FildteredBrainrot = {}

local AutoEnabled = false
local SelectedRarities = {}

local function IsInNoDetect(pos: Vector3): boolean
    if not NoDetectBox then return false end

    local minX = math.min(NoDetectBox.LeftCornerFront.X, NoDetectBox.RightCornerFront.X)
    local maxX = math.max(NoDetectBox.LeftCornerFront.X, NoDetectBox.RightCornerFront.X)
    local minZ = math.min(NoDetectBox.LeftCornerFront.Z, NoDetectBox.RightCornerFront.Z)
    local maxZ = math.max(NoDetectBox.LeftCornerFront.Z, NoDetectBox.RightCornerFront.Z)

    return pos.X >= minX and pos.X <= maxX and pos.Z >= minZ and pos.Z <= maxZ
end

function FindBrainrots()
    brainrotModels = {}
    FildteredBrainrot = {}

    for _, child in ipairs(ActiveBrainrots:GetChildren()) do
        if child.Name == "ServerHitbox" and child:IsA("Model") then
            for _, obj in ipairs(child:GetChildren()) do
                if obj:IsA("Model") and obj.Name ~= "Attachment" then
                    table.insert(brainrotModels, obj)
                end
            end
        end
    end

    print("Total Brainrots Models Found:", #brainrotModels)

    for i, Brainrots in ipairs(brainrotModels) do
        local BrainrotRoot = Brainrots:FindFirstChild("HumanoidRootPart")
        if not BrainrotRoot then
            BrainrotRoot = Brainrots:FindFirstChildWhichIsA("BasePart")
        end

        if not BrainrotRoot then
            continue
        end

        local pos = BrainrotRoot.Position

        if IsInNoDetect(pos) then
            continue
        end
        
        local Rarity = Brainrots:GetAttribute("Rarity")
        
        if SelectedRarities[Rarity] then
            table.insert(FildteredBrainrot, Brainrots)
        end
    end

    print("FINAL FilteredBrainrot")
    print("Total Filtered Rarity Brainrots:", #FildteredBrainrot)
    if #FildteredBrainrot > 0 then
        for i, Brainrots in ipairs(FildteredBrainrot) do
            local rarity = Brainrots:GetAttribute("Rarity") or "Unknown"
            print(string.format("[%d/%d] %s  |  Rarity: %s", i, #FildteredBrainrot, Brainrots.Name, rarity))
        end
    end
end

function DisableClip()
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.CanCollide = false  
            end)
        end
    end
end

function EnableClip()
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.CanCollide = true  
            end)
        end
    end
end

function StopSmoothLikeButterMovement()
    if MovementConnection then
        MovementConnection:Disconnect()
        MovementConnection = nil
    end
    MovementRunning = false
    EnableClip()
end

function SmoothLikeButterMovement(targetModel)
    StopSmoothLikeButterMovement() 

    DisableClip()
    
    local MovementSpeed = 40

    if not HRP then 
        warn("SmoothLikeButterMovement: HRP is nil!")
        return 
    end

    local StartPos = HRP.Position
    
    local root = targetModel:FindFirstChild("HumanoidRootPart") or targetModel:FindFirstChildWhichIsA("BasePart")
    local targetPos = (root and root.Position or Vector3.new()) + Vector3.new(0, 10, 0)

    local IntialDis = (targetPos - StartPos).Magnitude
    local StartTime = tick()

    MovementRunning = true

    MovementConnection = RunService.Heartbeat:Connect(function(dt)  
        if not MovementRunning then return end 

        if not HRP then 
            StopSmoothLikeButterMovement()
            return 
        end

        local currentPos = HRP.Position
        local remainingDist = (targetPos - currentPos).Magnitude
        
        if remainingDist < 5 then
            HRP.CFrame = CFrame.new(targetPos.X, targetPos.Y, targetPos.Z)
            StopSmoothLikeButterMovement() 
            return
        end

        local timePassed = tick() - StartTime
        local t = math.min(timePassed * (MovementSpeed / IntialDis), 1)
        
        local newPos = currentPos:Lerp(targetPos, t * 1.05) 
        
        local Progress = (StartPos - currentPos).Magnitude / IntialDis
        local archHeight = 2500
        local ArchFactor = math.sin(Progress * math.pi)

        local linearY = StartPos.Y + (targetPos.Y - StartPos.Y) * Progress
        local archOffset = archHeight * ArchFactor

        newPos = Vector3.new(newPos.X, linearY + archOffset, newPos.Z)

        HRP.CFrame = CFrame.new(newPos.X, newPos.Y, newPos.Z) * (HRP.CFrame - HRP.CFrame.Position)
    end)
end

function GotoBrainrot()
    if #FildteredBrainrot > 0 then
        SmoothLikeButterMovement(FildteredBrainrot[1])
    else
        warn("No Brainrots found in with that rarity!")
    end
end

local Zones = {
	One = game.Workspace.Zones[1].Position,
	Two = game.Workspace.Zones[2].Position,
	Three = game.Workspace.Zones[3].Position,
	Four = game.Workspace.Zones[4].Position,
	Five = game.Workspace.Zones[5].Position,
	Six = game.Workspace.Zones[6].Position,
	Seven = game.Workspace.Zones[7].Position,
	Eight = game.Workspace.Zones[8].Position,
	Nine = game.Workspace.Zones[9].Position,
	Ten = game.Workspace.Zones[10].Position,
	Eleven = game.Workspace.Zones[11].Position,
	Twelve = game.Workspace.Zones[12].Position,
	Thirteen = game.Workspace.Zones[13].Position,
	Fourteen = game.Workspace.Zones[14].Position,
	Fifteen = game.Workspace.Zones[15].Position,
    }

function GotoZones()
    --Ignore for now
end

function GUI()
    UI.AddTab("SKIBIDI AUTO", function(tab)
        
        local left = tab:Section("Auto Farm", "Left")
        
        left:Combo("Move", "Movement Style", {"Instant Teleport", "SmoothLikeButter"}, 0, function(selectedIndex)
            print("Selected Move:", selectedIndex)
        end)

        left:Toggle("Auto", "Start Auto", false, function(state)
            AutoEnabled = state
            print("Auto State:", state)
            if state then
                FindBrainrots()
                GotoBrainrot()
            end
        end)

        left:Text("Rarity Filter")
        
        left:Toggle("FilterCommon", "Common", false, function(state)
            SelectedRarities["Common"] = state
        end)
        
        left:Toggle("FilterUncommon", "Uncommon", false, function(state)
            SelectedRarities["Uncommon"] = state
        end)
        
        left:Toggle("FilterRare", "Rare", false, function(state)
            SelectedRarities["Rare"] = state
        end)
        
        left:Toggle("FilterEpic", "Epic", false, function(state)
            SelectedRarities["Epic"] = state
        end)
        
        left:Toggle("FilterLegendary", "Legendary", false, function(state)
            SelectedRarities["Legendary"] = state
        end)
        
        left:Toggle("FilterMythical", "Mythical", true, function(state)
            SelectedRarities["Mythical"] = state
        end)
        
        left:Toggle("FilterSecret", "Secret", true, function(state)
            SelectedRarities["Secret"] = state
        end)

        left:Toggle("FilterGod", "God", true, function(state)
            SelectedRarities["God"] = state
        end)
        
        left:Toggle("FilterOG", "OG", true, function(state)
            SelectedRarities["OG"] = state
        end)

        left:Toggle("FilterDivine", "Divine", true, function(state)
            SelectedRarities["Divine"] = state
        end)

        left:Toggle("FilterAncient", "Ancient", true, function(state)
            SelectedRarities["Ancient"] = state
        end)

        left:Toggle("FilterClassified", "Classified", true, function(state)
            SelectedRarities["Classified"] = state
        end)

        local right = tab:Section("Teleport To Zones", "Right")
        
        right:Combo("Teleport Mode", "Movement Style", {"Instant Teleport", "SmoothLikeButter"}, 0, function(selectedIndex)
            print("Teleport Mode:", selectedIndex)
        end)
        
        right:Combo("Zone", "Select Zone", {"One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen"}, 0, function(selectedIndex)
            print("Selected Zone:", selectedIndex)
        end)
    end)
    
    notify("SKIBIDI AUTO Menu Loaded!", "Success", 4)
end

FindBrainrots()
GUI()