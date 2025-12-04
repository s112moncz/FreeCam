local cam = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local onMobile = not UIS.KeyboardEnabled
local keysDown = {}
local rotating = false

if not game:IsLoaded() then game.Loaded:Wait() end

-- Styly pro Voidware look
local VOIDWARE_COLORS = {
    Background = Color3.fromRGB(20, 20, 25),
    Header = Color3.fromRGB(30, 30, 40),
    Section = Color3.fromRGB(25, 25, 35),
    Text = Color3.fromRGB(220, 220, 220),
    Accent = Color3.fromRGB(100, 150, 255),
    Close = Color3.fromRGB(255, 80, 80),
    Loading = Color3.fromRGB(100, 200, 255)
}

-- Vytvoř GUI
local player = game.Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoidwareFreeCam"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Hlavní okno
local MainWindow = Instance.new("Frame")
MainWindow.Size = UDim2.new(0, 350, 0, 400)
MainWindow.Position = UDim2.new(0.5, -175, 0.5, -200)
MainWindow.BackgroundColor3 = VOIDWARE_COLORS.Background
MainWindow.BorderSizePixel = 0

local WindowCorner = Instance.new("UICorner")
WindowCorner.CornerRadius = UDim.new(0, 8)
WindowCorner.Parent = MainWindow

-- Header s titulem
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = VOIDWARE_COLORS.Header
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Sima FreeCam"
Title.TextColor3 = VOIDWARE_COLORS.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Tlačítko zavření (křížek)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.BackgroundColor3 = VOIDWARE_COLORS.Close
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.BorderSizePixel = 0

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Sekce Information
local InfoSection = Instance.new("Frame")
InfoSection.Size = UDim2.new(1, -20, 0, 320)
InfoSection.Position = UDim2.new(0, 10, 0, 50)
InfoSection.BackgroundColor3 = VOIDWARE_COLORS.Section
InfoSection.BorderSizePixel = 0

local SectionCorner = Instance.new("UICorner")
SectionCorner.CornerRadius = UDim.new(0, 6)
SectionCorner.Parent = InfoSection

local SectionTitle = Instance.new("TextLabel")
SectionTitle.Size = UDim2.new(1, 0, 0, 30)
SectionTitle.BackgroundColor3 = VOIDWARE_COLORS.Accent
SectionTitle.Text = "Information"
SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SectionTitle.Font = Enum.Font.GothamBold
SectionTitle.TextSize = 14
SectionTitle.BorderSizePixel = 0

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 6)
TitleCorner.Parent = SectionTitle

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, -20, 1, -40)
InfoText.Position = UDim2.new(0, 10, 0, 35)
InfoText.BackgroundTransparency = 1
InfoText.Text = "Sima FreeCam v1.0\n\n🚀 How to Use:\nPress O key to toggle FreeCam\n\n🎮 Controls:\n• WASD - Move camera\n• Right Click - Look around\n• Space - Move up\n• Q or Ctrl - Move down\n• E - Speed boost (hold)\n\n📱 Mobile Controls:\n• Right side - Look around (touch)\n• Left side - Move (touch & drag)\n\n🔧 Features:\n• Character movement locked\n• Smooth camera movement\n• Mobile touch support\n• Voidware style GUI\n\n💡 Tip: Press O anytime to toggle!"
InfoText.TextColor3 = VOIDWARE_COLORS.Text
InfoText.Font = Enum.Font.Gotham
InfoText.TextSize = 13
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.TextWrapped = true

-- Status indicator
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 1, -40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: FreeCam OFF (Press O)"
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Loading indicator
local LoadingOverlay = Instance.new("Frame")
LoadingOverlay.Size = UDim2.new(1, 0, 1, 0)
LoadingOverlay.BackgroundColor3 = VOIDWARE_COLORS.Background
LoadingOverlay.BackgroundTransparency = 0.1
LoadingOverlay.Visible = true

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 0, 30)
LoadingText.Position = UDim2.new(0, 0, 0.5, -15)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "Loading Sima FreeCam..."
LoadingText.TextColor3 = VOIDWARE_COLORS.Loading
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextSize = 18

-- Sestavení GUI
StatusLabel.Parent = InfoSection
LoadingText.Parent = LoadingOverlay
LoadingOverlay.Parent = MainWindow
SectionTitle.Parent = InfoSection
InfoText.Parent = InfoSection
InfoSection.Parent = MainWindow
CloseButton.Parent = Header
Title.Parent = Header
Header.Parent = MainWindow
MainWindow.Parent = ScreenGui
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Skryj loading po 2 sekundách
task.delay(2, function()
    if LoadingOverlay then
        LoadingOverlay.Visible = false
    end
end)

-- Tlačítko zavření
CloseButton.MouseButton1Click:Connect(function()
    if freecamEnabled then
        disableFreecam()
    end
    ScreenGui:Destroy()
end)

-- Efekty hoveru pro close button
CloseButton.MouseEnter:Connect(function()
    if CloseButton then
        CloseButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

CloseButton.MouseLeave:Connect(function()
    if CloseButton then
        CloseButton.BackgroundColor3 = VOIDWARE_COLORS.Close
    end
end)

-- Freecam + blokování pohybu postavy
local freecamEnabled = false
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local savedWalkSpeed = humanoid.WalkSpeed
local savedJumpPower = humanoid.JumpPower

-- Rozšířené klávesy pro pohyb nahoru/dolů a speed boost
local extendedKeys = {
    "Enum.KeyCode.W",
    "Enum.KeyCode.A",
    "Enum.KeyCode.S",
    "Enum.KeyCode.D",
    "Enum.KeyCode.Space",
    "Enum.KeyCode.Q",
    "Enum.KeyCode.E",
    "Enum.KeyCode.LeftControl"
}

local function updateStatus()
    if StatusLabel then
        if freecamEnabled then
            StatusLabel.Text = "Status: FreeCam ON (Press O to disable)"
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            StatusLabel.Text = "Status: FreeCam OFF (Press O to enable)"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
end

local function enableFreecam()
	freecamEnabled = true
	cam.CameraType = Enum.CameraType.Scriptable

	-- Uložení hodnot
	savedWalkSpeed = humanoid.WalkSpeed
	savedJumpPower = humanoid.JumpPower

	-- Zastavení postavy
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
    
    -- Update status
    updateStatus()
end

local function disableFreecam()
	freecamEnabled = false
	cam.CameraType = Enum.CameraType.Custom

	-- Obnovení pohybu
	humanoid.WalkSpeed = savedWalkSpeed
	humanoid.JumpPower = savedJumpPower
    
    -- Update status
    updateStatus()
end

local function toggleFreecam()
	if freecamEnabled then
		disableFreecam()
	else
		enableFreecam()
	end
end

local speed = 3
local sens = 0.3
local baseSpeed = speed / 10
local currentSpeed = baseSpeed

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

	-- Pohyb s aktuální rychlostí
	if keysDown["Enum.KeyCode.W"] then
		cam.CFrame *= CFrame.new(0, 0, -currentSpeed)
	end
	if keysDown["Enum.KeyCode.A"] then
		cam.CFrame *= CFrame.new(-currentSpeed, 0, 0)
	end
	if keysDown["Enum.KeyCode.S"] then
		cam.CFrame *= CFrame.new(0, 0, currentSpeed)
	end
	if keysDown["Enum.KeyCode.D"] then
		cam.CFrame *= CFrame.new(currentSpeed, 0, 0)
	end
	-- Pohyb nahoru/dolů
	if keysDown["Enum.KeyCode.Space"] then
		cam.CFrame *= CFrame.new(0, currentSpeed, 0)
	end
	if keysDown["Enum.KeyCode.Q"] or keysDown["Enum.KeyCode.LeftControl"] then
		cam.CFrame *= CFrame.new(0, -currentSpeed, 0)
	end
end

RS.RenderStepped:Connect(renderStepped)

UIS.InputBegan:Connect(function(Input)
	-- TOGGLE freecam na O
	if Input.KeyCode == Enum.KeyCode.O then
		toggleFreecam()
	end

	-- Klávesy pro pohyb
	for i, key in pairs(extendedKeys) do
		if key == tostring(Input.KeyCode) then
			keysDown[key] = true
		end
	end

	-- Speed boost (E)
	if Input.KeyCode == Enum.KeyCode.E then
		currentSpeed = baseSpeed * 3
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
	-- Klávesy pro pohyb
	for key, v in pairs(keysDown) do
		if key == tostring(Input.KeyCode) then
			keysDown[key] = false
		end
	end

	-- Reset speed boost
	if Input.KeyCode == Enum.KeyCode.E then
		currentSpeed = baseSpeed
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
			keysDown["Enum.KeyCode.Space"] = false
			keysDown["Enum.KeyCode.Q"] = false
		end
	end
end)

UIS.TouchMoved:Connect(function(input)
	if not freecamEnabled then return end

	if touchPos then
		if input.Position.X < cam.ViewportSize.X / 2 then
			-- Pohyb vpřed/vzad
			if input.Position.Y < touchPos.Y then
				keysDown["Enum.KeyCode.W"] = true
				keysDown["Enum.KeyCode.S"] = false
			else
				keysDown["Enum.KeyCode.W"] = false
				keysDown["Enum.KeyCode.S"] = true
			end

			-- Pohyb do stran
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

-- Zpracování respawnu
player.CharacterAdded:Connect(function(newChar)
    task.wait(1)
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

-- Inicializace statusu
updateStatus()

print("✅ Sima FreeCam loaded with Voidware GUI!")
print("🎯 Press O key to toggle FreeCam")
print("❌ Click X to close GUI")
