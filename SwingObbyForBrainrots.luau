local EncodingService = game:GetService("EncodingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local char = LocalPlayer.Character
local HRP = char:FindFirstChild("HumanoidRootPart")

local MovementConnection = nil
local MovementRunning = false

local ActiveBrainrots = game.Workspace.ActiveBrainrots

print("Total objects in ActiveBrainrots:", #ActiveBrainrots:GetChildren())

local brainrotModels = {}

function FindBrainrots()
    for _, child in ipairs(ActiveBrainrots:GetChildren()) do
        if child.Name == "ServerHitbox" and child:IsA("Model") then
            for _, obj in ipairs(child:GetChildren()) do
                if obj:IsA("Model") then
                    table.insert(brainrotModels, obj)
                end
            end
        end
    end

    print("Total Brainrots Models Found:", #brainrotModels)

    for i, Brainrots in ipairs(brainrotModels) do
        print(string.format("[%d/%d] %s", i, #brainrotModels, Brainrots.Name))

        local BrainrotRoot = Brainrots:FindFirstChild("HumanoidRootPart")
        if not BrainrotRoot then
            BrainrotRoot = Brainrots:FindFirstChildWhichIsA("BasePart")
        end

        if BrainrotRoot then
            local ok, pos = pcall(function() return BrainrotRoot.Position end)
            if ok and pos then
                print("   Position:", string.format("(%.1f, %.1f, %.1f)", pos.X, pos.Y, pos.Z))
            end
        end

        local Rarity = Brainrots:GetAttribute("Rarity")
        if Rarity then
            print(" Rarity:", Rarity)
        end
        
        local Mutation = Brainrots:GetAttribute("Mutation")
        if Mutation then
            print(" Mutation:", Mutation)
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

    local StartPos = HRP.Position
    
    local root = targetModel:FindFirstChild("HumanoidRootPart") or targetModel:FindFirstChildWhichIsA("BasePart")
    local targetPos = (root and root.Position or Vector3.new()) + Vector3.new(0, 10, 0)

    local IntialDis = (targetPos - StartPos).Magnitude
    local StartTime = tick()

    MovementRunning = true

    MovementConnection = RunService.Heartbeat:Connect(function(dt)  
        if not MovementRunning then return end 

        local currentPos = HRP.Position
        local remainingDist = (targetPos - currentPos).Magnitude
        
        if remainingDist < 1 then
            HRP.CFrame = CFrame.new(targetPos.X, targetPos.Y, targetPos.Z)
            StopSmoothLikeButterMovement() 
            return
        end

        local timePassed = tick() - StartTime
        local t = math.min(timePassed * (MovementSpeed / IntialDis), 1)
        
        local newPos = currentPos:Lerp(targetPos, t * 1.05) 
        
        -- Fixed line for Matcha
        HRP.CFrame = CFrame.new(newPos.X, newPos.Y, newPos.Z) * (HRP.CFrame - HRP.CFrame.Position)
    end)
end

--Ignore for now
function GotoBrainrot()
    if #brainrotModels > 0 then
        SmoothLikeButterMovement(brainrotModels[1])
    end
end

--Ignore for now
function GotoIslands()

end

FindBrainrots()
GotoBrainrot()