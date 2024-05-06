local AkaliNotif = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Dynissimo/main/Scripts/AkaliNotif.lua"))();
local Notify = AkaliNotif.Notify;


Notify({
Description = "Mistreat.cc";
Title = "Mistreat.cc | Loaded";
Duration = 5;
});

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Mistreat = getgenv().Mistreat
local OldSilentAimPart = Mistreat.Silent.Part
local SilentTarget, AimTarget = nil, nil
local DetectedDesync, DetectedDesyncV2, DetectedUnderGround, DetectedUnderGround2, DetectedFreeFall = false, false, false, false, false
local Script = {Functions = {}, Drawing = {}}

local Players, Client, Mouse, RS, Camera, GuiS, Uis, UserInputService = game:GetService("Players"), game:GetService("Players").LocalPlayer, game:GetService("Players").LocalPlayer:GetMouse(), game:GetService("RunService"), game:GetService("Workspace").CurrentCamera, game:GetService("GuiService"), game:GetService("UserInputService"), game:GetService("UserInputService")

Script.Drawing.SilentCircle = Drawing.new("Circle")
Script.Drawing.SilentCircle.Color = Color3.new(1, 1, 1)
Script.Drawing.SilentCircle.Thickness = 1

local function Alive(plr)
    return plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("Head") ~= nil
end

local function OnScreen(Object)
    local _, screen = Camera:WorldToScreenPoint(Object.Position)
    return screen
end

local function GetMagnitudeFromMouse(Part)
    local PartPos, OnScreen = Camera:WorldToScreenPoint(Part.Position)
    if OnScreen then
        return (Vector2.new(PartPos.X, PartPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
    end
    return math.huge
end

local function VisibleCheck(Part, PartDescendant)
    local Character = Client.Character or Client.CharacterAdded:Wait()
    local Origin = Camera.CFrame.Position
    local _, OnScreen = Camera:WorldToViewportPoint(Part.Position)

    if OnScreen then
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {Character, Camera}

        local Result = Workspace:Raycast(Origin, Part.Position - Origin, raycastParams)

        if Result then
            local PartHit = Result.Instance
            return not PartHit or PartHit:IsDescendantOf(PartDescendant)
        end
    end
    return false
end

local function GetParts(Object)
    if string.find(Object.Name, "Gun") then
        return
    end
    return table.find({"Part", "MeshPart", "BasePart"}, Object.ClassName)
end

local function FindCrew(Player)
    if Player:FindFirstChild("DataFolder") and Player.DataFolder:FindFirstChild("Information") and Player.DataFolder.Information:FindFirstChild("Crew") and Client:FindFirstChild("DataFolder") and Client.DataFolder:FindFirstChild("Information") and Client.DataFolder.Information:FindFirstChild("Crew") then
        local PlayerCrew, ClientCrew = Player.DataFolder.Information:FindFirstChild("Crew").Value, Client.DataFolder.Information:FindFirstChild("Crew").Value
        return PlayerCrew ~= nil and ClientCrew ~= nil and PlayerCrew ~= "" and ClientCrew ~= ""
    end
    return false
end

local function GetClosestBodyPart(Char)
    if not (Char and Char:IsA("Model")) then
        return nil
    end

    local Distance, ClosestPart = math.huge, nil
    local Filtered = {}

    for _, v in ipairs(Char:GetChildren()) do
        if GetParts(v) and OnScreen(v) then
            table.insert(Filtered, v)
        end
    end

    for _, Part in ipairs(Filtered) do
        local Magnitude = GetMagnitudeFromMouse(Part)
        if Magnitude < Distance then
            ClosestPart = Part
            Distance = Magnitude
        end
    end
    return ClosestPart
end

local function GetClosestPlayer()
    local Target, Closest, thresholdDistance = nil, math.huge, 100

    for _, v in ipairs(Players:GetPlayers()) do
        if v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart") then
            if not OnScreen(v.Character.HumanoidRootPart) then
            end
            if Mistreat.Checks.WallCheck and not VisibleCheck(v.Character.HumanoidRootPart, v.Character) then
            end
            if Mistreat.Checks.KoCheck and v.Character:FindFirstChild("BodyEffects") then
                local KoCheck = v.Character.BodyEffects:FindFirstChild("K.O").Value
                local Grabbed = v.Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
                if KoCheck or Grabbed then
                end
            end
            if Mistreat.Checks.VisibleCheck and v.Character:FindFirstChild("Head") then
                if v.Character.Head.Transparency > 0.5 then 
                end
            end
            if Mistreat.Checks.CrewCheck and FindCrew(v) and v.DataFolder.Information:FindFirstChild("Crew").Value == Client.DataFolder.Information:FindFirstChild("Crew").Value then
            end
            local Position = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            local Distance = ((Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Position.X, Position.Y)).Magnitude) * 0.6
            if Distance < Closest and Script.Drawing.SilentCircle.Radius > Distance and Distance < thresholdDistance then
                Closest = Distance
                Target = v
            end
        end
    end

    SilentTarget = Target
end

local OldIndex = nil
OldIndex = hookmetamethod(game, "__index", function(self, Index)
    if not checkcaller() and Mouse and self == Mouse and Index == "Hit" and Mistreat.Silent.Enabled and Mistreat.AntiAimViewer.AntiAimViewer and not Mistreat.PanicMode.Enabled then
        if Alive(SilentTarget) and Players[tostring(SilentTarget)].Character:FindFirstChild(Mistreat.Silent.Part) then
            local EndPoint = nil
            local TargetPos = Players[tostring(SilentTarget)].Character[Mistreat.Silent.Part].CFrame
            local TargetVel = Players[tostring(SilentTarget)].Character.HumanoidRootPart.Velocity
            local TargetMov = Players[tostring(SilentTarget)].Character.Humanoid.MoveDirection

            if Mistreat.Resolver.Desync then
                local Magnitude = TargetVel.Magnitude
                local Magnitude2 = TargetMov.Magnitude
                DetectedDesync = Magnitude > 86 or (Magnitude < 1 and Magnitude2 > 0.01) or (Magnitude > 5 and Magnitude2 < 0.01)
            end

            if Mistreat.Checks.AntiGroundShots then
                DetectedFreeFall = TargetVel.Y < -20
            end

            if Mistreat.Resolver.UndergroundAA then
                DetectedUnderGround = TargetVel.Y < -30
            end

            if TargetPos ~= nil then
                if DetectedDesync then
                    local MoveDirection = TargetMov * 16
                    EndPoint = TargetPos + (MoveDirection * Mistreat.Silent.PredictionVelocity)
                elseif DetectedUnderGround then
                    EndPoint = TargetPos + (Vector3.new(TargetVel.X, 0, TargetVel.Z) * Mistreat.Silent.PredictionVelocity)
                elseif DetectedFreeFall then
                    EndPoint = TargetPos + (Vector3.new(TargetVel.X, TargetVel.Y * 0.5, TargetVel.Z) * Mistreat.Silent.PredictionVelocity)
                elseif Mistreat.Silent.PredictMovement then
                    EndPoint = TargetPos + (Vector3.new(TargetVel.X, TargetVel.Y * 0.5, TargetVel.Z) * Mistreat.Silent.PredictionVelocity)
                else
                    EndPoint = TargetPos
                end
            end

            if EndPoint ~= nil then
                return (Index == "Hit" and EndPoint)
            end
        end
    end
    return OldIndex(self, Index)
end)

local function SilentMisc()
    if Mistreat.Silent.Enabled then
        if Alive(SilentTarget) then
            if Mistreat.Silent.UseAirPart then
                if SilentTarget.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                    Mistreat.Silent.Part = Mistreat.Silent.AirPart
                else
                    Mistreat.Silent.Part = OldSilentAimPart
                end
            end
        end
    end
end

local function UpdateFOV()
    if not Script.Drawing.SilentCircle then
        return Script.Drawing.SilentCircle
    end
    Script.Drawing.SilentCircle.Visible = Mistreat.SilentFOV.Visible
    Script.Drawing.SilentCircle.Color = Mistreat.SilentFOV.Color
    Script.Drawing.SilentCircle.Filled = Mistreat.SilentFOV.Filled
    Script.Drawing.SilentCircle.Transparency = Mistreat.SilentFOV.Transparency
    Script.Drawing.SilentCircle.Position = Vector2.new(Mouse.X, Mouse.Y + GuiS:GetGuiInset().Y)
    Script.Drawing.SilentCircle.Radius = Mistreat.SilentFOV.Radius * 3
end

local function HandlePanicModeKeybind(input, gameProcessedEvent)
    if not gameProcessedEvent then
        if input.KeyCode == Enum.KeyCode[Mistreat.PanicMode.Key] then
            Mistreat.PanicMode.Enabled = not Mistreat.PanicMode.Enabled
        end
    end
end

UserInputService.InputBegan:Connect(HandlePanicModeKeybind)

RS.Heartbeat:Connect(function()
    if not Mistreat.PanicMode.Enabled then
        GetClosestPlayer()
        SilentMisc()
    end
end)

RS.RenderStepped:Connect(function()
    if not Mistreat.PanicMode.Enabled then
        UpdateFOV()
        if Mistreat.Silent.Enabled and Alive(AimTarget) and Mistreat.Silent.ClosestPart and Alive(SilentTarget) then
            local currentpart = tostring(GetClosestBodyPart(AimTarget.Character))
            if Mistreat.Silent.ClosestPart then
                Mistreat.Silent.Part = currentpart
                OldSilentAimPart = Mistreat.Silent.Part
            end
            return
        end
        if Mistreat.Silent.Enabled then
            if Mistreat.Silent.ClosestPart and Alive(SilentTarget) then
                Mistreat.Silent.Part = tostring(GetClosestBodyPart(SilentTarget.Character))
                OldSilentAimPart = Mistreat.Silent.Part
            end
        end
    end
end)

local Locking = false
local OldAimPart = Mistreat.Camlock.Part
local ClosestPart = nil

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent then
        if input.KeyCode == Enum.KeyCode[Mistreat.Camlock.Key] then
            Locking = not Locking
            if Locking then
                Plr, ClosestPart = getClosestPlayerToCursor()
            elseif not Locking then
                if Plr then
                    Plr = nil
                    ClosestPart = nil
                end
            end
        end
    end
end)

function getClosestPlayerToCursor()
    local closestDist = math.huge
    local closestPlr = nil
    local closestPart = nil
    for _, v in next, Players:GetPlayers() do
        pcall(function()
            local notKO = v.Character:WaitForChild("BodyEffects")["K.O"].Value ~= true
            local notGrabbed = v.Character:FindFirstChild("GRABBING_CONSTRAINT") == nil
            if v ~= Client and v.Character and v.Character.Humanoid.Health > 0 and notKO and notGrabbed then
                local screenPos, cameraVisible = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
                if cameraVisible then
                    local distToMouse = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if distToMouse < closestDist then
                        closestPlr = v
                        closestDist = distToMouse
                        if Mistreat.Camlock.ClosestPart then
                            closestPart = GetClosestBodyPart(v.Character)
                        else
                            closestPart = v.Character[Mistreat.Camlock.Part]
                        end
                    end
                end
            end
        end)
    end
    return closestPlr, closestPart
end

local rawmetatable = getrawmetatable(game)
local old = rawmetatable.__namecall
setreadonly(rawmetatable, false)
rawmetatable.__namecall = newcclosure(function(...)
    local args = {...}
    if Plr ~= nil and getnamecallmethod() == "FireServer" and args[2] == "UpdateMousePos" then
        args[3] = Plr.Character[Mistreat.Camlock.Part].Position + (Plr.Character[Mistreat.Camlock.Part].Velocity * Mistreat.Camlock.Prediction)
        return old(unpack(args))
    end
    return old(...)
end)

RS.RenderStepped:Connect(function()
    if not Mistreat.PanicMode.Enabled then
        if Plr ~= nil then
            local Main
            if Plr.Character.Humanoid.FloorMaterial == Enum.Material.Air then
                Main = CFrame.new(Camera.CFrame.p, Plr.Character[Mistreat.Camlock.JumpPart].Position + Plr.Character[Mistreat.Camlock.JumpPart].Velocity * Mistreat.Camlock.Prediction)
            else
                if Mistreat.Camlock.ClosestPart then
                    closestPart = GetClosestBodyPart(Plr.Character)
                    Main = CFrame.new(Camera.CFrame.p, Plr.Character[Mistreat.Camlock.JumpPart].Position + Plr.Character[Mistreat.Camlock.JumpPart].Velocity * Mistreat.Camlock.Prediction)
                else
                    Main = CFrame.new(Camera.CFrame.p, Plr.Character[Mistreat.Camlock.Part].Position + Plr.Character[Mistreat.Camlock.Part].Velocity * Mistreat.Camlock.Prediction)
                end
            end
            Camera.CFrame = Camera.CFrame:Lerp(Main, Mistreat.Camlock.SmoothingValue, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut)
        end

        if Mistreat.Camlock.CheckIfKo and Plr and Plr.Character then
            local KOd = Plr.Character:WaitForChild("BodyEffects")["K.O"].Value
            local Grabbed = Plr.Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
            if Plr.Character.Humanoid.Health < 1 or KOd or Grabbed then
                if Locking then
                    Plr = nil
                    Locking = false
                end
            end
        end

        if Mistreat.Camlock.DisableOnTargetDeath and Plr and Plr.Character:FindFirstChild("Humanoid") then
            if Plr.Character.Humanoid.Health < 1 then
                if Locking then
                    Plr = nil
                    Locking = false
                end
            end
        end

        if Mistreat.Camlock.DisableOnPlayerDeath and Client.Character and Client.Character:FindFirstChild("Humanoid") and Client.Character.Humanoid.Health < 1 then
            if Locking then
                Plr = nil
                Locking = false
            end
        end
    end
end)