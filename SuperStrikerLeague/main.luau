if _G.SSL_UniversalConnections then
    for _, connection in ipairs(_G.SSL_UniversalConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
end
_G.SSL_UniversalConnections = {}

if _G.SSL_RayfieldWindow then
    pcall(function() _G.SSL_RayfieldWindow:Destroy() end)
end

local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("Failed to load interface provider!")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local State = {
    MovementOptimization = false,
    VelocityScaling = 16,
    CollisionBypass = false,
    VisualHighlights = false,
}

local Character, RootPart, Humanoid

local function UpdateCharacter(char)
    Character = char
    RootPart = char:WaitForChild("HumanoidRootPart", 5)
    Humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
end

if LocalPlayer.Character then
    UpdateCharacter(LocalPlayer.Character)
end

local charConn = LocalPlayer.CharacterAdded:Connect(UpdateCharacter)
table.insert(_G.SSL_UniversalConnections, charConn)

local function GetRoot()
    if RootPart and RootPart.Parent then
        return RootPart
    end
    local char = LocalPlayer.Character
    RootPart = char and char:FindFirstChild("HumanoidRootPart")
    return RootPart
end

local function GetHumanoid()
    if Humanoid and Humanoid.Parent then
        return Humanoid
    end
    local char = LocalPlayer.Character
    Humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
    return Humanoid
end

local function RemoveHighlights()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChildOfClass("Highlight")
            if highlight then
                pcall(function() highlight:Destroy() end)
            end
        end
    end
end

local function HighlightPlayer(player)
    if player == LocalPlayer then return end
    local function CreateHighlight(char)
        if not State.VisualHighlights then return end
        local highlight = char:FindFirstChildOfClass("Highlight")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 60, 60)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = char
        end
    end
    if player.Character then
        CreateHighlight(player.Character)
    end
    local conn = player.CharacterAdded:Connect(CreateHighlight)
    table.insert(_G.SSL_UniversalConnections, conn)
end

local Window = Rayfield:CreateWindow({
    Name = "Universal Utility Suite",
    LoadingTitle = "Universal Optimization",
    LoadingSubtitle = "by github.com/tosubmit",
    Theme = "Default",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false,
})

_G.SSL_RayfieldWindow = Window

local MovementTab = Window:CreateTab("Movement", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

MovementTab:CreateToggle({
    Name = "Velocity Optimization",
    CurrentValue = false,
    Callback = function(Value)
        State.MovementOptimization = Value
    end,
})

MovementTab:CreateSlider({
    Name = "Velocity Scaling",
    Range = {16, 150},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        State.VelocityScaling = Value
    end,
})

MovementTab:CreateToggle({
    Name = "Collision Bypass",
    CurrentValue = false,
    Callback = function(Value)
        State.CollisionBypass = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "Perception Highlights",
    CurrentValue = false,
    Callback = function(Value)
        State.VisualHighlights = Value
        if Value then
            for _, player in ipairs(Players:GetPlayers()) do
                HighlightPlayer(player)
            end
        else
            RemoveHighlights()
        end
    end,
})

local steppedConn = RunService.Stepped:Connect(function()
    if State.CollisionBypass then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)
table.insert(_G.SSL_UniversalConnections, steppedConn)

local heartbeatConn = RunService.Heartbeat:Connect(function()
    if State.MovementOptimization then
        local root = GetRoot() or RootPart
        local hum = GetHumanoid() or Humanoid
        if root and hum and hum.MoveDirection.Magnitude > 0 then
            root.AssemblyLinearVelocity = Vector3.new(
                hum.MoveDirection.X * State.VelocityScaling,
                root.AssemblyLinearVelocity.Y,
                hum.MoveDirection.Z * State.VelocityScaling
            )
        end
    end
end)
table.insert(_G.SSL_UniversalConnections, heartbeatConn)

local playerAddedConn = Players.PlayerAdded:Connect(function(player)
    if State.VisualHighlights then
        HighlightPlayer(player)
    end
end)
table.insert(_G.SSL_UniversalConnections, playerAddedConn)
