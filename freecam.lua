local cam = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local onMobile = not UIS.KeyboardEnabled
local keysDown = {}
local rotating = false

if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

-- GUI Creation
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FreeCamGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 150, 0, 50)
MainFrame.Position = UDim2.new(0.5, -75, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

-- Toggle Switch Frame
local ToggleFrame = Instance.new("Frame")
ToggleFrame.Name = "ToggleFrame"
ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
ToggleFrame.BackgroundTransparency = 1
ToggleFrame.Visible = true

-- Toggle Switch
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 100, 0, 40)
ToggleButton.Position = UDim2.new(0.5, -50, 0.5, -20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ToggleButton.Text = "FreeCam: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.BorderSizePixel = 0

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.white
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.BorderSizePixel = 0

-- Loading Indicator Frame
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Size = UDim2.new(1, 0, 0, 50)
LoadingFrame.BackgroundTransparency = 1
LoadingFrame.Visible = false

-- Loading Text
local LoadingText = Instance.new("TextLabel")
LoadingText.Name = "LoadingText"
LoadingText.Size = UDim2.new(1, 0, 1, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "Loading Sima FreeCam"
LoadingText.TextColor3 = Color3.fromRGB(100, 200, 255)
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextSize = 16
LoadingText.Visible = true

-- Loading Animation (rotating dots)
local DotsFrame = Instance.new("Frame")
DotsFrame.Name = "DotsFrame"
DotsFrame.Size = UDim2.new(0, 60, 0, 20)
DotsFrame.Position = UDim2.new(0.5, -30, 1, 10)
DotsFrame.BackgroundTransparency = 1

local dots = {}
for i = 1, 3 do
    local dot = Instance.new("TextLabel")
    dot.Name = "Dot"..i
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, (i-1)*20, 0, 0)
    dot.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    dot.BackgroundTransparency = 0.5
    dot.BorderSizePixel = 0
    dot.Text = ""
    table.insert(dots, dot)
    dot.Parent = DotsFrame
end

-- Assemble GUI
DotsFrame.Parent = LoadingFrame
LoadingText.Parent = LoadingFrame
CloseButton.Parent = ToggleFrame
ToggleButton.Parent = ToggleFrame
ToggleFrame.Parent = MainFrame
LoadingFrame.Parent = MainFrame
MainFrame.Parent = ScreenGui
ScreenGui.Parent = PlayerGui

-- Loading Animation Function
local function animateLoading()
    while LoadingFrame.Visible do
        for i, dot in ipairs(dots) do
            local tween = TweenService:Create(dot, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 0.2
            })
            tween:Play()
            tween.Completed:Wait()
            
            local tween2 = TweenService:Create(dot, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 0.5
            })
            tween2:Play()
            task.wait(0.1)
        end
    end
end

-- Show Loading Function
local function showLoading()
    ToggleFrame.Visible = false
    LoadingFrame.Visible = true
    LoadingText.Text = "Loading Sima FreeCam"
    
    -- Start loading animation
    task.spawn(animateLoading)
    
    -- Simulate loading time
    task.wait(1.5)
    
    -- Hide loading and show toggle
    LoadingFrame.Visible = false
    ToggleFrame.Visible = true
end

-- Close button functionality
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Freecam + blokování pohybu postavy
local freecamEnabled = false
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local savedWalkSpeed = humanoid.WalkSpeed
local savedJumpPower = humanoid.JumpPower

local function enableFreecam()
    freecamEnabled = true
    cam.CameraType = Enum.CameraType.Scriptable

    -- Uložení hodnot
    savedWalkSpeed = humanoid.WalkSpeed
    savedJumpPower = humanoid.JumpPower

    -- Zastavení postavy
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
    
    -- Update GUI
    ToggleButton.Text = "FreeCam: ON"
    ToggleButton.TextColor3 = Color3.fromRGB(100, 255, 100)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
end

local function disableFreecam()
    freecamEnabled = false
    cam.CameraType = Enum.CameraType.Custom

    -- Obnovení pohybu
    humanoid.WalkSpeed = savedWalkSpeed
    humanoid.JumpPower = savedJumpPower
    
    -- Update GUI
    ToggleButton.Text = "FreeCam: OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
end

local function toggleFreecam()
    if freecamEnabled then
        disableFreecam()
    else
        enableFreecam()
    end
end

-- Toggle button functionality
ToggleButton.MouseButton1Click:Connect(function()
    toggleFreecam()
end)

local speed = 3
local sens = 0.3

speed /= 10
if onMobile then sens *= 2 end

local touchPos

local function renderStepped()
    if not freecamEnabled then return end

    if rotating then
        local delta = UIS:GetMouseDelta()
        local cf = cam.CFrame
        local yAngle = cf:ToEulerAngles(Enum.RotationOrder.YZX)
        local newAmount = math.deg(yAngle) + delta.Y

        if newAmount > 65 or newAmount < -65 then
            if not (yAngle < 0 and delta.Y < 0) and not (yAngle > 0 and delta.Y > 0) then
                delta = Vector2.new(delta.X, 0)
            end
        end

        cf *= CFrame.Angles(-math.rad(delta.Y), 0, 0)
        cf = CFrame.Angles(0, -math.rad(delta.X), 0) * (cf - cf.Position) + cf.Position
        cf = CFrame.lookAt(cf.Position, cf.Position + cf.LookVector)

        if delta ~= Vector2.new(0, 0) then
            cam.CFrame = cam.CFrame:Lerp(cf, sens)
        end

        UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    else
        UIS.MouseBehavior = Enum.MouseBehavior.Default
    end

    if keysDown["Enum.KeyCode.W"] then
        cam.CFrame *= CFrame.new(0, 0, -speed)
    end
    if keysDown["Enum.KeyCode.A"] then
        cam.CFrame *= CFrame.new(-speed, 0, 0)
    end
    if keysDown["Enum.KeyCode.S"] then
        cam.CFrame *= CFrame.new(0, 0, speed)
    end
    if keysDown["Enum.KeyCode.D"] then
        cam.CFrame *= CFrame.new(speed, 0, 0)
    end
end

RS.RenderStepped:Connect(renderStepped)

local validKeys = {
    "Enum.KeyCode.W",
    "Enum.KeyCode.A",
    "Enum.KeyCode.S",
    "Enum.KeyCode.D"
}

UIS.InputBegan:Connect(function(Input)
    -- TOGGLE freecam na O
    if Input.KeyCode == Enum.KeyCode.O then
        toggleFreecam()
    end

    for i, key in pairs(validKeys) do
        if key == tostring(Input.KeyCode) then
            keysDown[key] = true
        end
    end

    if not freecamEnabled then return end

    if Input.UserInputType == Enum.UserInputType.MouseButton2
        or (Input.UserInputType == Enum.UserInputType.Touch and UIS:GetMouseLocation().X > (cam.ViewportSize.X / 2)) then
        rotating = true
    end

    if Input.UserInputType == Enum.UserInputType.Touch then
        if Input.Position.X < cam.ViewportSize.X / 2 then
            touchPos = Input.Position
        end
    end
end)

UIS.InputEnded:Connect(function(Input)
    for key, v in pairs(keysDown) do
        if key == tostring(Input.KeyCode) then
            keysDown[key] = false
        end
    end

    if not freecamEnabled then return end

    if Input.UserInputType == Enum.UserInputType.MouseButton2
        or (Input.UserInputType == Enum.UserInputType.Touch and UIS:GetMouseLocation().X > (cam.ViewportSize.X / 2)) then
        rotating = false
    end

    if Input.UserInputType == Enum.UserInputType.Touch and touchPos then
        if Input.Position.X < cam.ViewportSize.X / 2 then
            touchPos = nil
            keysDown["Enum.KeyCode.W"] = false
            keysDown["Enum.KeyCode.A"] = false
            keysDown["Enum.KeyCode.S"] = false
            keysDown["Enum.KeyCode.D"] = false
        end
    end
end)

UIS.TouchMoved:Connect(function(input)
    if not freecamEnabled then return end

    if touchPos then
        if input.Position.X < cam.ViewportSize.X / 2 then
            if input.Position.Y < touchPos.Y then
                keysDown["Enum.KeyCode.W"] = true
                keysDown["Enum.KeyCode.S"] = false
            else
                keysDown["Enum.KeyCode.W"] = false
                keysDown["Enum.KeyCode.S"] = true
            end

            if input.Position.X < (touchPos.X - 15) then
                keysDown["Enum.KeyCode.A"] = true
                keysDown["Enum.KeyCode.D"] = false
            elseif input.Position.X > (touchPos.X + 15) then
                keysDown["Enum.KeyCode.A"] = false
                keysDown["Enum.KeyCode.D"] = true
            else
                keysDown["Enum.KeyCode.A"] = false
                keysDown["Enum.KeyCode.D"] = false
            end
        end
    end
end)

-- Show loading on start
showLoading()

-- Reconnect character if respawned
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    
    if freecamEnabled then
        -- Re-apply freecam settings
        savedWalkSpeed = humanoid.WalkSpeed
        savedJumpPower = humanoid.JumpPower
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    end
end)
