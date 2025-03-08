local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/KlorPe000/KlorPeLib/main/source'))()

local Window = OrionLib:MakeWindow({
    Name = "KlorPeHub", 
    HidePremium = false, 
    ConfigFolder = "KlorPeTest"
})

local PlayerTab = Window:MakeTab({
    Name = "Гравець",
    Icon = "rbxassetid://17404114716",
    PremiumOnly = false
})
 
-- Переменные
local walkSpeed = 16 
local jumpHeight = 7
local fieldOfView = 70

local walkSpeedEnabled = false
local jumpHeightEnabled = false
local fovEnabled = false

local defaultWalkSpeed = 16
local defaultJumpHeight = 7
local defaultFieldOfView = 70
 
-- Функции для сброса значений
local function resetHumanoid(humanoid)
    humanoid.WalkSpeed = defaultWalkSpeed
    humanoid.JumpHeight = defaultJumpHeight
end

local function resetFOV()
    game.Workspace.CurrentCamera.FieldOfView = defaultFieldOfView
end

-- Мониторинг Humanoid
local function monitorHumanoid(humanoid)
    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if walkSpeedEnabled and humanoid.WalkSpeed ~= walkSpeed then
            humanoid.WalkSpeed = walkSpeed
        end
    end)

    humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(function()
        if jumpHeightEnabled and humanoid.JumpHeight ~= jumpHeight then
            humanoid.JumpHeight = jumpHeight
        end
    end)
end

-- Мониторинг FOV
local function monitorFOV()
    game.Workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
        if fovEnabled and game.Workspace.CurrentCamera.FieldOfView ~= fieldOfView then
            game.Workspace.CurrentCamera.FieldOfView = fieldOfView
        end
    end)
end

-- Настройка персонажа
local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    if humanoid then
        monitorHumanoid(humanoid)
        if walkSpeedEnabled then
            humanoid.WalkSpeed = walkSpeed
        else
            humanoid.WalkSpeed = defaultWalkSpeed
        end

        if jumpHeightEnabled then
            humanoid.JumpHeight = jumpHeight
        else
            humanoid.JumpHeight = defaultJumpHeight
        end
    end
end

game.Players.LocalPlayer.CharacterAdded:Connect(setupCharacter)
if game.Players.LocalPlayer.Character then
    setupCharacter(game.Players.LocalPlayer.Character)
end

monitorFOV()

-- Секция скорости
PlayerTab:AddSection({ Name = "Швидкість" })

PlayerTab:AddSlider({
    Name = "Швидкість руху",
    Min = 16,
    Max = 500,
    Default = 16,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Сила",
    Callback = function(Value)
        walkSpeed = Value
        if walkSpeedEnabled then
            local character = game.Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = walkSpeed
                end
            end
        end
    end
})

PlayerTab:AddToggle({
    Name = "Вкл/Викл швидкість рух",
    Default = false,
    Callback = function(State)
        walkSpeedEnabled = State
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                if walkSpeedEnabled then
                    humanoid.WalkSpeed = walkSpeed
                else
                    resetHumanoid(humanoid)
                end
            end
        end
    end
})

-- Секция прыжков
PlayerTab:AddSection({ Name = "Стрибки" })

PlayerTab:AddSlider({
    Name = "Висота стрибка",
    Min = 7,
    Max = 100,
    Default = 7,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Сила",
    Callback = function(Value)
        jumpHeight = Value
        if jumpHeightEnabled then
            local character = game.Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.JumpHeight = jumpHeight
                end
            end
        end
    end
})

PlayerTab:AddToggle({
    Name = "Вкл/Викл висота стрибка",
    Default = false,
    Callback = function(State)
        jumpHeightEnabled = State
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                if jumpHeightEnabled then
                    humanoid.JumpHeight = jumpHeight
                else
                    resetHumanoid(humanoid)
                end
            end
        end
    end
})

game:GetService("UserInputService").JumpRequest:connect(function()
	if InfiniteJumpEnabled then
		game:GetService"Players".LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")
	end
end)

PlayerTab:AddToggle({
    Name = "Нескінченні стрибки",
    Default = false,
    Callback = function(State)
        InfiniteJumpEnabled = State
    end
})

-- Секция поля зрения
PlayerTab:AddSection({ Name = "Поле зору" })

PlayerTab:AddSlider({
    Name = "Поле зору",
    Min = 5,
    Max = 120,
    Default = 70,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Сила",
    Callback = function(Value)
        fieldOfView = Value
        if fovEnabled then
            game.Workspace.CurrentCamera.FieldOfView = fieldOfView
        end
    end
})

PlayerTab:AddToggle({
    Name = "Вкл/Викл поле зору",
    Default = false,
    Callback = function(State)
        fovEnabled = State
        if fovEnabled then
            game.Workspace.CurrentCamera.FieldOfView = fieldOfView
        else
            resetFOV()
        end
    end
})

local Section = PlayerTab:AddSection({
    Name = "Інше"
})

local Noclip = nil
local Clip = nil
local originalCollisions = {}
local cachedParts = {}
local vehicleCollisions = {}
local vehicleParts = {}

-- Сохранение состояния столкновений для частей игрока
local function cachePlayerParts()
    cachedParts = {}
    originalCollisions = {}
    for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
        if v:IsA('BasePart') then
            table.insert(cachedParts, v)
            originalCollisions[v] = v.CanCollide
        end
    end
end

-- Сохранение состояния столкновений для транспортного средства
local function cacheVehicleParts(vehicle)
    vehicleParts = {}
    vehicleCollisions = {}
    for _, v in pairs(vehicle:GetDescendants()) do
        if v:IsA('BasePart') then
            table.insert(vehicleParts, v)
            vehicleCollisions[v] = v.CanCollide
        end
    end
end

-- Проверка на наличие транспортного средства
local function getVehicle()
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        local seat = character.Humanoid.SeatPart
        if seat and seat:IsA("VehicleSeat") then
            return seat.Parent
        end
    end
    return nil
end

-- Включение noclip
function noclip()
    Clip = false
    cachePlayerParts()

    local vehicle = getVehicle()
    if vehicle then
        cacheVehicleParts(vehicle)
    end

    local function Nocl()
        if not Clip then
            -- Отключаем столкновения для игрока
            for _, part in pairs(cachedParts) do
                if part and part:IsA('BasePart') and part.CanCollide then
                    part.CanCollide = false
                end
            end

            -- Отключаем столкновения для транспортного средства
            for _, part in pairs(vehicleParts) do
                if part and part:IsA('BasePart') and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end

    -- Используем Heartbeat для редких обновлений
    Noclip = game:GetService('RunService').Heartbeat:Connect(Nocl)
end

-- Выключение noclip
function clip()
    if Noclip then Noclip:Disconnect() end
    Clip = true

    -- Восстанавливаем столкновения для игрока
    for part, collision in pairs(originalCollisions) do
        if part and part:IsA('BasePart') and part.CanCollide ~= collision then
            part.CanCollide = collision
        end
    end

    -- Восстанавливаем столкновения для транспортного средства
    for part, collision in pairs(vehicleCollisions) do
        if part and part:IsA('BasePart') and part.CanCollide ~= collision then
            part.CanCollide = collision
        end
    end
end

-- Обработчик респавна персонажа
local player = game.Players.LocalPlayer
player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    cachePlayerParts()
    if not Clip then
        noclip()
    end
end)

-- Пример использования Toggle
PlayerTab:AddToggle({
    Name = "Нокліп",
    Default = false,
    Callback = function(State)
        if State then
            noclip()
        else
            clip()
        end
    end
})

local function activateuserFLY()
    if flyButtonExists2 then return end -- Если кнопка уже существует, ничего не делаем
    flyButtonExists2 = true -- Устанавливаем флаг

    local main = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local up = Instance.new("TextButton")
    local down = Instance.new("TextButton")
    local onof = Instance.new("TextButton")
    local TextLabel = Instance.new("TextLabel")
    local plus = Instance.new("TextButton")
    local speed = Instance.new("TextLabel")
    local mine = Instance.new("TextButton")
    local closebutton = Instance.new("TextButton")
    local mini = Instance.new("TextButton")
    local mini2 = Instance.new("TextButton")
    
    local main = Instance.new("ScreenGui")
    main.Name = "main"
    main.Parent = game:GetService("CoreGui")
    main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    main.IgnoreGuiInset = true
    main.ResetOnSpawn = false
    
    local Frame = Instance.new("Frame")
    Frame.Parent = main
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.BorderColor3 = Color3.fromRGB(150, 150, 150)
    Frame.Position = UDim2.new(0.100320168, -0, 0.379746825, 0)
    Frame.Size = UDim2.new(0, 145, 0, 56)
    
    local onof = Instance.new("TextButton")
    onof.Name = "onof"
    onof.Parent = Frame
    onof.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    onof.BorderColor3 = Color3.fromRGB(150, 150, 150)
    onof.Position = UDim2.new(0.613, 0, 0.491228074, 1)
    onof.Size = UDim2.new(0, 56, 0, 28)
    onof.Font = Enum.Font.SourceSans
    onof.Text = "Політ"
    onof.TextColor3 = Color3.fromRGB(240, 240, 240)
    onof.TextSize = 14.000
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = Frame
    TextLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TextLabel.BorderColor3 = Color3.fromRGB(150, 150, 150)
    TextLabel.Position = UDim2.new(0.31, 0, -0.001, 0)
    TextLabel.Size = UDim2.new(0, 100, 0, 27)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.Text = "Fly User"
    TextLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14.000
    TextLabel.TextWrapped = true
    
    local plus = Instance.new("TextButton")
    plus.Name = "plus"
    plus.Parent = Frame
    plus.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    plus.BorderColor3 = Color3.fromRGB(150, 150, 150)
    plus.Position = UDim2.new(0, 0, 0, 0)
    plus.Size = UDim2.new(0, 44, 0, 28)
    plus.Font = Enum.Font.SourceSans
    plus.Text = "+"
    plus.TextColor3 = Color3.fromRGB(240, 240, 240)
    plus.TextScaled = true
    plus.TextSize = 14.000
    plus.TextWrapped = true
    
    local speed = Instance.new("TextLabel")
    speed.Name = "speed"
    speed.Parent = Frame
    speed.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    speed.BorderColor3 = Color3.fromRGB(150, 150, 150)
    speed.Position = UDim2.new(0.31, 0, 0.491228074, 1)
    speed.Size = UDim2.new(0, 43, 0, 28)
    speed.Font = Enum.Font.SourceSans
    speed.Text = "1"
    speed.TextColor3 = Color3.fromRGB(240, 240, 240)
    speed.TextScaled = true
    speed.TextSize = 14.000
    speed.TextWrapped = true
    
    local mine = Instance.new("TextButton")
    mine.Name = "mine"
    mine.Parent = Frame
    mine.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mine.BorderColor3 = Color3.fromRGB(150, 150, 150)
    mine.Position = UDim2.new(0, 0, 0.491228074, 1)
    mine.Size = UDim2.new(0, 44, 0, 28)
    mine.Font = Enum.Font.SourceSans
    mine.Text = "-"
    mine.TextColor3 = Color3.fromRGB(240, 240, 240)
    mine.TextScaled = true
    mine.TextSize = 14.000
    mine.TextWrapped = true
    
    local closebutton = Instance.new("TextButton")
    closebutton.Name = "Close"
    closebutton.Parent = Frame
    closebutton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    closebutton.BorderColor3 = Color3.fromRGB(150, 150, 150)
    closebutton.Font = Enum.Font.SourceSans
    closebutton.Size = UDim2.new(0, 44, 0, 28)
    closebutton.Text = "X"
    closebutton.TextSize = 30
    closebutton.Position = UDim2.new(0, 0, -1, 27)
    closebutton.ZIndex = 10
    
    speeds = 1
    
    local speaker = game:GetService("Players").LocalPlayer
    
    local chr = game.Players.LocalPlayer.Character
    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
    
    nowe = false
    
    Frame.Active = true -- main = gui
    Frame.Draggable = true
    
    onof.MouseButton1Down:connect(function()
    
        if nowe == true then
            nowe = false
    
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
            speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        else 
            nowe = true
    
    
    
            for i = 1, speeds do
                spawn(function()
    
                    local hb = game:GetService("RunService").Heartbeat	
    
    
                    tpwalking = true
                    local chr = game.Players.LocalPlayer.Character
                    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                    while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                        if hum.MoveDirection.Magnitude > 0 then
                            chr:TranslateBy(hum.MoveDirection)
                        end
                    end
    
                end)
            end
            game.Players.LocalPlayer.Character.Animate.Disabled = true
            local Char = game.Players.LocalPlayer.Character
            local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
    
            for i,v in next, Hum:GetPlayingAnimationTracks() do
                v:AdjustSpeed(0)
            end
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
            speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        end
    
    
    
    
        if game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
    
    
    
            local plr = game.Players.LocalPlayer
            local torso = plr.Character.Torso
            local flying = true
            local deb = true
            local ctrl = {f = 0, b = 0, l = 0, r = 0}
            local lastctrl = {f = 0, b = 0, l = 0, r = 0}
            local maxspeed = 50
            local speed = 0
    
    
            local bg = Instance.new("BodyGyro", torso)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = torso.CFrame
            local bv = Instance.new("BodyVelocity", torso)
            bv.velocity = Vector3.new(0,0.1,0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            if nowe == true then
                plr.Character.Humanoid.PlatformStand = true
            end
            while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
                game:GetService("RunService").RenderStepped:Wait()
    
                if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                    speed = speed+.5+(speed/maxspeed)
                    if speed > maxspeed then
                        speed = maxspeed
                    end
                elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
                    speed = speed-1
                    if speed < 0 then
                        speed = 0
                    end
                end
                if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
                    lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
                else
                    bv.velocity = Vector3.new(0,0,0)
                end
                --	game.Players.LocalPlayer.Character.Animate.Disabled = true
                bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
            end
            ctrl = {f = 0, b = 0, l = 0, r = 0}
            lastctrl = {f = 0, b = 0, l = 0, r = 0}
            speed = 0
            bg:Destroy()
            bv:Destroy()
            plr.Character.Humanoid.PlatformStand = false
            game.Players.LocalPlayer.Character.Animate.Disabled = false
            tpwalking = false
    
    
    
    
        else
            local plr = game.Players.LocalPlayer
            local UpperTorso = plr.Character.UpperTorso
            local flying = true
            local deb = true
            local ctrl = {f = 0, b = 0, l = 0, r = 0}
            local lastctrl = {f = 0, b = 0, l = 0, r = 0}
            local maxspeed = 50
            local speed = 0
    
    
            local bg = Instance.new("BodyGyro", UpperTorso)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = UpperTorso.CFrame
            local bv = Instance.new("BodyVelocity", UpperTorso)
            bv.velocity = Vector3.new(0,0.1,0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            if nowe == true then
                plr.Character.Humanoid.PlatformStand = true
            end
            while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
                wait()
    
                if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                    speed = speed+.5+(speed/maxspeed)
                    if speed > maxspeed then
                        speed = maxspeed
                    end
                elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
                    speed = speed-1
                    if speed < 0 then
                        speed = 0
                    end
                end
                if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
                    lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
                else
                    bv.velocity = Vector3.new(0,0,0)
                end
    
                bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
            end
            ctrl = {f = 0, b = 0, l = 0, r = 0}
            lastctrl = {f = 0, b = 0, l = 0, r = 0}
            speed = 0
            bg:Destroy()
            bv:Destroy()
            plr.Character.Humanoid.PlatformStand = false
            game.Players.LocalPlayer.Character.Animate.Disabled = false
            tpwalking = false
    
    
    
        end
    
    
    
    
    
    end)
    
    local tis
    
    up.MouseButton1Down:connect(function()
        tis = up.MouseEnter:connect(function()
            while tis do
                wait()
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
            end
        end)
    end)
    
    up.MouseLeave:connect(function()
        if tis then
            tis:Disconnect()
            tis = nil
        end
    end)
    
    local dis
    
    down.MouseButton1Down:connect(function()
        dis = down.MouseEnter:connect(function()
            while dis do
                wait()
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,0)
            end
        end)
    end)
    
    down.MouseLeave:connect(function()
        if dis then
            dis:Disconnect()
            dis = nil
        end
    end)
    
    
    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(char)
        wait(0.7)
        game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
        game.Players.LocalPlayer.Character.Animate.Disabled = false
    
    end)
    
    
    plus.MouseButton1Down:connect(function()
        speeds = speeds + 1
        speed.Text = speeds
        if nowe == true then
    
    
            tpwalking = false
            for i = 1, speeds do
                spawn(function()
    
                    local hb = game:GetService("RunService").Heartbeat	
    
    
                    tpwalking = true
                    local chr = game.Players.LocalPlayer.Character
                    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                    while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                        if hum.MoveDirection.Magnitude > 0 then
                            chr:TranslateBy(hum.MoveDirection)
                        end
                    end
    
                end)
            end
        end
    end)
    mine.MouseButton1Down:connect(function()
        if speeds == 1 then
            speed.Text = 'Не може бути менше 1'
            wait(1)
            speed.Text = speeds
        else
            speeds = speeds - 1
            speed.Text = speeds
            if nowe == true then
                tpwalking = false
                for i = 1, speeds do
                    spawn(function()
    
                        local hb = game:GetService("RunService").Heartbeat	
    
    
                        tpwalking = true
                        local chr = game.Players.LocalPlayer.Character
                        local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                        while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                            if hum.MoveDirection.Magnitude > 0 then
                                chr:TranslateBy(hum.MoveDirection)
                            end
                        end
    
                    end)
                end
            end
        end
    end)
    
    closebutton.MouseButton1Click:Connect(function()
        main:Destroy()
        flyButtonExists2 = false -- Сбрасываем флаг, чтобы можно было снова создать кнопку
    end) 

end

PlayerTab:AddButton({
    Name = "Політ гравцем",
    Callback = function()
        activateuserFLY()
    end
})

--Механика полета
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local speaker = Players.LocalPlayer
local flying = false
local speed = 25
local minSpeed = 25
local maxSpeed = 1000
local ctrl = {f = 0, b = 0, l = 0, r = 0}
local vehicle = nil

-- Отслеживание, садится ли игрок в транспортное средство
local function onSeated(active, seat)
    if active and seat:IsA("VehicleSeat") then
        vehicle = seat
    else
        vehicle = nil
    end
end

-- Связываем событие с Humanoid персонажа
local function setupSeatedEvent()
    local character = speaker.Character or speaker.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Seated:Connect(onSeated)
end

-- Включение или отключение полета
local function toggleFly()
    flying = not flying
    if flying then
        if not vehicle then
            flying = false
            return
        end

        local bg = Instance.new("BodyGyro", vehicle)
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.cframe = vehicle.CFrame

        local bv = Instance.new("BodyVelocity", vehicle)
        bv.velocity = Vector3.new(0, 0.1, 0)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

        spawn(function()
            while flying do
                RunService.RenderStepped:Wait()

                bv.velocity = (
                    (workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f + ctrl.b)) +
                    ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * .2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)
                ) * speed
                bg.cframe = workspace.CurrentCamera.CoordinateFrame
            end

            bg:Destroy()
            bv:Destroy()
        end)
    else
    end
end

-- Обработка ввода
UserInputService.InputBegan:Connect(function(input)
    if flying then
        if input.KeyCode == Enum.KeyCode.W then
            ctrl.f = 1
        elseif input.KeyCode == Enum.KeyCode.S then
            ctrl.b = -1
        elseif input.KeyCode == Enum.KeyCode.A then
            ctrl.l = -1
        elseif input.KeyCode == Enum.KeyCode.D then
            ctrl.r = 1
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if flying then
        if input.KeyCode == Enum.KeyCode.W then
            ctrl.f = 0
        elseif input.KeyCode == Enum.KeyCode.S then
            ctrl.b = 0
        elseif input.KeyCode == Enum.KeyCode.A then
            ctrl.l = 0
        elseif input.KeyCode == Enum.KeyCode.D then
            ctrl.r = 0
        end
    end
end)

setupSeatedEvent()

speaker.CharacterAdded:Connect(setupSeatedEvent)

-- Интерфейс кнопки
local function activatecarFLY()
    if flyButtonExists1 then return end -- Если кнопка уже существует, ничего не делаем
    flyButtonExists1 = true -- Устанавливаем флаг

    local minSpeed = 25
    local maxSpeed = 1000

    local main = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local up = Instance.new("TextButton")
    local down = Instance.new("TextButton")
    local onof = Instance.new("TextButton")
    local TextLabel = Instance.new("TextLabel")
    local plus = Instance.new("TextButton")
    local speedLabel = Instance.new("TextLabel")
    local mine = Instance.new("TextButton")
    local closebutton = Instance.new("TextButton")

    main.Name = "main"
    main.Parent = game:GetService("CoreGui")
    main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    main.IgnoreGuiInset = true
    main.ResetOnSpawn = false

    Frame.Parent = main
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.BorderColor3 = Color3.fromRGB(150, 150, 150)
    Frame.Position = UDim2.new(0.100320168, -0, 0.500, 0)
    Frame.Size = UDim2.new(0, 145, 0, 56)

    onof.Name = "onof"
    onof.Parent = Frame
    onof.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    onof.BorderColor3 = Color3.fromRGB(150, 150, 150)
    onof.Position = UDim2.new(0.613, 0, 0.491228074, 1)
    onof.Size = UDim2.new(0, 56, 0, 28)
    onof.Font = Enum.Font.SourceSans
    onof.Text = "Політ"
    onof.TextColor3 = Color3.fromRGB(240, 240, 240)
    onof.TextSize = 14

    onof.MouseButton1Click:Connect(function()
        toggleFly()
    end)

    TextLabel.Parent = Frame
    TextLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TextLabel.BorderColor3 = Color3.fromRGB(150, 150, 150)
    TextLabel.Position = UDim2.new(0.31, 0, 0, 0)
    TextLabel.Size = UDim2.new(0, 100, 0, 27)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.Text = "Fly Vehicle"
    TextLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14
    TextLabel.TextWrapped = true

    speedLabel.Name = "speedLabel"
    speedLabel.Parent = Frame
    speedLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    speedLabel.BorderColor3 = Color3.fromRGB(150, 150, 150)
    speedLabel.Position = UDim2.new(0.31, 0, 0.491228074, 1)
    speedLabel.Size = UDim2.new(0, 43, 0, 28)
    speedLabel.Font = Enum.Font.SourceSans
    speedLabel.Text = tostring(speed)
    speedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    speedLabel.TextScaled = true
    speedLabel.TextSize = 14
    speedLabel.TextWrapped = true

    plus.Name = "plus"
    plus.Parent = Frame
    plus.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    plus.BorderColor3 = Color3.fromRGB(150, 150, 150)
    plus.Position = UDim2.new(0, 0, 0, 0)
    plus.Size = UDim2.new(0, 44, 0, 28)
    plus.Font = Enum.Font.SourceSans
    plus.Text = "+"
    plus.TextColor3 = Color3.fromRGB(240, 240, 240)
    plus.TextScaled = true
    plus.TextSize = 14
    plus.TextWrapped = true

    plus.MouseButton1Click:Connect(function()
        speed = math.min(maxSpeed, speed + 25) -- Увеличиваем скорость
        speedLabel.Text = tostring(speed)
    end)

    mine.Name = "mine"
    mine.Parent = Frame
    mine.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mine.BorderColor3 = Color3.fromRGB(150, 150, 150)
    mine.Position = UDim2.new(0, 0, 0.491228074, 1)
    mine.Size = UDim2.new(0, 44, 0, 28)
    mine.Font = Enum.Font.SourceSans
    mine.Text = "-"
    mine.TextColor3 = Color3.fromRGB(240, 240, 240)
    mine.TextScaled = true
    mine.TextSize = 14
    mine.TextWrapped = true

    mine.MouseButton1Click:Connect(function()
        speed = math.max(minSpeed, speed - 25) -- Уменьшаем скорость
        speedLabel.Text = tostring(speed)
    end)

    closebutton.Name = "Close"
    closebutton.Parent = Frame
    closebutton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    closebutton.BorderColor3 = Color3.fromRGB(150, 150, 150)
    closebutton.Font = Enum.Font.SourceSans
    closebutton.Size = UDim2.new(0, 44, 0, 28)
    closebutton.Text = "X"
    closebutton.TextSize = 30
    closebutton.Position = UDim2.new(0, 0, -1, 27)
    closebutton.ZIndex = 10

    closebutton.MouseButton1Click:Connect(function()
        if main and main.Parent then
            main:Destroy()
            flyButtonExists1 = false
        end
    end)

    Frame.Active = true
    Frame.Draggable = true
end

PlayerTab:AddButton({
    Name = "Політ транспортом",
    Callback = function()
        activatecarFLY()
    end
})

-- Создание вкладки в пользовательском интерфейсе
local UniversalTab = Window:MakeTab({
    Name = "Аім", 
    Icon = "rbxassetid://17404114716", 
    PremiumOnly = false
})

local UniversalSection = UniversalTab:AddSection({
    Name = "Аім"
})

-- Инициализация глобальной таблицы и её свойств, если они ещё не существуют
getgenv().ExunysDeveloperAimbot = getgenv().ExunysDeveloperAimbot or {}
getgenv().ExunysDeveloperAimbot.Settings = getgenv().ExunysDeveloperAimbot.Settings or {
    TeamCheck = false,
    AliveCheck = false,
    WallCheck = false
}

UniversalSection:AddToggle({
    Name = "Перевірка на живого",
    Default = getgenv().ExunysDeveloperAimbot.Settings.AliveCheck,
    Default = true,
    Callback = function(Value)
        getgenv().ExunysDeveloperAimbot.Settings.AliveCheck = Value
    end
})

-- Добавление переключателей в UI
UniversalSection:AddToggle({
    Name = "Перевірка команди",
    Default = getgenv().ExunysDeveloperAimbot.Settings.TeamCheck,
    Default = false,
    Callback = function(Value)
        getgenv().ExunysDeveloperAimbot.Settings.TeamCheck = Value
    end
})

UniversalSection:AddToggle({
    Name = "Перевірка стін",
    Default = getgenv().ExunysDeveloperAimbot.Settings.WallCheck,
    Default = false,
    Callback = function(Value)
        getgenv().ExunysDeveloperAimbot.Settings.WallCheck = Value
    end
})


-- Функция инициализации аимбота
local function InitializeAimbot()

local game, workspace = game, workspace
local getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick, select = getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick, select
local Vector2new, Vector3new, Vector3zero, CFramenew, Color3fromRGB, Color3fromHSV, Drawingnew, TweenInfonew = Vector2.new, Vector3.new, Vector3.zero, CFrame.new, Color3.fromRGB, Color3.fromHSV, Drawing.new, TweenInfo.new
local getupvalue, mousemoverel, tablefind, tableremove, stringlower, stringsub, mathclamp = debug.getupvalue, mousemoverel or (Input and Input.MouseMove), table.find, table.remove, string.lower, string.sub, math.clamp

local GameMetatable = getrawmetatable and getrawmetatable(game) or {__index = function(self, Index)
	return self[Index]
end, __newindex = function(self, Index, Value)
	self[Index] = Value
end}

local __index = GameMetatable.__index
local __newindex = GameMetatable.__newindex
local GetService = select(2, pcall(__index, game, "GetService")) or game.GetService

--// Services

local RunService = GetService(game, "RunService")
local UserInputService = GetService(game, "UserInputService")
local TweenService = GetService(game, "TweenService")
local Players = GetService(game, "Players")

--// Degrade "__index" and "__newindex" functions if the executor doesn't support "getrawmetatable" properly.

local ReciprocalRelativeSensitivity = false

if getrawmetatable and select(2, pcall(__index, Players, "LocalPlayer")) then
	ReciprocalRelativeSensitivity = true

	__index, __newindex = function(Object, Key)
		return Object[Key]
	end, function(Object, Key, Value)
		Object[Key] = Value
	end
end

--// Service Methods

local LocalPlayer = __index(Players, "LocalPlayer")
local Camera = __index(workspace, "CurrentCamera")

local FindFirstChild, FindFirstChildOfClass = __index(game, "FindFirstChild"), __index(game, "FindFirstChildOfClass")
local GetDescendants = __index(game, "GetDescendants")
local WorldToViewportPoint = __index(Camera, "WorldToViewportPoint")
local GetPartsObscuringTarget = __index(Camera, "GetPartsObscuringTarget")
local GetMouseLocation = __index(UserInputService, "GetMouseLocation")
local GetPlayers = __index(Players, "GetPlayers")

--// Variables

local RequiredDistance, Typing, Running, ServiceConnections, Animation, OriginalSensitivity = 2000, false, false, {}
local Connect, Disconnect, GetRenderProperty, SetRenderProperty = __index(game, "DescendantAdded").Connect

local Degrade = false

do
	xpcall(function()
		local TemporaryDrawing = Drawingnew("Line")
		GetRenderProperty = getupvalue(getmetatable(TemporaryDrawing).__index, 4)
		SetRenderProperty = getupvalue(getmetatable(TemporaryDrawing).__newindex, 4)
		TemporaryDrawing.Remove(TemporaryDrawing)
	end, function()
		Degrade, GetRenderProperty, SetRenderProperty = true, function(Object, Key)
			return Object[Key]
		end, function(Object, Key, Value)
			Object[Key] = Value
		end
	end)

	local TemporaryConnection = Connect(__index(game, "DescendantAdded"), function() end)
	Disconnect = TemporaryConnection.Disconnect
	Disconnect(TemporaryConnection)
end

--// Checking for multiple processes

if ExunysDeveloperAimbot and ExunysDeveloperAimbot.Exit then
	ExunysDeveloperAimbot:Exit()
end

--// Environment

getgenv().ExunysDeveloperAimbot = {
	DeveloperSettings = {
		UpdateMode = "RenderStepped",
		TeamCheckOption = "TeamColor",
		RainbowSpeed = 1 -- Bigger = Slower
	},

	Settings = {
		Enabled = true,

		TeamCheck = false,
		AliveCheck = true,
		WallCheck = false,

		OffsetToMoveDirection = false,
		OffsetIncrement = 15,

		Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
		Sensitivity2 = 3.5, -- mousemoverel Sensitivity

		LockMode = 1, -- 1 = CFrame; 2 = mousemoverel
		LockPart = "Head", -- Body part to lock on

		TriggerKey = Enum.UserInputType.MouseButton2,
		Toggle = false
	},

	FOVSettings = {
		Enabled = true,
		Visible = true,

		Radius = 180,
		NumSides = 60,

		Thickness = 1,
		Transparency = 1,
		Filled = false,

		RainbowColor = false,
		RainbowOutlineColor = false,
		Color = Color3fromRGB(255, 255, 255),
		OutlineColor = Color3fromRGB(0, 0, 0),
		LockedColor = Color3fromRGB(255, 150, 150)
	},

	Blacklisted = {},
	FOVCircle = Drawingnew("Circle"),
	FOVCircleOutline = Drawingnew("Circle")
}

local Environment = getgenv().ExunysDeveloperAimbot

SetRenderProperty(Environment.FOVCircle, "Visible", false)
SetRenderProperty(Environment.FOVCircleOutline, "Visible", false)

--// Core Functions

local FixUsername = function(String)
	local Result

	for _, Value in next, GetPlayers(Players) do
		local Name = __index(Value, "Name")

		if stringsub(stringlower(Name), 1, #String) == stringlower(String) then
			Result = Name
		end
	end

	return Result
end

local GetRainbowColor = function()
	local RainbowSpeed = Environment.DeveloperSettings.RainbowSpeed

	return Color3fromHSV(tick() % RainbowSpeed / RainbowSpeed, 1, 1)
end

local ConvertVector = function(Vector)
	return Vector2new(Vector.X, Vector.Y)
end

local CancelLock = function()
	Environment.Locked = nil

	local FOVCircle = Degrade and Environment.FOVCircle or Environment.FOVCircle.__OBJECT

	SetRenderProperty(FOVCircle, "Color", Environment.FOVSettings.Color)
	__newindex(UserInputService, "MouseDeltaSensitivity", OriginalSensitivity)

	if Animation then
		Animation:Cancel()
	end
end

-- Проверяем части тела в модели персонажа
local function GetClosestPlayer()
    local Settings = Environment.Settings
    local LockPart = Settings.LockPart

    if not Environment.Locked then
        RequiredDistance = Environment.FOVSettings.Enabled and Environment.FOVSettings.Radius or 2000

        for _, Player in next, GetPlayers(Players) do
            local Character = __index(Player, "Character")
            if not Character then
                continue -- Пропускаем, если персонажа нет
            end

            local Humanoid = FindFirstChildOfClass(Character, "Humanoid")
            if not Humanoid then
                continue -- Пропускаем, если Humanoid отсутствует
            end

            if Player ~= LocalPlayer and not tablefind(Environment.Blacklisted, __index(Player, "Name")) then
                local Part = FindFirstChild(Character, LockPart)
                if not Part then
                    continue -- Пропускаем, если указанная часть тела отсутствует
                end

                local PartPosition = __index(Part, "Position")
                -- Проверки на команду, стены и здоровье
                if Settings.TeamCheck and __index(Player, Environment.DeveloperSettings.TeamCheckOption) == __index(LocalPlayer, Environment.DeveloperSettings.TeamCheckOption) then
                    continue
                end

                if Settings.AliveCheck and __index(Humanoid, "Health") <= 0 then
                    continue
                end

                if Settings.WallCheck then
                    local BlacklistTable = GetDescendants(__index(LocalPlayer, "Character"))
                    for _, Value in next, GetDescendants(Character) do
                        BlacklistTable[#BlacklistTable + 1] = Value
                    end
                    if #GetPartsObscuringTarget(Camera, {PartPosition}, BlacklistTable) > 0 then
                        continue
                    end
                end

                local Vector, OnScreen, Distance = WorldToViewportPoint(Camera, PartPosition)
                Vector = ConvertVector(Vector)
                Distance = (GetMouseLocation(UserInputService) - Vector).Magnitude

                if Distance < RequiredDistance and OnScreen then
                    RequiredDistance, Environment.Locked = Distance, Player
                end
            end
        end
    elseif (GetMouseLocation(UserInputService) - ConvertVector(WorldToViewportPoint(Camera, __index(__index(__index(Environment.Locked, "Character"), LockPart), "Position")))).Magnitude > RequiredDistance then
        CancelLock()
    end
end

local Load = function()
	OriginalSensitivity = __index(UserInputService, "MouseDeltaSensitivity")

	local Settings, FOVCircle, FOVCircleOutline, FOVSettings, Offset = Environment.Settings, Environment.FOVCircle, Environment.FOVCircleOutline, Environment.FOVSettings

	if not Degrade then
		FOVCircle, FOVCircleOutline = FOVCircle.__OBJECT, FOVCircleOutline.__OBJECT
	end

	SetRenderProperty(FOVCircle, "ZIndex", 2)
	SetRenderProperty(FOVCircleOutline, "ZIndex", 1)

	ServiceConnections.RenderSteppedConnection = Connect(__index(RunService, Environment.DeveloperSettings.UpdateMode), function()
		local OffsetToMoveDirection, LockPart = Settings.OffsetToMoveDirection, Settings.LockPart

		if FOVSettings.Enabled and Settings.Enabled then
			for Index, Value in next, FOVSettings do
				if Index == "Color" then
					continue
				end

				if pcall(GetRenderProperty, FOVCircle, Index) then
					SetRenderProperty(FOVCircle, Index, Value)
					SetRenderProperty(FOVCircleOutline, Index, Value)
				end
			end

			SetRenderProperty(FOVCircle, "Color", (Environment.Locked and FOVSettings.LockedColor) or FOVSettings.RainbowColor and GetRainbowColor() or FOVSettings.Color)
			SetRenderProperty(FOVCircleOutline, "Color", FOVSettings.RainbowOutlineColor and GetRainbowColor() or FOVSettings.OutlineColor)

			SetRenderProperty(FOVCircleOutline, "Thickness", FOVSettings.Thickness + 1)
			SetRenderProperty(FOVCircle, "Position", GetMouseLocation(UserInputService))
			SetRenderProperty(FOVCircleOutline, "Position", GetMouseLocation(UserInputService))
		else
			SetRenderProperty(FOVCircle, "Visible", false)
			SetRenderProperty(FOVCircleOutline, "Visible", false)
		end

		if Running and Settings.Enabled then
			GetClosestPlayer()

			Offset = OffsetToMoveDirection and __index(FindFirstChildOfClass(__index(Environment.Locked, "Character"), "Humanoid"), "MoveDirection") * (mathclamp(Settings.OffsetIncrement, 1, 30) / 10) or Vector3zero

			if Environment.Locked then
				local LockedPosition_Vector3 = __index(__index(Environment.Locked, "Character")[LockPart], "Position")
				local LockedPosition = WorldToViewportPoint(Camera, LockedPosition_Vector3 + Offset)
 
				local RelativeSensitivity = ReciprocalRelativeSensitivity and (1 / Settings.Sensitivity2) or Settings.Sensitivity2

				if Environment.Settings.LockMode == 2 then
					mousemoverel((LockedPosition.X - GetMouseLocation(UserInputService).X) * RelativeSensitivity, (LockedPosition.Y - GetMouseLocation(UserInputService).Y) * RelativeSensitivity)
				else
					if Settings.Sensitivity > 0 then
						Animation = TweenService:Create(Camera, TweenInfonew(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFramenew(Camera.CFrame.Position, LockedPosition_Vector3)})
						Animation:Play()
					else
						__newindex(Camera, "CFrame", CFramenew(Camera.CFrame.Position, LockedPosition_Vector3 + Offset))
					end

					__newindex(UserInputService, "MouseDeltaSensitivity", 0)
				end

				SetRenderProperty(FOVCircle, "Color", FOVSettings.LockedColor)
			end
		end
	end)

	ServiceConnections.InputBeganConnection = Connect(__index(UserInputService, "InputBegan"), function(Input)
		local TriggerKey, Toggle = Settings.TriggerKey, Settings.Toggle

		if Typing then
			return
		end

		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == TriggerKey or Input.UserInputType == TriggerKey then
			if Toggle then
				Running = not Running
 
				if not Running then
					CancelLock()
				end
			else
				Running = true
			end
		end
	end)

	ServiceConnections.InputEndedConnection = Connect(__index(UserInputService, "InputEnded"), function(Input)
		local TriggerKey, Toggle = Settings.TriggerKey, Settings.Toggle
 
		if Toggle or Typing then
			return
		end
 
		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == TriggerKey or Input.UserInputType == TriggerKey then
			Running = false
			CancelLock()
		end
	end)
end

--// Typing Check

ServiceConnections.TypingStartedConnection = Connect(__index(UserInputService, "TextBoxFocused"), function()
	Typing = true
end)

ServiceConnections.TypingEndedConnection = Connect(__index(UserInputService, "TextBoxFocusReleased"), function()
	Typing = false
end)

--// Functions

function Environment.Exit(self) -- METHOD | ExunysDeveloperAimbot:Exit(<void>)
	assert(self, "EXUNYS_AIMBOT-V3.Exit: Missing parameter #1 \"self\" <table>.")
 
	for Index, _ in next, ServiceConnections do
		Disconnect(ServiceConnections[Index])
	end
 
	Load = nil; ConvertVector = nil; CancelLock = nil; GetClosestPlayer = nil; GetRainbowColor = nil; FixUsername = nil
 
	self.FOVCircle:Remove()
	self.FOVCircleOutline:Remove()
	getgenv().ExunysDeveloperAimbot = nil
end

function Environment.Restart() -- ExunysDeveloperAimbot.Restart(<void>)
	for Index, _ in next, ServiceConnections do
		Disconnect(ServiceConnections[Index])
	end
 
	Load()
end

function Environment.Blacklist(self, Username) -- METHOD | ExunysDeveloperAimbot:Blacklist(<string> Player Name)
	assert(self, "EXUNYS_AIMBOT-V3.Blacklist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "EXUNYS_AIMBOT-V3.Blacklist: Missing parameter #2 \"Username\" <string>.")
 
	Username = FixUsername(Username)
 
	assert(self, "EXUNYS_AIMBOT-V3.Blacklist: User "..Username.." couldn't be found.")
 
	self.Blacklisted[#self.Blacklisted + 1] = Username
end

function Environment.Whitelist(self, Username) -- METHOD | ExunysDeveloperAimbot:Whitelist(<string> Player Name)
	assert(self, "EXUNYS_AIMBOT-V3.Whitelist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "EXUNYS_AIMBOT-V3.Whitelist: Missing parameter #2 \"Username\" <string>.")
 
	Username = FixUsername(Username)
 
	assert(Username, "EXUNYS_AIMBOT-V3.Whitelist: User "..Username.." couldn't be found.")
 
	local Index = tablefind(self.Blacklisted, Username)
 
	assert(Index, "EXUNYS_AIMBOT-V3.Whitelist: User "..Username.." is not blacklisted.")
 
	tableremove(self.Blacklisted, Index)
end

function Environment.GetClosestPlayer() -- ExunysDeveloperAimbot.GetClosestPlayer(<void>)
	GetClosestPlayer()
	local Value = Environment.Locked
	CancelLock()
	
	return Value
end

Environment.Load = Load -- ExunysDeveloperAimbot.Load()

setmetatable(Environment, {__call = Load})

return Environment

end

-- Инициализация аимбота
local AimbotScript

local bodyParts = {
    "Head",
    "HumanoidRootPart",
    "LeftHand",
    "RightHand",
    "LeftLowerArm",
    "RightLowerArm",
    "LeftUpperArm",
    "RightUpperArm",
    "LeftLowerLeg",
    "RightLowerLeg",
    "LowerTorso"
}

local translations = {
    Head = "Голова",
    HumanoidRootPart = "Торс",
    LeftHand = "Ліва долоня",
    RightHand = "Права долоня",
    LeftLowerArm = "Лівий лікоть",
    RightLowerArm = "Правий лікоть",
    LeftUpperArm = "Ліве плече",
    RightUpperArm = "Праве плече",
    LeftLowerLeg = "Ліва нога",
    RightLowerLeg = "Права нога",
    LowerTorso = "Член"
}

-- Генерация списка с переводами для отображения
local displayOptions = {}
for _, part in ipairs(bodyParts) do
    table.insert(displayOptions, translations[part])
end

local selectedPart = "Head" -- Значение по умолчанию
UniversalSection:AddDropdown({
    Name = "Виберіть частину тіла",
    Default = translations[selectedPart],
    Options = displayOptions,
    Callback = function(Value)
        -- Найти оригинальное название по переводу
        for original, translation in pairs(translations) do
            if translation == Value then
                selectedPart = original
                break
            end
        end
        getgenv().ExunysDeveloperAimbot.Settings.LockPart = selectedPart
    end
})

-- Убедимся, что LockPart в настройках соответствует значению по умолчанию
getgenv().ExunysDeveloperAimbot.Settings.LockPart = selectedPart

local isAimbotEnabled = false
UniversalTab:AddToggle({
    Name = "Вкл/Викл Аімбот",
    Default = false,
    Callback = function(state)
        isAimbotEnabled = state
        if isAimbotEnabled then
            if not AimbotScript then
                AimbotScript = InitializeAimbot()
            end
            AimbotScript:Load()
        else
            if AimbotScript then
                AimbotScript:Exit()
                AimbotScript = nil
            end
        end
    end
})

-- Проверка и инициализация настроек aimbot
if not getgenv().ExunysDeveloperAimbot then
    getgenv().ExunysDeveloperAimbot = {}
end

if not getgenv().ExunysDeveloperAimbot.FOVSettings then
    getgenv().ExunysDeveloperAimbot.FOVSettings = {
        Radius = 180,  -- Установите значение по умолчанию
        Visible = true
    }
end

-- Инициализация FOVCircle и FOVCircleOutline, если они не существуют
if not getgenv().ExunysDeveloperAimbot.FOVCircle then
    getgenv().ExunysDeveloperAimbot.FOVCircle = {
        Visible = getgenv().ExunysDeveloperAimbot.FOVSettings.Visible
    }
end

if not getgenv().ExunysDeveloperAimbot.FOVCircleOutline then
    getgenv().ExunysDeveloperAimbot.FOVCircleOutline = {
        Visible = getgenv().ExunysDeveloperAimbot.FOVSettings.Visible
    }
end

-- Добавление слайдера для изменения радиуса FOV
UniversalSection:AddSlider({
    Name = "Радіус FOV",
    Min = 50,
    Max = 500,
    Default = getgenv().ExunysDeveloperAimbot.FOVSettings.Radius,
    Increment = 1,
    Callback = function(Value)
        getgenv().ExunysDeveloperAimbot.FOVSettings.Radius = Value
    end
})

-- Добавление переключателя для видимости FOV
UniversalSection:AddToggle({
    Name = "Видимість FOV",
    Default = getgenv().ExunysDeveloperAimbot.FOVSettings.Visible,
    Callback = function(Value)
        getgenv().ExunysDeveloperAimbot.FOVSettings.Visible = Value

        -- Проверяем перед изменением свойства
        if getgenv().ExunysDeveloperAimbot.FOVCircle then
            getgenv().ExunysDeveloperAimbot.FOVCircle.Visible = Value
        else
            warn("FOVCircle is not initialized!")
        end

        if getgenv().ExunysDeveloperAimbot.FOVCircleOutline then
            getgenv().ExunysDeveloperAimbot.FOVCircleOutline.Visible = Value
        else
            warn("FOVCircleOutline is not initialized!")
        end
    end
})

local AimTab = Window:MakeTab({
    Name = "Вх",
    Icon = "rbxassetid://17404114716",
    PremiumOnly = false
})

local ESPEnabled = false
local TracersEnabled = false
local UseTeamColor = false
local UseTeamColorForTracers = false
local OnlyEnemiesForBoxes = false
local OnlyEnemiesForTracers = false

local updateInterval = 0.001
local lastUpdateTime = 0

local function activateESP()
    local plr = game.Players.LocalPlayer
    local camera = game.Workspace.CurrentCamera

    function getTeamColor(player)
        if UseTeamColor and player.Team then
            return player.Team.TeamColor.Color
        else
            return Color3.fromRGB(255, 255, 255)
        end
    end

    function getTracerColor(player)
        if UseTeamColorForTracers and player.Team then
            return player.Team.TeamColor.Color
        else
            return Color3.fromRGB(255, 255, 255)
        end
    end

    local function initializeESP(player)
        local Top = Drawing.new("Line")
        Top.Visible = false
        Top.Color = getTeamColor(player)
        Top.Thickness = 2
        Top.Transparency = 1

        local Bottom = Drawing.new("Line")
        Bottom.Visible = false
        Bottom.Color = getTeamColor(player)
        Bottom.Thickness = 2
        Bottom.Transparency = 1

        local Left = Drawing.new("Line")
        Left.Visible = false
        Left.Color = getTeamColor(player)
        Left.Thickness = 2
        Left.Transparency = 1

        local Right = Drawing.new("Line")
        Right.Visible = false
        Right.Color = getTeamColor(player)
        Right.Thickness = 2
        Right.Transparency = 1

        local Tracer = Drawing.new("Line")
        Tracer.Visible = false
        Tracer.Color = getTracerColor(player)
        Tracer.Thickness = 2
        Tracer.Transparency = 1

        local function updateESP()
            local connection
            connection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
                lastUpdateTime = lastUpdateTime + deltaTime
                if lastUpdateTime < updateInterval then
                    return
                end
                lastUpdateTime = 0

                if not ESPEnabled and not TracersEnabled then
                    Top.Visible = false
                    Left.Visible = false
                    Bottom.Visible = false
                    Right.Visible = false
                    Tracer.Visible = false
                    connection:Disconnect()
                    return
                end

                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Name ~= plr.Name and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local isEnemy = not player.Team or player.Team ~= plr.Team
                    if (OnlyEnemiesForBoxes and not isEnemy) and (OnlyEnemiesForTracers and not isEnemy) then
                        Top.Visible = false
                        Left.Visible = false
                        Bottom.Visible = false
                        Right.Visible = false
                        Tracer.Visible = false
                        return
                    end

                    local teamColor = getTeamColor(player)
                    local tracerColor = getTracerColor(player)
                    Top.Color = teamColor
                    Bottom.Color = teamColor
                    Left.Color = teamColor
                    Right.Color = teamColor
                    Tracer.Color = tracerColor

                    local ScreenPos, OnScreen = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                    if OnScreen then
                        local Scale = player.Character.Head.Size.Y / 2
                        local Size = Vector3.new(2, 3, 0) * (Scale * 2)
                        local TL = camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, 0)).p)
                        local TR = camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, 0)).p)
                        local BL = camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, 0)).p)
                        local BR = camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, 0)).p)

                        Top.From = Vector2.new(TL.X, TL.Y)
                        Top.To = Vector2.new(TR.X, TR.Y)
                        Left.From = Vector2.new(TL.X, TL.Y)
                        Left.To = Vector2.new(BL.X, BL.Y)
                        Right.From = Vector2.new(TR.X, TR.Y)
                        Right.To = Vector2.new(BR.X, BR.Y)
                        Bottom.From = Vector2.new(BL.X, BL.Y)
                        Bottom.To = Vector2.new(BR.X, BR.Y)

                        if TracersEnabled and (not OnlyEnemiesForTracers or isEnemy) then
                            Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                            Tracer.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
                            Tracer.Visible = true
                        else
                            Tracer.Visible = false
                        end

                        Top.Visible = ESPEnabled and (not OnlyEnemiesForBoxes or isEnemy)
                        Left.Visible = ESPEnabled and (not OnlyEnemiesForBoxes or isEnemy)
                        Bottom.Visible = ESPEnabled and (not OnlyEnemiesForBoxes or isEnemy)
                        Right.Visible = ESPEnabled and (not OnlyEnemiesForBoxes or isEnemy)
                    else
                        Top.Visible = false
                        Left.Visible = false
                        Bottom.Visible = false
                        Right.Visible = false
                        Tracer.Visible = false
                    end
                else
                    Top.Visible = false
                    Left.Visible = false
                    Bottom.Visible = false
                    Right.Visible = false
                    Tracer.Visible = false
                    if not game.Players:FindFirstChild(player.Name) then
                        connection:Disconnect()
                    end
                end
            end)
        end

        coroutine.wrap(updateESP)()
    end

    for _, player in pairs(game.Players:GetPlayers()) do
        initializeESP(player)
    end

    game.Players.PlayerAdded:Connect(function(newPlayer)
        newPlayer.CharacterAdded:Connect(function()
            initializeESP(newPlayer)
        end)
    end)
end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local HighlightEnabled = false -- Начальное состояние Highlight (выключено)
local UseTeamColorForHighlight = true -- Использовать ли командные цвета для Highlight
local ShowOnlyEnemies = false -- Переключатель "Тільки противники"
local UpdateInterval = 2 -- Интервал в секундах для регулярной проверки

-- Очистка всех Highlight
local function clearAllHighlights()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            for _, highlight in pairs(player.Character:GetChildren()) do
                if highlight:IsA("Highlight") then
                    highlight:Destroy()
                end
            end
        end
    end
end

-- Создание Highlight
local function createHighlight(player, character)
    -- Пропускаем создание Highlight для самого себя
    if player == localPlayer then
        return
    end

    -- Удаляем старый Highlight
    for _, highlight in pairs(character:GetChildren()) do
        if highlight:IsA("Highlight") then
            highlight:Destroy()
        end
    end

    -- Создаём новый Highlight
    local highlight = Instance.new("Highlight")
    highlight.Archivable = true
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = true

    -- Устанавливаем цвет на основе команды или стандартный
    if UseTeamColorForHighlight and player.Team then
        highlight.FillColor = player.Team.TeamColor.Color
    else
        highlight.FillColor = Color3.fromRGB(255, 0, 4)
    end

    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = character
end

-- Фильтрация игроков по командам
local function filterPlayersByTeam()
    local filteredPlayers = {}

    for _, player in pairs(Players:GetPlayers()) do
        if ShowOnlyEnemies then
            -- Показываем только противников
            if player.Team ~= localPlayer.Team then
                table.insert(filteredPlayers, player)
            end
        else
            -- Показываем всех
            table.insert(filteredPlayers, player)
        end
    end

    return filteredPlayers
end

-- Функция для расчета расстояния
local function calculateDistance(player)
    if player.Character and player.Character.PrimaryPart then
        return (player.Character.PrimaryPart.Position - localPlayer.Character.PrimaryPart.Position).Magnitude
    end
    return math.huge -- если нет персонажа, возвращаем большое значение
end

-- Обновление Highlight
local function applyDynamicHighlight()
    if not HighlightEnabled then return end

    local players = filterPlayersByTeam()

    -- Сортируем игроков по расстоянию
    table.sort(players, function(a, b)
        return calculateDistance(a) < calculateDistance(b)
    end)

    -- Применяем Highlight игрокам
    for _, player in pairs(players) do
        if player.Character then
            createHighlight(player, player.Character)
        end
    end
end

-- Постоянный мониторинг персонажей
local function monitorCharacters()
    while HighlightEnabled do
        applyDynamicHighlight()
        wait(UpdateInterval)
    end
end

-- Включение Highlight
local function activateHighlight()
    HighlightEnabled = true
    clearAllHighlights()
    task.spawn(monitorCharacters)
end

-- Отключение Highlight
local function deactivateHighlight()
    HighlightEnabled = false
    clearAllHighlights()
end

local Section = AimTab:AddSection({
    Name = "ESP налаштування"
})

-- Флаги для управления ESP
local NameDisplayEnabled = false
local DistanceDisplayEnabled = false

-- Переключатель для отображения имён
AimTab:AddToggle({
    Name = "Відобразити імена",
    Default = false,
    Callback = function(value)
        NameDisplayEnabled = value
        if not value then
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player.Character then
                    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        local existingGui = rootPart:FindFirstChild("NameGui")
                        if existingGui then
                            existingGui:Destroy()
                        end
                    end
                end
            end
        end
    end
})

-- Переключатель для отображения расстояний
AimTab:AddToggle({
    Name = "Відображати відстань",
    Default = false,
    Callback = function(value)
        DistanceDisplayEnabled = value
        if not value then
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player.Character then
                    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        local existingGui = rootPart:FindFirstChild("DistanceGui")
                        if existingGui then
                            existingGui:Destroy()
                        end
                    end
                end
            end
        end
    end
})

-- Функция для отображения имени
local LocalPlayer = game.Players.LocalPlayer

local function updateNameGui(player)
    if player == LocalPlayer then return end

    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart", 5)
    if not rootPart then return end

    local existingGui = rootPart:FindFirstChild("NameGui")
    if NameDisplayEnabled then
        if not existingGui then
            local billboardGui = Instance.new("BillboardGui", rootPart)
            billboardGui.Name = "NameGui"
            billboardGui.Adornee = rootPart
            billboardGui.Size = UDim2.new(4, 0, 1, 0)
            billboardGui.StudsOffset = Vector3.new(0, 3.5, 0)
            billboardGui.AlwaysOnTop = true

            local textLabel = Instance.new("TextLabel", billboardGui)
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = Color3.new(1, 1, 1)
            textLabel.TextStrokeTransparency = 0.5
            textLabel.Font = Enum.Font.GothamBold
            textLabel.TextScaled = true
            textLabel.Text = player.Name
        end
    elseif existingGui then
        existingGui:Destroy()
    end
end

local function updateDistanceGui(player)
    if player == LocalPlayer then return end

    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart", 5)
    if not rootPart then return end

    local existingGui = rootPart:FindFirstChild("DistanceGui")
    if DistanceDisplayEnabled then
        if not existingGui then
            local billboardGui = Instance.new("BillboardGui", rootPart)
            billboardGui.Name = "DistanceGui"
            billboardGui.Adornee = rootPart
            billboardGui.Size = UDim2.new(4, 0, 1, 0)
            billboardGui.StudsOffset = Vector3.new(0, -4, 0)
            billboardGui.AlwaysOnTop = true

            local textLabel = Instance.new("TextLabel", billboardGui)
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = Color3.new(1, 1, 1)
            textLabel.TextStrokeTransparency = 0.5
            textLabel.Font = Enum.Font.GothamBold
            textLabel.TextScaled = true
        end

        local billboardGui = rootPart:FindFirstChild("DistanceGui")
        local textLabel = billboardGui:FindFirstChildOfClass("TextLabel")
        if textLabel then
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
            textLabel.Text = string.format("%.1f", distance)
        end
    elseif existingGui then
        existingGui:Destroy()
    end
end

-- Обновление всех имен и расстояний
local function updateAllNames()
    for _, player in ipairs(game.Players:GetPlayers()) do
        updateNameGui(player)
    end
end

local function updateAllDistances()
    for _, player in ipairs(game.Players:GetPlayers()) do
        updateDistanceGui(player)
    end
end

-- Подключение событий
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        updateNameGui(player)
        updateDistanceGui(player)
    end)
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if NameDisplayEnabled then
        updateAllNames()
    end
    if DistanceDisplayEnabled then
        updateAllDistances()
    end
end)

local Section = AimTab:AddSection({
    Name = "Бокс"
})

AimTab:AddToggle({
    Name = "Бокс",
    Default = false,
    Callback = function(state)
        ESPEnabled = state
        if ESPEnabled then
            activateESP()
        end
    end
})

AimTab:AddToggle({
    Name = "Колір команди (Якщо є)",
    Default = false,
    Callback = function(state)
        UseTeamColor = state
    end
})

AimTab:AddToggle({
    Name = "Тільки противники",
    Default = false,
    Callback = function(state)
        OnlyEnemiesForBoxes = state
    end
})

local Section = AimTab:AddSection({
    Name = "Трейсери"
})

AimTab:AddToggle({
    Name = "Трейсери",
    Default = false,
    Callback = function(state)
        TracersEnabled = state
        if TracersEnabled then
            activateESP()
        end
    end
})

AimTab:AddToggle({
    Name = "Колір команди (Якщо є)",
    Default = false,
    Callback = function(state)
        UseTeamColorForTracers = state
    end
})

AimTab:AddToggle({
    Name = "Тільки противники",
    Default = false,
    Callback = function(state)
        OnlyEnemiesForTracers = state
    end
})

local Section = AimTab:AddSection({
    Name = "Виділення"
})

AimTab:AddToggle({
    Name = "Виділення",
    Default = false,
    Callback = function(state)
        HighlightEnabled = state
        if HighlightEnabled then
            activateHighlight()
        else
            deactivateHighlight()
        end
    end
})

AimTab:AddToggle({
    Name = "Колір команди (Якщо є)",
    Default = false,
    Callback = function(state)
        UseTeamColorForHighlight = state
        if HighlightEnabled then
            deactivateHighlight()
            activateHighlight()
        end
    end
})

AimTab:AddToggle({
    Name = "Тільки противники",
    Default = false,
    Callback = function(state)
        ShowOnlyEnemies = state
        if HighlightEnabled then
            deactivateHighlight()
            activateHighlight()
        end
    end
})

-- Создаем вкладку "Телепорт"
local TPTab = Window:MakeTab({ 
    Name = "Телепорт", 
    Icon = "rbxassetid://17404114716",
    PremiumOnly = false
})

-- Добавляем секцию "Телепорт"
local Section = TPTab:AddSection({ 
    Name = "Телепорт" 
})

-- Переменная для выбранного игрока
local selectedPlayer = nil

-- Создаем дропдаун для списка игроков
local playerDropdown
local function updatePlayerList()
    local players = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        table.insert(players, player.Name)
    end
    if playerDropdown then
        playerDropdown:Refresh(players, true)
    else
        playerDropdown = Section:AddDropdown({
            Name = "Виберіть гравця",
            Options = players,
            Default = "None",
            Callback = function(selected)
                selectedPlayer = selected
            end
        })
    end
end

-- Обновляем список игроков при подключении/отключении
updatePlayerList()
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)

-- Кнопка для телепортации
Section:AddButton({
    Name = "Телепортувати",
    Callback = function()
        local Players = game:GetService("Players")
        local targetPlayer = Players:FindFirstChild(selectedPlayer)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local localPlayer = Players.LocalPlayer
            local localCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
            local localHRP = localCharacter:FindFirstChild("HumanoidRootPart")

            if localHRP then
                localHRP.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            end
        else
            warn("Цього гравця не знайдено або його персонаж недоступний.")
        end
    end
})

-- Переменные
local UIS = game:GetService("UserInputService")
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

local TPEnabled = false -- Переменная для переключателя состояния

-- Функция получения персонажа
function GetCharacter()
    return Player.Character
end

-- Функция телепортации
function Teleport(pos)
    local Char = GetCharacter()
    if Char then
        Char:MoveTo(pos)
    end
end

Section:AddToggle({
    Name = "TP на кліку (Ctrl + ЛКМ)",
    Default = false,
    Callback = function(value)
        TPEnabled = value
    end
})

-- Обработка нажатия клавиш
UIS.InputBegan:Connect(function(input)
    if TPEnabled then
        if input.UserInputType == Enum.UserInputType.MouseButton1 and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            Teleport(Mouse.Hit.p)
        end
    end
end)

-- Инициализация UI элементов
local FlingTab = Window:MakeTab({
    Name = "Флінг",
    Icon = "rbxassetid://17404114716",
    PremiumOnly = false
})

-- Создаем динамический список игроков
local playerDropdown
local function updatePlayerList()
    local players = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        table.insert(players, player.Name)
    end
    if playerDropdown then
        playerDropdown:Refresh(players, true)
    else
        playerDropdown = FlingTab:AddDropdown({
            Name = "Виберіть гравця",
            Options = players,
            Default = "None",
            Callback = function(selected)
                selectedPlayer = selected
            end
        })
    end
end

-- Обновляем список игроков при подключении/отключении
updatePlayerList()
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)

-- Создаем кнопку для выполнения флинга
FlingTab:AddButton({
    Name = "Флінг",
    Callback = function()
        if selectedPlayer then
            local playerToFling = game:GetService("Players"):FindFirstChild(selectedPlayer)
            if playerToFling then
                miniFling(playerToFling)
            else
                warn("Гравця не знайдено")
            end
        else
            warn("Виберіть гравця для флінгу")
        end
    end
})

-- Функция флинга
function miniFling(playerToFling)
    local a = game.Players.LocalPlayer
    local b = a:GetMouse()
    local c = {playerToFling}
    local d = game:GetService("Players")
    local e = d.LocalPlayer
    local f = false

    local g = function(h)
        local i = e.Character
        local j = i and i:FindFirstChildOfClass("Humanoid")
        local k = j and j.RootPart
        local l = h.Character
        local m, n, o, p, q
        if l:FindFirstChildOfClass("Humanoid") then m = l:FindFirstChildOfClass("Humanoid") end
        if m and m.RootPart then n = m.RootPart end
        if l:FindFirstChild("Head") then o = l.Head end
        if l:FindFirstChildOfClass("Accessory") then p = l:FindFirstChildOfClass("Accessory") end
        if p and p:FindFirstChild("Handle") then q = p.Handle end

        if i and j and k then
            if k.Velocity.Magnitude < 50 then getgenv().OldPos = k.CFrame end
        end
        if m and m.Sit and not f then end
        if o then
            if o.Velocity.Magnitude > 500 then
                fu.dialog("Player flung", "Player is already flung. Fling again?", {"Fling again", "No"})
                if fu.waitfordialog() == "No" then return fu.closedialog() end
                fu.closedialog()
            end
        elseif not o and q then
            if q.Velocity.Magnitude > 500 then
                fu.dialog("Player flung", "Player is already flung. Fling again?", {"Fling again", "No"})
                if fu.waitfordialog() == "No" then return fu.closedialog() end
                fu.closedialog()
            end
        end
        if o then
            workspace.CurrentCamera.CameraSubject = o
        elseif not o and q then
            workspace.CurrentCamera.CameraSubject = q
        elseif m and n then
            workspace.CurrentCamera.CameraSubject = m
        end
        if not l:FindFirstChildWhichIsA("BasePart") then return end

        local r = function(s, t, u)
            k.CFrame = CFrame.new(s.Position) * t * u
            i:SetPrimaryPartCFrame(CFrame.new(s.Position) * t * u)
            k.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            k.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local v = function(s)
            local w = 2
            local x = tick()
            local y = 0
            repeat
                if k and m then
                    if s.Velocity.Magnitude < 50 then
                        y = y + 100
                        r(s, CFrame.new(0, 1.5, 0) + m.MoveDirection * s.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(y), 0, 0))
                        task.wait()
                        r(s, CFrame.new(0, -1.5, 0) + m.MoveDirection * s.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(y), 0, 0))
                        task.wait()
                        r(s, CFrame.new(2.25, 1.5, -2.25) + m.MoveDirection * s.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(y), 0, 0))
                        task.wait()
                        r(s, CFrame.new(-2.25, -1.5, 2.25) + m.MoveDirection * s.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(y), 0, 0))
                        task.wait()
                        r(s, CFrame.new(0, 1.5, 0) + m.MoveDirection, CFrame.Angles(math.rad(y), 0, 0))
                        task.wait()
                        r(s, CFrame.new(0, -1.5, 0) + m.MoveDirection, CFrame.Angles(math.rad(y), 0, 0))
                        task.wait()
                    else
                        r(s, CFrame.new(0, 1.5, m.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        r(s, CFrame.new(0, -1.5, -m.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        r(s, CFrame.new(0, 1.5, m.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        r(s, CFrame.new(0, 1.5, n.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        r(s, CFrame.new(0, -1.5, -n.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                        task.wait()
                        r(s, CFrame.new(0, 1.5, n.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        r(s, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        r(s, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        r(s, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                        task.wait()
                        r(s, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                else
                    break
                end
            until s.Velocity.Magnitude > 500 or s.Parent ~= h.Character or h.Parent ~= d or h.Character ~= l or m.Sit or j.Health <= 0 or tick() > x + w
        end

        workspace.FallenPartsDestroyHeight = 0 / 0
        local z = Instance.new("BodyVelocity")
        z.Name = "EpixVel"
        z.Parent = k
        z.Velocity = Vector3.new(9e8, 9e8, 9e8)
        z.MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)
        j:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        if n and o then
            if (n.CFrame.p - o.CFrame.p).Magnitude > 5 then
                v(o)
            else
                v(n)
            end
        elseif n and not o then
            v(n)
        elseif not n and o then
            v(o)
        elseif not n and not o and p and q then
            v(q)
        else
            fu.notification("Не вдається знайти належну частину цього гравця, щоб зафлінгити.")
        end
        z:Destroy()
        j:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = j
        repeat
            k.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
            i:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
            j:ChangeState("GettingUp")
            table.foreach(i:GetChildren(), function(A, B)
                if B:IsA("BasePart") then
                    B.Velocity, B.RotVelocity = Vector3.new(), Vector3.new()
                end
            end)
            task.wait()
        until (k.Position - getgenv().OldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    end

    g(c[1])
end

local EmoteTab = Window:MakeTab({ 
    Name = "Емоції", 
    Icon = "rbxassetid://17404114716",
    PremiumOnly = false
})

local Section = EmoteTab:AddSection({ 
    Name = "Емоції" 
})

Section:AddButton({
    Name = "Включити скрипт із емоціями",
    Default = false,
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Порада!",
            Text = "Зачекайте 1–15 секунд, щоб відобразити графічний інтерфейс. Якщо він не з’являється, спробуйте виконати ще раз.",
             Duration = 15})

if game:GetService("CoreGui"):FindFirstChild("Emotes") then
game:GetService("CoreGui"):FindFirstChild("Emotes"):Destroy()
end

wait(1)

local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local Open = Instance.new("TextButton")
UICorner = Instance.new("UICorner")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local Emotes = {}
local LoadedEmotes = {}
local function AddEmote(name: string, id: IntValue, price: IntValue?)
LoadedEmotes[id] = false
task.spawn(function()
    if not (name and id) then
        return
    end
    local success, date = pcall(function()
        local info = MarketplaceService:GetProductInfo(id)
        local updated = info.Updated
        return DateTime.fromIsoDate(updated):ToUniversalTime()
    end)
    if not success then
        task.wait(10)
        AddEmote(name, id, price)
        return
    end
    local unix = os.time({
        year = date.Year,
        month = date.Month,
        day = date.Day,
        hour = date.Hour,
        min = date.Minute,
        sec = date.Second
    })
    LoadedEmotes[id] = true
    table.insert(Emotes, {
        ["name"] = name,
        ["id"] = id,
        ["icon"] = "rbxthumb://type=Asset&id=".. id .."&w=150&h=150",
        ["price"] = price or 0,
        ["lastupdated"] = unix,
        ["sort"] = {}
    })
end)
end
local CurrentSort = "recentfirst"

local FavoriteOff = "rbxassetid://10651060677"
local FavoriteOn = "rbxassetid://10651061109"
local FavoritedEmotes = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Emotes"
ScreenGui.DisplayOrder = 2
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Enabled = true

local BackFrame = Instance.new("Frame")
BackFrame.Size = UDim2.new(0.9, 0, 0.5, 0)
BackFrame.AnchorPoint = Vector2.new(0.5, 0.5)
BackFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
BackFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY
BackFrame.BackgroundTransparency = 1
BackFrame.BorderSizePixel = 0
BackFrame.Parent = ScreenGui

Open.Name = "Open"
Open.Parent = ScreenGui
Open.Draggable = true
Open.Size = UDim2.new(0.05,0,0.114,0)
Open.Position = UDim2.new(0.05, 0, 0.25, 0)
Open.Text = "Закрити"
Open.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Open.TextColor3 = Color3.fromRGB(255, 255, 255)
Open.TextScaled = true
Open.TextSize = 20
Open.Visible = true
Open.BackgroundTransparency = .5
Open.MouseButton1Up:Connect(function()
if Open.Text == "Відкрити" then
    Open.Text = "Закрити"
    BackFrame.Visible = true
else
    if Open.Text == "Закрити" then
        Open.Text = "Відкрити"
        BackFrame.Visible = false
    end
end
end)

UICorner.Name = "UICorner"
UICorner.Parent = Open
UICorner.CornerRadius = UDim.new(1, 0)

local EmoteName = Instance.new("TextLabel")
EmoteName.Name = "EmoteName"
EmoteName.TextScaled = true
EmoteName.AnchorPoint = Vector2.new(0.5, 0.5)
EmoteName.Position = UDim2.new(-0.1, 0, 0.5, 0)
EmoteName.Size = UDim2.new(0.2, 0, 0.2, 0)
EmoteName.SizeConstraint = Enum.SizeConstraint.RelativeYY
EmoteName.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
EmoteName.TextColor3 = Color3.new(1, 1, 1)
EmoteName.BorderSizePixel = 0
EmoteName.Parent = BackFrame

local Corner = Instance.new("UICorner")
Corner.Parent = EmoteName

local Loading = Instance.new("TextLabel", BackFrame)
Loading.AnchorPoint = Vector2.new(0.5, 0.5)
Loading.Text = "Завантаження..."
Loading.TextColor3 = Color3.new(1, 1, 1)
Loading.BackgroundColor3 = Color3.new(0, 0, 0)
Loading.TextScaled = true
Loading.BackgroundTransparency = 0.5
Loading.Size = UDim2.fromScale(0.2, 0.1)
Loading.Position = UDim2.fromScale(0.5, 0.2)
Corner:Clone().Parent = Loading

local Frame = Instance.new("ScrollingFrame")
Frame.Size = UDim2.new(1, 0, 1, 0)
Frame.CanvasSize = UDim2.new(0, 0, 0, 0)
Frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Frame.ScrollingDirection = Enum.ScrollingDirection.Y
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.BackgroundTransparency = 1
Frame.ScrollBarThickness = 5
Frame.BorderSizePixel = 0
Frame.MouseLeave:Connect(function()
EmoteName.Text = "Виберіть емодзі"
end)
Frame.Parent = BackFrame

local Grid = Instance.new("UIGridLayout")
Grid.CellSize = UDim2.new(0.105, 0, 0, 0)
Grid.CellPadding = UDim2.new(0.006, 0, 0.006, 0)
Grid.SortOrder = Enum.SortOrder.LayoutOrder
Grid.Parent = Frame

local SortFrame = Instance.new("Frame")
SortFrame.Visible = false
SortFrame.BorderSizePixel = 0
SortFrame.Position = UDim2.new(1, 5, -0.125, 0)
SortFrame.Size = UDim2.new(0.2, 0, 0, 0)
SortFrame.AutomaticSize = Enum.AutomaticSize.Y
SortFrame.BackgroundTransparency = 1
Corner:Clone().Parent = SortFrame
SortFrame.Parent = BackFrame

local SortList = Instance.new("UIListLayout")
SortList.Padding = UDim.new(0.02, 0)
SortList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SortList.VerticalAlignment = Enum.VerticalAlignment.Top
SortList.SortOrder = Enum.SortOrder.LayoutOrder
SortList.Parent = SortFrame

local function SortEmotes()
for i,Emote in pairs(Emotes) do
    local EmoteButton = Frame:FindFirstChild(Emote.id)
    if not EmoteButton then
        continue
    end
    local IsFavorited = table.find(FavoritedEmotes, Emote.id)
    EmoteButton.LayoutOrder = Emote.sort[CurrentSort] + ((IsFavorited and 0) or #Emotes)
    EmoteButton.number.Text = Emote.sort[CurrentSort]
end
end

local function createsort(order, text, sort)
local CreatedSort = Instance.new("TextButton")
CreatedSort.SizeConstraint = Enum.SizeConstraint.RelativeXX
CreatedSort.Size = UDim2.new(1, 0, 0.2, 0)
CreatedSort.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CreatedSort.LayoutOrder = order
CreatedSort.TextColor3 = Color3.new(1, 1, 1)
CreatedSort.Text = text
CreatedSort.TextScaled = true
CreatedSort.BorderSizePixel = 0
Corner:Clone().Parent = CreatedSort
CreatedSort.Parent = SortFrame
CreatedSort.MouseButton1Click:Connect(function()
    SortFrame.Visible = false
    Open.Text = "Відкрити"
    CurrentSort = sort
    SortEmotes()
end)
return CreatedSort
end

createsort(1, "Recently Updated First", "recentfirst")
createsort(2, "Recently Updated Last", "recentlast")
createsort(3, "Alphabetically First", "alphabeticfirst")
createsort(4, "Alphabetically Last", "alphabeticlast")
createsort(5, "Highest Price", "highestprice")
createsort(6, "Lowest Price", "lowestprice")

local SortButton = Instance.new("TextButton")
SortButton.BorderSizePixel = 0
SortButton.AnchorPoint = Vector2.new(0.5, 0.5)
SortButton.Position = UDim2.new(0.925, -5, -0.075, 0)
SortButton.Size = UDim2.new(0.15, 0, 0.1, 0)
SortButton.TextScaled = true
SortButton.TextColor3 = Color3.new(1, 1, 1)
SortButton.BackgroundColor3 = Color3.new(0, 0, 0)
SortButton.BackgroundTransparency = 0.3
SortButton.Text = "Фільтр"
SortButton.MouseButton1Click:Connect(function()
SortFrame.Visible = not SortFrame.Visible
Open.Text = "Відкрити"
end)
Corner:Clone().Parent = SortButton
SortButton.Parent = BackFrame

local CloseButton = Instance.new("TextButton")
CloseButton.BorderSizePixel = 0
CloseButton.AnchorPoint = Vector2.new(0.5, 0.5)
CloseButton.Position = UDim2.new(0.075, 0, -0.075, 0)
CloseButton.Size = UDim2.new(0.15, 0, 0.1, 0)
CloseButton.TextScaled = true
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.BackgroundColor3 = Color3.new(0.5, 0, 0)
CloseButton.BackgroundTransparency = 0.3
CloseButton.Text = "Закрити GUI"
CloseButton.MouseButton1Click:Connect(function()
ScreenGui:Destroy()
end)
Corner:Clone().Parent = CloseButton
CloseButton.Parent = BackFrame

local SearchBar = Instance.new("TextBox")
SearchBar.Text = "Пошук"
SearchBar.BorderSizePixel = 0
SearchBar.AnchorPoint = Vector2.new(0.5, 0.5)
SearchBar.Position = UDim2.new(0.5, 0, -0.075, 0)
SearchBar.Size = UDim2.new(0.55, 0, 0.1, 0)
SearchBar.TextScaled = true
SearchBar.PlaceholderText = "Пошук"
SearchBar.TextColor3 = Color3.new(1, 1, 1)
SearchBar.BackgroundColor3 = Color3.new(0, 0, 0)
SearchBar.BackgroundTransparency = 0.3
SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
local text = SearchBar.Text:lower()
local buttons = Frame:GetChildren()
if text ~= text:sub(1,50) then
    SearchBar.Text = SearchBar.Text:sub(1,50)
    text = SearchBar.Text:lower()
end
if text ~= ""  then
    for i,button in pairs(buttons) do
        if button:IsA("GuiButton") then
            local name = button:GetAttribute("name"):lower()
            if name:match(text) then
                button.Visible = true
            else
                button.Visible = false
            end
        end
    end
else
    for i,button in pairs(buttons) do
        if button:IsA("GuiButton") then
            button.Visible = true
        end
    end
end
end)
Corner:Clone().Parent = SearchBar
SearchBar.Parent = BackFrame

local function openemotes(name, state, input)
if state == Enum.UserInputState.Begin then
    BackFrame.Visible = not BackFrame.Visible
    Open.Text = "Відкрити"
end
end

ContextActionService:BindCoreActionAtPriority(
"Emote Menu",
openemotes,
true,
2001,
Enum.KeyCode.Comma
)

local inputconnect
ScreenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
if BackFrame.Visible == false then
    EmoteName.Text = "Виберіть емодзі"
    SearchBar.Text = ""
    SortFrame.Visible = false
    GuiService:SetEmotesMenuOpen(false)
    inputconnect = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed then
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                BackFrame.Visible = false
                Open.Text = "Відкрити"
            end
        end
    end)
else
    inputconnect:Disconnect()
end
end)

GuiService.EmotesMenuOpenChanged:Connect(function(isopen)
if isopen then
    BackFrame.Visible = false
    Open.Text = "Відкрити"
end
end)

GuiService.MenuOpened:Connect(function()
BackFrame.Visible = false
Open.Text = "Відкрити"
end)

if not game:IsLoaded() then
game.Loaded:Wait()
end

--thanks inf yield
local SynV3 = syn and DrawingImmediate
if (not is_sirhurt_closure) and (not SynV3) and (syn and syn.protect_gui) then
syn.protect_gui(ScreenGui)
ScreenGui.Parent = CoreGui
elseif get_hidden_gui or gethui then
local hiddenUI = get_hidden_gui or gethui
ScreenGui.Parent = hiddenUI()
else
ScreenGui.Parent = CoreGui
end

local function SendNotification(title, text)
if syn and syn.toast_notification then
    syn.toast_notification({
        Type = ToastType.Error,
        Title = title,
        Content = text
    })
else
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text
    })
end
end

local LocalPlayer = Players.LocalPlayer

local function PlayEmote(name: string, id: IntValue)
BackFrame.Visible = false
Open.Text = "Відкрити"
SearchBar.Text = ""
local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
local Description = Humanoid and Humanoid:FindFirstChildOfClass("HumanoidDescription")
if not Description then
    return
end
if LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R6 then
    local succ, err = pcall(function()
        Humanoid:PlayEmoteAndGetAnimTrackById(id)
    end)
    if not succ then
        Description:AddEmote(name, id)
        Humanoid:PlayEmoteAndGetAnimTrackById(id)
    end
else
    SendNotification(
        "R6? лол",
        "Тобі треба бути R15"
    )
end
end

local function WaitForChildOfClass(parent, class)
local child = parent:FindFirstChildOfClass(class)
while not child or child.ClassName ~= class do
    child = parent.ChildAdded:Wait()
end
return child
end

local Cursor = ""
while true do
local function Request()
    local success, Response = pcall(function()
        return game:HttpGetAsync("https://catalog.roblox.com/v1/search/items/details?Category=12&Subcategory=39&SortType=1&SortAggregation=&limit=30&IncludeNotForSale=true&cursor=".. Cursor)
    end)
    if not success then
        task.wait(10)
        return Request()
    end
    return Response
end
local Response = Request()
local Body = HttpService:JSONDecode(Response)
for i,v in pairs(Body.data) do
    AddEmote(v.name, v.id, v.price)
end
if Body.nextPageCursor ~= nil then
    Cursor = Body.nextPageCursor
else
    break
end
end

--unreleased emotes
AddEmote("Arm Wave", 5915773155)
AddEmote("Head Banging", 5915779725)
AddEmote("Face Calisthenics", 9830731012)

--wait for emotes to finish loading

local function EmotesLoaded()
for i, loaded in pairs(LoadedEmotes) do
    if not loaded then
        return false
    end
end
return true
end
while not EmotesLoaded() do
task.wait()
end
Loading:Destroy()

--sorting options setup
table.sort(Emotes, function(a, b)
return a.lastupdated > b.lastupdated
end)
for i,v in pairs(Emotes) do
v.sort.recentfirst = i
end

table.sort(Emotes, function(a, b)
return a.lastupdated < b.lastupdated
end)
for i,v in pairs(Emotes) do
v.sort.recentlast = i
end

table.sort(Emotes, function(a, b)
return a.name:lower() < b.name:lower()
end)
for i,v in pairs(Emotes) do
v.sort.alphabeticfirst = i
end

table.sort(Emotes, function(a, b)
return a.name:lower() > b.name:lower()
end)
for i,v in pairs(Emotes) do
v.sort.alphabeticlast = i
end

table.sort(Emotes, function(a, b)
return a.price < b.price
end)
for i,v in pairs(Emotes) do
v.sort.lowestprice = i
end

table.sort(Emotes, function(a, b)
return a.price > b.price
end)
for i,v in pairs(Emotes) do
v.sort.highestprice = i
end

if isfile("FavoritedEmotes.txt") then
if not pcall(function()
    FavoritedEmotes = HttpService:JSONDecode(readfile("FavoritedEmotes.txt"))
end) then
    FavoritedEmotes = {}
end
else
writefile("FavoritedEmotes.txt", HttpService:JSONEncode(FavoritedEmotes))
end

local UpdatedFavorites = {}
for i,name in pairs(FavoritedEmotes) do
if typeof(name) == "string" then
    for i,emote in pairs(Emotes) do
        if emote.name == name then
            table.insert(UpdatedFavorites, emote.id)
            break
        end
    end
end
end
if #UpdatedFavorites ~= 0 then
FavoritedEmotes = UpdatedFavorites
writefile("FavoritedEmotes.txt", HttpService:JSONEncode(FavoritedEmotes))
end

local function CharacterAdded(Character)
for i,v in pairs(Frame:GetChildren()) do
    if not v:IsA("UIGridLayout") then
        v:Destroy()
    end
end
local Humanoid = WaitForChildOfClass(Character, "Humanoid")
local Description = Humanoid:WaitForChild("HumanoidDescription", 5) or Instance.new("HumanoidDescription", Humanoid)
local random = Instance.new("TextButton")
local Ratio = Instance.new("UIAspectRatioConstraint")
Ratio.AspectType = Enum.AspectType.ScaleWithParentSize
Ratio.Parent = random
random.LayoutOrder = 0
random.TextColor3 = Color3.new(1, 1, 1)
random.BorderSizePixel = 0
random.BackgroundTransparency = 0.5
random.BackgroundColor3 = Color3.new(0, 0, 0)
random.TextScaled = true
random.Text = "Рандом"
random:SetAttribute("name", "")
Corner:Clone().Parent = random
random.MouseButton1Click:Connect(function()
    local randomemote = Emotes[math.random(1, #Emotes)]
    PlayEmote(randomemote.name, randomemote.id)
end)
random.MouseEnter:Connect(function()
    EmoteName.Text = "Рандом"
end)
random.Parent = Frame
for i,Emote in pairs(Emotes) do
    Description:AddEmote(Emote.name, Emote.id)
    local EmoteButton = Instance.new("ImageButton")
    local IsFavorited = table.find(FavoritedEmotes, Emote.id)
    EmoteButton.LayoutOrder = Emote.sort[CurrentSort] + ((IsFavorited and 0) or #Emotes)
    EmoteButton.Name = Emote.id
    EmoteButton:SetAttribute("name", Emote.name)
    Corner:Clone().Parent = EmoteButton
    EmoteButton.Image = Emote.icon
    EmoteButton.BackgroundTransparency = 0.5
    EmoteButton.BackgroundColor3 = Color3.new(0, 0, 0)
    EmoteButton.BorderSizePixel = 0
    Ratio:Clone().Parent = EmoteButton
    local EmoteNumber = Instance.new("TextLabel")
    EmoteNumber.Name = "number"
    EmoteNumber.TextScaled = true
    EmoteNumber.BackgroundTransparency = 1
    EmoteNumber.TextColor3 = Color3.new(1, 1, 1)
    EmoteNumber.BorderSizePixel = 0
    EmoteNumber.AnchorPoint = Vector2.new(0.5, 0.5)
    EmoteNumber.Size = UDim2.new(0.2, 0, 0.2, 0)
    EmoteNumber.Position = UDim2.new(0.1, 0, 0.9, 0)
    EmoteNumber.Text = Emote.sort[CurrentSort]
    EmoteNumber.TextXAlignment = Enum.TextXAlignment.Center
    EmoteNumber.TextYAlignment = Enum.TextYAlignment.Center
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Transparency = 0.5
    UIStroke.Parent = EmoteNumber
    EmoteNumber.Parent = EmoteButton
    EmoteButton.Parent = Frame
    EmoteButton.MouseButton1Click:Connect(function()
        PlayEmote(Emote.name, Emote.id)
    end)
    EmoteButton.MouseEnter:Connect(function()
        EmoteName.Text = Emote.name
    end)
    local Favorite = Instance.new("ImageButton")
    Favorite.Name = "favorite"
    if table.find(FavoritedEmotes, Emote.id) then
        Favorite.Image = FavoriteOn
    else
        Favorite.Image = FavoriteOff
    end
    Favorite.AnchorPoint = Vector2.new(0.5, 0.5)
    Favorite.Size = UDim2.new(0.2, 0, 0.2, 0)
    Favorite.Position = UDim2.new(0.9, 0, 0.9, 0)
    Favorite.BorderSizePixel = 0
    Favorite.BackgroundTransparency = 1
    Favorite.Parent = EmoteButton
    Favorite.MouseButton1Click:Connect(function()
        local index = table.find(FavoritedEmotes, Emote.id)
        if index then
            table.remove(FavoritedEmotes, index)
            Favorite.Image = FavoriteOff
            EmoteButton.LayoutOrder = Emote.sort[CurrentSort] + #Emotes
        else
            table.insert(FavoritedEmotes, Emote.id)
            Favorite.Image = FavoriteOn
            EmoteButton.LayoutOrder = Emote.sort[CurrentSort]
        end
        writefile("FavoritedEmotes.txt", HttpService:JSONEncode(FavoritedEmotes))
    end)
end
for i=1,9 do
    local EmoteButton = Instance.new("Frame")
    EmoteButton.LayoutOrder = 2147483647
    EmoteButton.Name = "filler"
    EmoteButton.BackgroundTransparency = 1
    EmoteButton.BorderSizePixel = 0
    Ratio:Clone().Parent = EmoteButton
    EmoteButton.Visible = true
    EmoteButton.Parent = Frame
    EmoteButton.MouseEnter:Connect(function()
        EmoteName.Text = "Виберіть емодзі"
    end)
end
end

if LocalPlayer.Character then
CharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(CharacterAdded)

wait(1)

game.CoreGui.Emotes.Enabled = true

game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Готово!",
            Text = "Графічний інтерфейс емодзі готовий!",
             Duration = 10})

game.Players.LocalPlayer.PlayerGui.ContextActionGui:Destroy()
    end
})

local Section = EmoteTab:AddSection({ 
    Name = "-- Русорезік --" 
})

local RusoresScript = nil -- Скрипт пока не загружается
local scriptExecuted = false -- Флаг, указывающий, был ли скрипт уже запущен

EmoteTab:AddButton({
    Name = "Резать",
    Default = false,
    Callback = function()
        if scriptExecuted then
            return
        end

        -- Загружаем скрипт, если он еще не был загружен
        if not RusoresScript then
            RusoresScript = loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
        end

        -- Запускаем скрипт
        pcall(function()
            RusoresScript:Load()
        end)

        -- После первого запуска "удаляем" RusoresScript и блокируем повторный запуск
        RusoresScript = nil
        scriptExecuted = true -- Устанавливаем флаг, что скрипт был запущен
    end
})

local NonameTab = Window:MakeTab({ 
    Name = "Індивідуальні\n     скріпти", 
    Icon = "rbxassetid://17404114716",
    PremiumOnly = false
})

local Section = NonameTab:AddSection({ 
    Name = "Плейси, на які індивідуально зроблені скріпти" 
})

local scriptLoaded = false

NonameTab:AddButton({
    Name = "Murder Mystery 2",
    Callback = function()
        if not scriptLoaded then
            local context = {
                OrionLib = OrionLib,
                Window = Window
            }
            local scriptUrl = "https://raw.githubusercontent.com/KlorPe000/Murder_KlorPe/main/src/murd.lua"
            local scriptCode = game:HttpGet(scriptUrl)
            if scriptCode then
                local success, result = pcall(loadstring(scriptCode))
                if success then
                    result(context)
                    scriptLoaded = true
                else
                    warn("Помилка виконання скрипту:", result)
                end
            else
                warn("Неможливо завантажити скрипт", scriptUrl)
            end
        else
            warn("Скрипт був завантажений і не може бути виконаний повторно.")
        end
    end
})

OrionLib:Init()
