local cam = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local onMobile = not UIS.KeyboardEnabled
local keysDown = {}
local rotating = false

-- Počkej na načtení hry
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

-- Počkej na hráče
local player = game.Players.LocalPlayer
while not player do
    wait()
    player = game.Players.LocalPlayer
end

-- Vytvoření GUI
local PlayerGui = player:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FreeCamGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Hlavní kontejner
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 180, 0, 60)
MainFrame.Position = UDim2.new(0.5, -90, 0.05, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Frame pro přepínač
local ToggleFrame = Instance.new("Frame")
ToggleFrame.Name = "ToggleFrame"
ToggleFrame.Size = UDim2.new(1, 0, 1, 0)
ToggleFrame.BackgroundTransparency = 1
ToggleFrame.Visible = true

-- Tlačítko pro přepínání
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 140, 0, 40)
ToggleButton.Position = UDim2.new(0.5, -70, 0.5, -20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleButton.Text = "FreeCam: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.AutoButtonColor = false

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = ToggleButton

-- Tlačítko pro zavření
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.AutoButtonColor = false

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 15)
CloseCorner.Parent = CloseButton

-- Frame pro loading
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundTransparency = 1
LoadingFrame.Visible = false

-- Loading text
local LoadingText = Instance.new("TextLabel")
LoadingText.Name = "LoadingText"
LoadingText.Size = UDim2.new(1, -20, 1, 0)
LoadingText.Position = UDim2.new(0, 10, 0, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "Loading Sima FreeCam..."
LoadingText.TextColor3 = Color3.fromRGB(100, 200, 255)
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextSize = 16
LoadingText.TextXAlignment = Enum.TextXAlignment.Left

-- Animované tečky
local DotsFrame = Instance.new("Frame")
DotsFrame.Name = "DotsFrame"
DotsFrame.Size = UDim2.new(0, 40, 0, 10)
DotsFrame.Position = UDim2.new(1, -50, 0.5, -5)
DotsFrame.BackgroundTransparency = 1

local dots = {}
for i = 1, 3 do
    local dot = Instance.new("Frame")
    dot.Name = "Dot"..i
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0, (i-1)*12, 0, 0)
    dot.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    dot.BorderSizePixel = 0
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0, 4)
    dotCorner.Parent = dot
    
    table.insert(dots, dot)
    dot.Parent = DotsFrame
end

-- Sestavení GUI
DotsFrame.Parent = LoadingFrame
LoadingText.Parent = LoadingFrame
CloseButton.Parent = ToggleFrame
ToggleButton.Parent = ToggleFrame
ToggleFrame.Parent = MainFrame
LoadingFrame.Parent = MainFrame
MainFrame.Parent = ScreenGui
ScreenGui.Parent = PlayerGui

-- Animace loading teček
local loadingAnimationActive = false

local function animateLoading()
    if loadingAnimationActive then return end
    loadingAnimationActive = true
    
    while LoadingFrame.Visible and LoadingFrame.Parent do
        for i, dot in ipairs(dots) do
            local tween = TweenService:Create(dot, TweenInfo.new(0.4), {
                BackgroundTransparency = 0,
                Size = UDim2.new(0, 10, 0, 10)
            })
            tween:Play()
            wait(0.2)
            
            local tween2 = TweenService:Create(dot, TweenInfo.new(0.4), {
                BackgroundTransparency = 0.5,
                Size = UDim2.new(0, 8, 0, 8)
            })
            tween2:Play()
        end
        wait(0.2)
    end
    
    loadingAnimationActive = false
end

-- Zobrazení loading screenu
local function showLoading()
    if not LoadingFrame or not LoadingFrame.Parent then return end
    
    ToggleFrame.Visible = false
    LoadingFrame.Visible = true
    
    -- Spustit animaci
    task.spawn(animateLoading)
    
    -- Simulace načítání
    wait(2)
    
    -- Skrýt loading a ukázat toggle
    if LoadingFrame and LoadingFrame.Parent then
        LoadingFrame.Visible = false
        ToggleFrame.Visible = true
    end
end

-- Funkce pro tlačítko zavření
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Efekty při hoveru
ToggleButton.MouseEnter:Connect(function()
    if ToggleButton then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end
end)

ToggleButton.MouseLeave:Connect(function()
    if ToggleButton then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

CloseButton.MouseEnter:Connect(function()
    if CloseButton then
        CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

CloseButton.MouseLeave:Connect(function()
    if CloseButton then
        CloseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    end
end)

-- Freecam proměnné
local freecamEnabled = false
local char = player.Character
local humanoid = char and char:FindFirstChild("Humanoid")

local savedWalkSpeed = 16
local savedJumpPower = 50

local function enableFreecam()
    if freecamEnabled then return end
    
    freecamEnabled = true
    cam.CameraType = Enum.CameraType.Scriptable
    
    -- Získat aktuální postavu
    char = player.Character
    if char then
        humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Uložení hodnot
            savedWalkSpeed = humanoid.WalkSpeed
            savedJumpPower = humanoid.JumpPower
            
            -- Zastavení postavy
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
        end
    end
    
    -- Update GUI
    if ToggleButton then
        ToggleButton.Text = "FreeCam: ON"
        ToggleButton.TextColor3 = Color3.fromRGB(100, 255, 100)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
    end
end

local function disableFreecam()
    if not freecamEnabled then return end
    
    freecamEnabled = false
    cam.CameraType = Enum.CameraType.Custom
    
    -- Obnovení pohybu
    if char and humanoid and humanoid.Parent then
        humanoid.WalkSpeed = savedWalkSpeed
        humanoid.JumpPower = savedJumpPower
    end
    
    -- Resetování ovládání
    rotating = false
    for key, _ in pairs(keysDown) do
        keysDown[key] = false
    end
    
    -- Update GUI
    if ToggleButton then
        ToggleButton.Text = "FreeCam: OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end

local function toggleFreecam()
    if freecamEnabled then
        disableFreecam()
    else
        enableFreecam()
    end
end

-- Tlačítko pro přepínání
ToggleButton.MouseButton1Click:Connect(function()
    toggleFreecam()
end)

-- Nastavení freecam
local speed = 3
local sens = 0.3
speed = speed / 10
if onMobile then sens = sens * 2 end

local touchPos

-- Hlavní render loop
local function renderStepped()
    if not freecamEnabled then return end
    
    -- Otáčení kamery
    if rotating then
        local delta = UIS:GetMouseDelta()
        local cf = cam.CFrame
        
        -- Omezení vertikálního otáčení
        local yAngle = cf:ToEulerAngles(Enum.RotationOrder.YZX)
        local newAmount = math.deg(yAngle) + delta.Y
        
        if newAmount > 80 or newAmount < -80 then
            if not (yAngle < 0 and delta.Y < 0) and not (yAngle > 0 and delta.Y > 0) then
                delta = Vector2.new(delta.X, 0)
            end
        end
        
        -- Aplikace rotace
        cf = cf * CFrame.Angles(-math.rad(delta.Y) * sens, 0, 0)
        cf = CFrame.Angles(0, -math.rad(delta.X) * sens, 0) * (cf - cf.Position) + cf.Position
        
        cam.CFrame = cf
        UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    else
        UIS.MouseBehavior = Enum.MouseBehavior.Default
    end
    
    -- Pohyb kamery
    if keysDown["W"] then
        cam.CFrame = cam.CFrame + cam.CFrame.LookVector * speed
    end
    if keysDown["S"] then
        cam.CFrame = cam.CFrame - cam.CFrame.LookVector * speed
    end
    if keysDown["A"] then
        cam.CFrame = cam.CFrame - cam.CFrame.RightVector * speed
    end
    if keysDown["D"] then
        cam.CFrame = cam.CFrame + cam.CFrame.RightVector * speed
    end
    if keysDown["Space"] then
        cam.CFrame = cam.CFrame + Vector3.new(0, speed, 0)
    end
    if keysDown["LeftControl"] or keysDown["Q"] then
        cam.CFrame = cam.CFrame - Vector3.new(0, speed, 0)
    end
end

-- Připojení render loop
RS.RenderStepped:Connect(renderStepped)

-- Ovládání kláves
UIS.InputBegan:Connect(function(input)
    -- Přepínání na O
    if input.KeyCode == Enum.KeyCode.O then
        toggleFreecam()
    end
    
    -- Klávesy pro pohyb
    if freecamEnabled then
        if input.KeyCode == Enum.KeyCode.W then
            keysDown["W"] = true
        elseif input.KeyCode == Enum.KeyCode.A then
            keysDown["A"] = true
        elseif input.KeyCode == Enum.KeyCode.S then
            keysDown["S"] = true
        elseif input.KeyCode == Enum.KeyCode.D then
            keysDown["D"] = true
        elseif input.KeyCode == Enum.KeyCode.Space then
            keysDown["Space"] = true
        elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.Q then
            keysDown["Q"] = true
        end
    end
    
    -- Otáčení myší
    if freecamEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
        rotating = true
    end
    
    -- Dotykové ovládání
    if freecamEnabled and input.UserInputType == Enum.UserInputType.Touch then
        local mouseLoc = UIS:GetMouseLocation()
        if mouseLoc.X > (cam.ViewportSize.X / 2) then
            rotating = true
        else
            touchPos = input.Position
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    -- Klávesy pro pohyb
    if input.KeyCode == Enum.KeyCode.W then
        keysDown["W"] = false
    elseif input.KeyCode == Enum.KeyCode.A then
        keysDown["A"] = false
    elseif input.KeyCode == Enum.KeyCode.S then
        keysDown["S"] = false
    elseif input.KeyCode == Enum.KeyCode.D then
        keysDown["D"] = false
    elseif input.KeyCode == Enum.KeyCode.Space then
        keysDown["Space"] = false
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.Q then
        keysDown["Q"] = false
    end
    
    -- Otáčení myší
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rotating = false
    end
    
    -- Dotykové ovládání
    if input.UserInputType == Enum.UserInputType.Touch then
        rotating = false
        touchPos = nil
    end
end)

-- Dotykový pohyb
if onMobile then
    UIS.TouchMoved:Connect(function(input)
        if not freecamEnabled or not touchPos then return end
        
        if input.Position.X < cam.ViewportSize.X / 2 then
            local delta = (input.Position - touchPos)
            
            -- Pohyb vpřed/vzad
            if delta.Y < -20 then
                keysDown["W"] = true
                keysDown["S"] = false
            elseif delta.Y > 20 then
                keysDown["W"] = false
                keysDown["S"] = true
            else
                keysDown["W"] = false
                keysDown["S"] = false
            end
            
            -- Pohyb do stran
            if delta.X < -20 then
                keysDown["A"] = true
                keysDown["D"] = false
            elseif delta.X > 20 then
                keysDown["A"] = false
                keysDown["D"] = true
            else
                keysDown["A"] = false
                keysDown["D"] = false
            end
        end
    end)
end

-- Zpracování respawnu postavy
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    wait(1) -- Počkat na načtení postavy
    
    if freecamEnabled then
        humanoid = newChar:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Znovu aplikovat freecam nastavení
            savedWalkSpeed = humanoid.WalkSpeed
            savedJumpPower = humanoid.JumpPower
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
        end
    end
end)

-- Zobrazit loading při startu
showLoading()

-- Přidání klávesy E pro rychlejší pohyb
UIS.InputBegan:Connect(function(input)
    if freecamEnabled and input.KeyCode == Enum.KeyCode.E then
        speed = 6 / 10
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        speed = 3 / 10
    end
end)

print("Sima FreeCam loaded successfully!")
print("Controls:")
print("- Click button or press O to toggle FreeCam")
print("- WASD: Move camera")
print("- Space/Q: Move up/down")
print("- Right mouse button: Look around")
print("- E: Speed boost")
print("- X button: Close GUI")
