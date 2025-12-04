-- Sima FreeCam - Simplified Version
local cam = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local player = game.Players.LocalPlayer

-- Počkej na načtení
repeat wait() until game:IsLoaded()
repeat wait() until player.Character

-- Vytvoř jednoduché GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleFreeCam"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 160, 0, 45)
MainFrame.Position = UDim2.new(0.5, -80, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

-- Tlačítko přepínače
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 120, 0, 35)
ToggleBtn.Position = UDim2.new(0.5, -60, 0.5, -17.5)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleBtn.Text = "FreeCam: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 4)
BtnCorner.Parent = ToggleBtn

-- Tlačítko zavření
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.white
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 12)
CloseCorner.Parent = CloseBtn

-- Přidání do GUI
CloseBtn.Parent = MainFrame
ToggleBtn.Parent = MainFrame
MainFrame.Parent = ScreenGui
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Loading indicator (bude se krátce zobrazit při startu)
local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 1, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "Loading Sima FreeCam..."
LoadingText.TextColor3 = Color3.fromRGB(100, 200, 255)
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextSize = 14
LoadingText.Visible = false
LoadingText.Parent = MainFrame

-- Zobraz loading na 1.5 sekundy
LoadingText.Visible = true
ToggleBtn.Visible = false
CloseBtn.Visible = false
wait(1.5)
LoadingText.Visible = false
ToggleBtn.Visible = true
CloseBtn.Visible = true

-- Freecam proměnné
local freecamEnabled = false
local char = player.Character
local humanoid = char:FindFirstChild("Humanoid")
local savedWalkSpeed = humanoid and humanoid.WalkSpeed or 16
local savedJumpPower = humanoid and humanoid.JumpPower or 50

-- Klávesy pro pohyb
local keysDown = {
    W = false,
    A = false,
    S = false,
    D = false,
    Space = false,
    Q = false,
    E = false
}

local rotating = false
local speed = 0.3
local sens = 0.3

-- Funkce pro freecam
local function enableFreecam()
    freecamEnabled = true
    cam.CameraType = Enum.CameraType.Scriptable
    
    -- Zastav postavu
    if humanoid and humanoid.Parent then
        savedWalkSpeed = humanoid.WalkSpeed
        savedJumpPower = humanoid.JumpPower
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    end
    
    -- Update GUI
    ToggleBtn.Text = "FreeCam: ON"
    ToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
end

local function disableFreecam()
    freecamEnabled = false
    cam.CameraType = Enum.CameraType.Custom
    
    -- Obnov pohyb postavy
    if humanoid and humanoid.Parent then
        humanoid.WalkSpeed = savedWalkSpeed
        humanoid.JumpPower = savedJumpPower
    end
    
    -- Reset ovládání
    rotating = false
    for key in pairs(keysDown) do
        keysDown[key] = false
    end
    
    -- Update GUI
    ToggleBtn.Text = "FreeCam: OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end

local function toggleFreecam()
    if freecamEnabled then
        disableFreecam()
    else
        enableFreecam()
    end
end

-- Tlačítko přepínače
ToggleBtn.MouseButton1Click:Connect(toggleFreecam)

-- Tlačítko zavření
CloseBtn.MouseButton1Click:Connect(function()
    if freecamEnabled then
        disableFreecam()
    end
    ScreenGui:Destroy()
end)

-- Render loop (jednodušší verze)
local connection
connection = RS.RenderStepped:Connect(function(delta)
    if not freecamEnabled then return end
    
    -- Otáčení kamery
    if rotating then
        local mouseDelta = UIS:GetMouseDelta()
        local cf = cam.CFrame
        
        -- Omezení vertikální rotace
        local look = cf.LookVector
        local currentPitch = math.asin(-look.Y)
        local maxPitch = math.rad(85)
        local newPitch = currentPitch - math.rad(mouseDelta.Y) * sens
        
        if newPitch > maxPitch then newPitch = maxPitch end
        if newPitch < -maxPitch then newPitch = -maxPitch end
        
        -- Aplikuj rotaci
        cf = CFrame.new(cf.Position) *
             CFrame.Angles(0, -math.rad(mouseDelta.X) * sens, 0) *
             CFrame.Angles(newPitch - currentPitch, 0, 0)
        
        cam.CFrame = cf
        UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    else
        UIS.MouseBehavior = Enum.MouseBehavior.Default
    end
    
    -- Pohyb kamery
    local moveSpeed = speed
    if keysDown.E then
        moveSpeed = speed * 2
    end
    
    if keysDown.W then
        cam.CFrame = cam.CFrame + cam.CFrame.LookVector * moveSpeed
    end
    if keysDown.S then
        cam.CFrame = cam.CFrame - cam.CFrame.LookVector * moveSpeed
    end
    if keysDown.A then
        cam.CFrame = cam.CFrame - cam.CFrame.RightVector * moveSpeed
    end
    if keysDown.D then
        cam.CFrame = cam.CFrame + cam.CFrame.RightVector * moveSpeed
    end
    if keysDown.Space then
        cam.CFrame = cam.CFrame + Vector3.new(0, moveSpeed, 0)
    end
    if keysDown.Q then
        cam.CFrame = cam.CFrame - Vector3.new(0, moveSpeed, 0)
    end
end)

-- Ovládání kláves
UIS.InputBegan:Connect(function(input)
    -- Přepni freecam klávesou O
    if input.KeyCode == Enum.KeyCode.O then
        toggleFreecam()
        return
    end
    
    -- Pohybové klávesy
    if freecamEnabled then
        if input.KeyCode == Enum.KeyCode.W then
            keysDown.W = true
        elseif input.KeyCode == Enum.KeyCode.A then
            keysDown.A = true
        elseif input.KeyCode == Enum.KeyCode.S then
            keysDown.S = true
        elseif input.KeyCode == Enum.KeyCode.D then
            keysDown.D = true
        elseif input.KeyCode == Enum.KeyCode.Space then
            keysDown.Space = true
        elseif input.KeyCode == Enum.KeyCode.Q then
            keysDown.Q = true
        elseif input.KeyCode == Enum.KeyCode.E then
            keysDown.E = true
        elseif input.KeyCode == Enum.KeyCode.LeftControl then
            keysDown.Q = true
        end
    end
    
    -- Otáčení myší
    if freecamEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
        rotating = true
    end
end)

UIS.InputEnded:Connect(function(input)
    -- Pohybové klávesy
    if input.KeyCode == Enum.KeyCode.W then
        keysDown.W = false
    elseif input.KeyCode == Enum.KeyCode.A then
        keysDown.A = false
    elseif input.KeyCode == Enum.KeyCode.S then
        keysDown.S = false
    elseif input.KeyCode == Enum.KeyCode.D then
        keysDown.D = false
    elseif input.KeyCode == Enum.KeyCode.Space then
        keysDown.Space = false
    elseif input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.LeftControl then
        keysDown.Q = false
    elseif input.KeyCode == Enum.KeyCode.E then
        keysDown.E = false
    end
    
    -- Otáčení myší
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rotating = false
    end
end)

-- Zpracování respawnu
player.CharacterAdded:Connect(function(newChar)
    wait(0.5) -- Krátká pauza
    char = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    
    if freecamEnabled then
        -- Znovu aplikuj freecam nastavení
        savedWalkSpeed = humanoid.WalkSpeed
        savedJumpPower = humanoid.JumpPower
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    end
end)

-- Efekty hoveru
ToggleBtn.MouseEnter:Connect(function()
    if ToggleBtn then
        ToggleBtn.BackgroundColor3 = freecamEnabled and Color3.fromRGB(50, 90, 50) or Color3.fromRGB(70, 70, 70)
    end
end)

ToggleBtn.MouseLeave:Connect(function()
    if ToggleBtn then
        ToggleBtn.BackgroundColor3 = freecamEnabled and Color3.fromRGB(40, 80, 40) or Color3.fromRGB(60, 60, 60)
    end
end)

CloseBtn.MouseEnter:Connect(function()
    if CloseBtn then
        CloseBtn.BackgroundColor3 = Color3.fromRGB(240, 70, 70)
    end
end)

CloseBtn.MouseLeave:Connect(function()
    if CloseBtn then
        CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    end
end)

print("✅ Sima FreeCam loaded!")
print("📌 Controls:")
print("• Click button or press O to toggle FreeCam")
print("• WASD: Move camera")
print("• Space/Q: Move up/down")
print("• Right click: Look around")
print("• E: Speed boost")
print("• X: Close GUI")
