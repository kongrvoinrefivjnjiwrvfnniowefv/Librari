-- vars

local lib = {}
local sections = {}
local workareas = {}
local notifs = {}
local visible = true
local dbcooper = false

-- paleta (todo negro, acento rojo) - Mantenida pero pulida
local COL_BG = Color3.fromRGB(10, 10, 10)
local COL_BG2 = Color3.fromRGB(15, 15, 15)
local COL_BTN = Color3.fromRGB(25, 25, 25)
local COL_TEXT = Color3.fromRGB(255, 255, 255)
local COL_SUBTEXT = Color3.fromRGB(180, 180, 180)
local COL_ACCENT = Color3.fromRGB(220, 40, 45)

-- la topbar ahora usa el MISMO color que el menú (COL_BG), no un color aparte
local TOPBAR_STROKE = Color3.fromRGB(50, 50, 50)
local TOPBAR_ICON_BG = Color3.fromRGB(20, 20, 20)

-- imagen de perfil/control, confirmada que carga bien con rbxthumb
local CONTROL_IMAGE = "rbxthumb://type=Asset&id=86868808077613&w=150&h=150"

-- iconos de control: corregidos para usar rbxthumb
local ICON_CLOSE = "rbxthumb://type=Asset&id=111147657950432&w=150&h=150"
local ICON_COLLAPSE = "rbxthumb://type=Asset&id=119364000008939&w=150&h=150"
local ICON_EXPAND = "rbxthumb://type=Asset&id=76932851909318&w=150&h=150"

local NORMAL_SIZE = UDim2.new(0, 721, 0, 584)
local MAX_SIZE = UDim2.new(0, 900, 0, 720)

local function tp(ins, pos, time, thing)
    game:GetService("TweenService"):Create(ins, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),{Position = pos}):Play()
end

-- animación genérica de hover (escala + color opcional)
local function addHover(btn, opts)
    opts = opts or {}
    local scaleUp = opts.scaleUp or 1.05
    local hoverColor = opts.hoverColor
    local baseColor = btn.BackgroundColor3
    local baseSize = btn.Size

    local tweenIn = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenOut = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    btn.MouseEnter:Connect(function()
        local goalSize = UDim2.new(
            baseSize.X.Scale, baseSize.X.Offset * scaleUp,
            baseSize.Y.Scale, baseSize.Y.Offset * scaleUp
        )
        game:GetService("TweenService"):Create(btn, tweenIn, {Size = goalSize}):Play()
        if hoverColor then
            game:GetService("TweenService"):Create(btn, tweenIn, {BackgroundColor3 = hoverColor}):Play()
        end
    end)

    btn.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(btn, tweenOut, {Size = baseSize}):Play()
        if hoverColor then
            game:GetService("TweenService"):Create(btn, tweenOut, {BackgroundColor3 = baseColor}):Play()
        end
    end)
end

-- rotación suave al hacer click (para iconos tipo "expandir")
local function addClickSpin(btn, degrees)
    btn.MouseButton1Click:Connect(function()
        local goal = btn.Rotation + (degrees or 90)
        game:GetService("TweenService"):Create(
            btn,
            TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Rotation = goal}
        ):Play()
    end)
end

-- pulso sutil infinito (respiración) para llamar la atención sin ser invasivo
local function addPulse(ins, opts)
    opts = opts or {}
    local minT = opts.minTransparency or 0.1
    local maxT = opts.maxTransparency or 0.4
    local dur = opts.duration or 1.4
    task.spawn(function()
        while ins and ins.Parent do
            local t1 = game:GetService("TweenService"):Create(ins, TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = maxT})
            t1:Play()
            t1.Completed:Wait()
            if not (ins and ins.Parent) then break end
            local t2 = game:GetService("TweenService"):Create(ins, TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = minT})
            t2:Play()
            t2.Completed:Wait()
        end
    end)
end

-- fade-in de transparencia de fondo (para frames al aparecer)
local function fadeInBackground(ins, targetTransparency, duration)
    local startT = ins.BackgroundTransparency
    ins.BackgroundTransparency = 1
    game:GetService("TweenService"):Create(
        ins,
        TweenInfo.new(duration or 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = targetTransparency}
    ):Play()
end

-- entrada escalonada: anima una lista de instancias con pequeño delay entre cada una
local function staggerIn(instances, delayStep)
    delayStep = delayStep or 0.05
    for i, ins in ipairs(instances) do
        local goalPos = ins.Position
        ins.Position = goalPos + UDim2.new(0, -20, 0, 0)
        local goalTransparency = ins.BackgroundTransparency
        ins.BackgroundTransparency = 1
        task.delay((i - 1) * delayStep, function()
            if ins and ins.Parent then
                game:GetService("TweenService"):Create(ins, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = goalPos, BackgroundTransparency = goalTransparency}):Play()
            end
        end)
    end
end

-- spinner rojo tipo "sin conexión" alrededor de un ImageLabel/ImageButton
local function addLoadingSpinner(parent, targetImage)
    local ring = Instance.new("ImageLabel")
    ring.Name = "loadingRing"
    ring.Parent = parent
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.BackgroundTransparency = 1
    ring.Position = UDim2.new(0.5, 0, 0.5, 0)
    ring.Size = UDim2.new(1.35, 0, 1.35, 0)
    ring.ZIndex = (targetImage.ZIndex or 1) - 1
    ring.Image = "rbxassetid://4965945880"
    ring.ImageColor3 = COL_ACCENT
    ring.ScaleType = Enum.ScaleType.Fit

    local spinning = true
    task.spawn(function()
        while spinning and ring.Parent do
            local tween = game:GetService("TweenService"):Create(
                ring,
                TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
                {Rotation = ring.Rotation + 360}
            )
            tween:Play()
            tween.Completed:Wait()
        end
    end)

    return ring, function() spinning = false end
end

-- contador de FPS en vivo
local function startFpsCounter(label)
    local frames = 0
    local lastUpdate = os.clock()
    local RunService = game:GetService("RunService")
    local conn
    conn = RunService.RenderStepped:Connect(function()
        frames += 1
        local now = os.clock()
        if now - lastUpdate >= 1 then
            if label and label.Parent then
                label.Text = "FPS: " .. tostring(frames)
            else
                if conn then conn:Disconnect() end
                return
            end
            frames = 0
            lastUpdate = now
        end
    end)
    return conn
end

-- contador de PING en vivo
local function startPingCounter(label)
    local Stats = game:GetService("Stats")
    task.spawn(function()
        while label and label.Parent do
            local ok, ping = pcall(function()
                return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            if ok and ping then
                label.Text = "PING: " .. math.floor(ping) .. "ms"
            end
            task.wait(1)
        end
    end)
end

function lib:init(ti, dosplash, visiblekey, deleteprevious)
    if syn then
         cg = game:GetService("CoreGui")
        if cg:FindFirstChild("ScreenGui") and deleteprevious then
           tp(cg.ScreenGui.main, cg.ScreenGui.main.Position + UDim2.new(0,0,2,0), 0.5)
            game:GetService("Debris"):AddItem(cg.ScreenGui, 1)
      end
        scrgui = Instance.new("ScreenGui")
        syn.protect_gui(scrgui)
        scrgui.Parent = game:GetService("CoreGui")
    elseif gethui then
        if gethui():FindFirstChild("ScreenGui") and deleteprevious then
            gethui().ScreenGui.main:TweenPosition(gethui().ScreenGui.main.Position + UDim2.new(0,0,2,0), "InOut", "Quart", 0.5)
            game:GetService("Debris"):AddItem(gethui().ScreenGui, 1)
        end
         scrgui = Instance.new("ScreenGui")
        scrgui.Parent = gethui()
    else
        cg = game:GetService("CoreGui")
        if cg:FindFirstChild("ScreenGui") and deleteprevious then
            tp(cg.ScreenGui.main, cg.ScreenGui.main.Position + UDim2.new(0,0,2,0), 0.5)
            game:GetService("Debris"):AddItem(cg.ScreenGui, 1)
        end
         scrgui = Instance.new("ScreenGui")
        scrgui.Parent = cg
    end

    if dosplash then
        local splash = Instance.new("Frame")
        splash.Name = "splash"
        splash.Parent = scrgui
        splash.AnchorPoint = Vector2.new(0.5, 0.5)
        splash.BackgroundColor3 = COL_BG
        splash.BackgroundTransparency = 0
        splash.Position = UDim2.new(0.5, 0, 2, 0)
        splash.Size = UDim2.new(0, 340, 0, 340)
        splash.Visible = true
        splash.ZIndex = 40

        local uc_22 = Instance.new("UICorner")
        uc_22.CornerRadius = UDim.new(0, 18)
        uc_22.Parent = splash

        local sicon = Instance.new("ImageLabel")
        sicon.Name = "sicon"
        sicon.Parent = splash
        sicon.AnchorPoint = Vector2.new(0.5, 0.5)
        sicon.BackgroundColor3 = COL_BG
        sicon.BackgroundTransparency = 1
        sicon.Position = UDim2.new(0.5, 0, 0.5, 0)
        sicon.Size = UDim2.new(0, 150, 0, 150)
        sicon.ZIndex = 40
        sicon.Image = CONTROL_IMAGE
        sicon.ScaleType = Enum.ScaleType.Fit

        local uc_sicon = Instance.new("UICorner")
        uc_sicon.CornerRadius = UDim.new(1, 0)
        uc_sicon.Parent = sicon

        local _, stopSpin = addLoadingSpinner(splash, sicon)

        -- pequeña animación de "respiración" en la imagen mientras carga
        addPulse(sicon, {minTransparency = 0, maxTransparency = 0.25, duration = 0.9})

        splash:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "InOut", "Quart", 1)
        wait(3)
        stopSpin()
        splash:TweenPosition(UDim2.new(0.5, 0, 2, 0), "InOut", "Quart", 1)
        game:GetService("Debris"):AddItem(splash, 1)
    end
        

    local main = Instance.new("Frame")
    main.Name = "main"
    main.Parent = scrgui
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = COL_BG
    main.BackgroundTransparency = 1 -- arranca invisible para el fade-in
    main.Position = UDim2.new(0.5, 0, 2, 0)
    main.Size = NORMAL_SIZE
    main.ClipsDescendants = false

    local uc = Instance.new("UICorner")
    uc.CornerRadius = UDim.new(0, 18)
    uc.Parent = main

    local UserInputService = game:GetService("UserInputService")
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- workarea right side setup

    local workarea = Instance.new("Frame")
    workarea.Name = "workarea"
    workarea.Parent = main
    workarea.BackgroundColor3 = COL_BG2
    workarea.Position = UDim2.new(0.36403501, 0, 0.09, 0)
    workarea.Size = UDim2.new(0, 458, 0, 530)

    local uc_2 = Instance.new("UICorner")
    uc_2.CornerRadius = UDim.new(0, 18)
    uc_2.Parent = workarea

    local workareacornerhider = Instance.new("Frame")
    workareacornerhider.Name = "workareacornerhider"
    workareacornerhider.Parent = workarea
    workareacornerhider.BackgroundColor3 = COL_BG2
    workareacornerhider.BorderSizePixel = 0
    workareacornerhider.Size = UDim2.new(0, 18, 0.99895674, 0)

    -- sidebar

    local sidebar = Instance.new("ScrollingFrame")
    sidebar.Name = "sidebar"
    sidebar.Parent = main
    sidebar.Active = true
    sidebar.BackgroundColor3 = COL_BG
    sidebar.BackgroundTransparency = 1
    sidebar.BorderSizePixel = 0
    sidebar.Position = UDim2.new(0.0249653254, 0, 0.19, 0)
    sidebar.Size = UDim2.new(0, 233, 0, 360) -- Ajustado para el perfil
    sidebar.AutomaticCanvasSize = "Y"
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.ScrollBarThickness = 2

    local ull_2 = Instance.new("UIListLayout")
    ull_2.Parent = sidebar
    ull_2.SortOrder = Enum.SortOrder.LayoutOrder
    ull_2.Padding = UDim.new(0, 5)

    -- SECCIÓN DE PERFIL
    local profileFrame = Instance.new("Frame")
    profileFrame.Name = "profileFrame"
    profileFrame.Parent = main
    profileFrame.BackgroundColor3 = COL_BG2
    profileFrame.Position = UDim2.new(0.025, 0, 0.86, 0)
    profileFrame.Size = UDim2.new(0, 226, 0, 65)
    profileFrame.ZIndex = 5

    local uc_prof = Instance.new("UICorner")
    uc_prof.CornerRadius = UDim.new(0, 12)
    uc_prof.Parent = profileFrame

    local profStroke = Instance.new("UIStroke")
    profStroke.Parent = profileFrame
    profStroke.Color = TOPBAR_STROKE
    profStroke.Thickness = 1
    profStroke.Transparency = 0.5

    local player = game:GetService("Players").LocalPlayer
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "avatar"
    avatar.Parent = profileFrame
    avatar.BackgroundColor3 = TOPBAR_ICON_BG
    avatar.Position = UDim2.new(0, 10, 0.5, 0)
    avatar.AnchorPoint = Vector2.new(0, 0.5)
    avatar.Size = UDim2.new(0, 46, 0, 46)
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
    avatar.ZIndex = 6
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

    local username = Instance.new("TextLabel")
    username.Name = "username"
    username.Parent = profileFrame
    username.BackgroundTransparency = 1
    username.Position = UDim2.new(0, 65, 0.2, 0)
    username.Size = UDim2.new(1, -75, 0, 20)
    username.Font = Enum.Font.GothamBold
    username.Text = player.Name
    username.TextColor3 = COL_TEXT
    username.TextSize = 14
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.ZIndex = 6

    local userid = Instance.new("TextLabel")
    userid.Name = "userid"
    userid.Parent = profileFrame
    userid.BackgroundTransparency = 1
    userid.Position = UDim2.new(0, 65, 0.55, 0)
    userid.Size = UDim2.new(1, -75, 0, 20)
    userid.Font = Enum.Font.Gotham
    userid.Text = "ID: " .. player.UserId
    userid.TextColor3 = COL_SUBTEXT
    userid.TextSize = 12
    userid.TextXAlignment = Enum.TextXAlignment.Left
    userid.ZIndex = 6

    -- ===== TOPBAR: mismo color que el menú (COL_BG) =====

    local topbar = Instance.new("Frame")
    topbar.Name = "topbar"
    topbar.Parent = main
    topbar.BackgroundColor3 = COL_BG
    topbar.BackgroundTransparency = 0
    topbar.Position = UDim2.new(0, 8, 0, 8)
    topbar.Size = UDim2.new(1, -16, 0, 52)
    topbar.ZIndex = 10
    topbar.ClipsDescendants = false

    local uc_topbar = Instance.new("UICorner")
    uc_topbar.CornerRadius = UDim.new(0, 12)
    uc_topbar.Parent = topbar

    local topbarStroke = Instance.new("UIStroke")
    topbarStroke.Parent = topbar
    topbarStroke.Color = TOPBAR_STROKE
    topbarStroke.Thickness = 1
    topbarStroke.Transparency = 0.5

    -- icono circular pequeño (izquierda), SIN borde
    local topbarIcon = Instance.new("ImageLabel")
    topbarIcon.Name = "topbarIcon"
    topbarIcon.Parent = topbar
    topbarIcon.BackgroundColor3 = TOPBAR_ICON_BG
    topbarIcon.Position = UDim2.new(0, 10, 0.5, 0)
    topbarIcon.AnchorPoint = Vector2.new(0, 0.5)
    topbarIcon.Size = UDim2.new(0, 34, 0, 34)
    topbarIcon.Image = CONTROL_IMAGE
    topbarIcon.ScaleType = Enum.ScaleType.Fit
    topbarIcon.ZIndex = 11

    local uc_ticon = Instance.new("UICorner")
    uc_ticon.CornerRadius = UDim.new(1, 0)
    uc_ticon.Parent = topbarIcon

    -- título + subtítulo
    local title = Instance.new("TextLabel")
    title.Name = "title"
    title.Parent = topbar
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 54, 0, 6)
    title.Size = UDim2.new(0, 220, 0, 20)
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = COL_ACCENT
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 11

    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "subtitle"
    subtitle.Parent = topbar
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.new(0, 54, 0, 26)
    subtitle.Size = UDim2.new(0, 220, 0, 16)
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = "PREMIUM INTERFACE"
    subtitle.TextColor3 = COL_SUBTEXT
    subtitle.TextSize = 11
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 11

    -- botones de control (derecha)
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "closeButton"
    closeButton.Parent = topbar
    closeButton.AnchorPoint = Vector2.new(1, 0.5)
    closeButton.BackgroundTransparency = 1
    closeButton.Position = UDim2.new(1, -10, 0.5, 0)
    closeButton.Size = UDim2.new(0, 24, 0, 24)
    closeButton.Image = ICON_CLOSE
    closeButton.ImageColor3 = COL_ACCENT
    closeButton.ZIndex = 12

    local expandButton = Instance.new("ImageButton")
    expandButton.Name = "expandButton"
    expandButton.Parent = topbar
    expandButton.AnchorPoint = Vector2.new(1, 0.5)
    expandButton.BackgroundTransparency = 1
    expandButton.Position = UDim2.new(1, -44, 0.5, 0)
    expandButton.Size = UDim2.new(0, 24, 0, 24)
    expandButton.Image = ICON_EXPAND
    expandButton.ImageColor3 = COL_SUBTEXT
    expandButton.ZIndex = 12

    local collapseButton = Instance.new("ImageButton")
    collapseButton.Name = "collapseButton"
    collapseButton.Parent = topbar
    collapseButton.AnchorPoint = Vector2.new(1, 0.5)
    collapseButton.BackgroundTransparency = 1
    collapseButton.Position = UDim2.new(1, -78, 0.5, 0)
    collapseButton.Size = UDim2.new(0, 24, 0, 24)
    collapseButton.Image = ICON_COLLAPSE
    collapseButton.ImageColor3 = COL_SUBTEXT
    collapseButton.ZIndex = 12

    addHover(closeButton, {scaleUp = 1.15})
    addHover(expandButton, {scaleUp = 1.15})
    addHover(collapseButton, {scaleUp = 1.15})

    addClickSpin(expandButton, 90)
    addClickSpin(collapseButton, -20)

    -- ===== botón único FUERA del menú, negro redondeado con la imagen =====
    local reopenButton = Instance.new("ImageButton")
    reopenButton.Name = "reopenButton"
    reopenButton.Parent = scrgui
    reopenButton.AnchorPoint = Vector2.new(1, 1)
    reopenButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    reopenButton.BorderSizePixel = 0
    reopenButton.Position = UDim2.new(1, -30, 1, -30)
    reopenButton.Size = UDim2.new(0, 64, 0, 64)
    reopenButton.Image = CONTROL_IMAGE
    reopenButton.ScaleType = Enum.ScaleType.Fit
    reopenButton.Visible = true
    reopenButton.ZIndex = 50

    local uc_reopen = Instance.new("UICorner")
    uc_reopen.CornerRadius = UDim.new(0, 20)
    uc_reopen.Parent = reopenButton

    local reopenStroke = Instance.new("UIStroke")
    reopenStroke.Parent = reopenButton
    reopenStroke.Color = Color3.fromRGB(60, 60, 60)
    reopenStroke.Thickness = 1.5

    addHover(reopenButton, {scaleUp = 1.1})
    addPulse(reopenButton, {minTransparency = 0, maxTransparency = 0.15, duration = 1.6})

    -- notif1
    local notif = Instance.new("Frame")
    notif.Name = "notif"
    notif.Parent = main
    notif.AnchorPoint = Vector2.new(0.5, 0.5)
    notif.BackgroundColor3 = COL_BG
    notif.Position = UDim2.new(0.5, 0, 0.5, 0)
    notif.Size = UDim2.new(0, 304, 0, 362)
    notif.Visible = false
    notif.ZIndex = 30

    local uc_11 = Instance.new("UICorner")
    uc_11.CornerRadius = UDim.new(0, 18)
    uc_11.Parent = notif

    local notificon = Instance.new("ImageLabel")
    notificon.Name = "notificon"
    notificon.Parent = notif
    notificon.BackgroundColor3 = COL_BG
    notificon.BackgroundTransparency = 1
    notificon.Position = UDim2.new(0.335526317, 0, 0.0994475111, 0)
    notificon.Size = UDim2.new(0, 100, 0, 100)
    notificon.ZIndex = 30
    notificon.Image = "rbxassetid://4871684504"
    notificon.ImageColor3 = COL_TEXT

    local notifbutton1 = Instance.new("TextButton")
    notifbutton1.Name = "notifbutton1"
    notifbutton1.Parent = notif
    notifbutton1.BackgroundColor3 = COL_ACCENT
    notifbutton1.Position = UDim2.new(0.0559210554, 0, 0.817679524, 0)
    notifbutton1.Size = UDim2.new(0, 270, 0, 50)
    notifbutton1.ZIndex = 30
    notifbutton1.Font = Enum.Font.Gotham
    notifbutton1.Text = "OK"
    notifbutton1.TextColor3 = COL_TEXT
    notifbutton1.TextSize = 21

    local uc_12 = Instance.new("UICorner")
    uc_12.CornerRadius = UDim.new(0, 9)
    uc_12.Parent = notifbutton1
    addHover(notifbutton1, {scaleUp = 1.05})

    local notifdarkness = Instance.new("Frame")
    notifdarkness.Name = "notifdarkness"
    notifdarkness.Parent = notif
    notifdarkness.AnchorPoint = Vector2.new(0.5, 0.5)
    notifdarkness.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notifdarkness.BackgroundTransparency = 0.600
    notifdarkness.Position = UDim2.new(0.5, 0, 0.5, 0)
    notifdarkness.Size = UDim2.new(0, 721, 0, 584)
    notifdarkness.ZIndex = 29

    local uc_13 = Instance.new("UICorner")
    uc_13.CornerRadius = UDim.new(0, 18)
    uc_13.Parent = notifdarkness

    local notiftitle = Instance.new("TextLabel")
    notiftitle.Name = "notiftitle"
    notiftitle.Parent = notif
    notiftitle.BackgroundColor3 = COL_BG
    notiftitle.BackgroundTransparency = 1
    notiftitle.Position = UDim2.new(0.167763159, 0, 0.375690609, 0)
    notiftitle.Size = UDim2.new(0, 200, 0, 50)
    notiftitle.ZIndex = 30
    notiftitle.Font = Enum.Font.GothamMedium
    notiftitle.Text = "Notice"
    notiftitle.TextColor3 = COL_TEXT
    notiftitle.TextSize = 28

    local notiftext = Instance.new("TextLabel")
    notiftext.Name = "notiftext"
    notiftext.Parent = notif
    notiftext.BackgroundColor3 = COL_BG
    notiftext.BackgroundTransparency = 1
    notiftext.Position = UDim2.new(0.0822368413, 0, 0.513812184, 0)
    notiftext.Size = UDim2.new(0, 254, 0, 66)
    notiftext.ZIndex = 30
    notiftext.Font = Enum.Font.Gotham
    notiftext.Text = "We would like to contact you regarding your car's extended warranty."
    notiftext.TextColor3 = COL_SUBTEXT
    notiftext.TextSize = 16
    notiftext.TextWrapped = true

    -- notifcation 2 (two button)

    local notif2 = Instance.new("Frame")
    notif2.Name = "notif2"
    notif2.Parent = main
    notif2.AnchorPoint = Vector2.new(0.5, 0.5)
    notif2.BackgroundColor3 = COL_BG
    notif2.Position = UDim2.new(0.5, 0, 0.5, 0)
    notif2.Size = UDim2.new(0, 304, 0, 260)
    notif2.Visible = false
    notif2.ZIndex = 30

    local uc_14 = Instance.new("UICorner")
    uc_14.CornerRadius = UDim.new(0, 18)
    uc_14.Parent = notif2

    local notif2icon = Instance.new("ImageLabel")
    notif2icon.Name = "notif2icon"
    notif2icon.Parent = notif2
    notif2icon.BackgroundColor3 = COL_BG
    notif2icon.BackgroundTransparency = 1
    notif2icon.Position = UDim2.new(0.335526317, 0, 0.0994475111, 0)
    notif2icon.Size = UDim2.new(0, 100, 0, 100)
    notif2icon.ZIndex = 30
    notif2icon.Image = "rbxassetid://12608260095"
    notif2icon.ImageColor3 = COL_TEXT

    local notif2title = Instance.new("TextLabel")
    notif2title.Name = "notif2title"
    notif2title.Parent = notif2
    notif2title.BackgroundColor3 = COL_BG
    notif2title.BackgroundTransparency = 1
    notif2title.Position = UDim2.new(0.167763159, 0, 0.375690609, 0)
    notif2title.Size = UDim2.new(0, 200, 0, 50)
    notif2title.ZIndex = 30
    notif2title.Font = Enum.Font.GothamMedium
    notif2title.Text = "Notice"
    notif2title.TextColor3 = COL_TEXT
    notif2title.TextSize = 28

    local notif2text = Instance.new("TextLabel")
    notif2text.Name = "notif2text"
    notif2text.Parent = notif2
    notif2text.BackgroundColor3 = COL_BG
    notif2text.BackgroundTransparency = 1
    notif2text.Position = UDim2.new(0.0822368413, 0, 0.513812184, 0)
    notif2text.Size = UDim2.new(0, 254, 0, 66)
    notif2text.ZIndex = 30
    notif2text.Font = Enum.Font.Gotham
    notif2text.Text = "We would like to contact you regarding your car's extended warranty."
    notif2text.TextColor3 = COL_SUBTEXT
    notif2text.TextSize = 16
    notif2text.TextWrapped = true

    local notif2button1 = Instance.new("TextButton")
    notif2button1.Name = "notif2button1"
    notif2button1.Parent = notif2
    notif2button1.BackgroundColor3 = COL_ACCENT
    notif2button1.Position = UDim2.new(0.0559210517, 0, 0.715469658, 0)
    notif2button1.Size = UDim2.new(0, 270, 0, 40)
    notif2button1.ZIndex = 30
    notif2button1.Font = Enum.Font.Gotham
    notif2button1.Text = "Sure!"
    notif2button1.TextColor3 = COL_TEXT
    notif2button1.TextSize = 21

    local uc_15 = Instance.new("UICorner")
    uc_15.CornerRadius = UDim.new(0, 9)
    uc_15.Parent = notif2button1
    addHover(notif2button1, {scaleUp = 1.05})

    local notif2darkness = Instance.new("Frame")
    notif2darkness.Name = "notif2darkness"
    notif2darkness.Parent = notif2
    notif2darkness.AnchorPoint = Vector2.new(0.5, 0.5)
    notif2darkness.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notif2darkness.BackgroundTransparency = 0.600
    notif2darkness.Position = UDim2.new(0.5, 0, 0.5, 0)
    notif2darkness.Size = UDim2.new(0, 721, 0, 584)
    notif2darkness.ZIndex = 29

    local uc_16 = Instance.new("UICorner")
    uc_16.CornerRadius = UDim.new(0, 18)
    uc_16.Parent = notif2darkness

    local notif2button2 = Instance.new("TextButton")
    notif2button2.Name = "notif2button2"
    notif2button2.Parent = notif2
    notif2button2.BackgroundColor3 = COL_ACCENT
    notif2button2.BackgroundTransparency = 1
    notif2button2.Position = UDim2.new(0.0526315793, 0, 0.842541456, 0)
    notif2button2.Size = UDim2.new(0, 270, 0, 40)
    notif2button2.ZIndex = 30
    notif2button2.Font = Enum.Font.Gotham
    notif2button2.Text = "Go away."
    notif2button2.TextColor3 = COL_SUBTEXT
    notif2button2.TextSize = 21

    local uc_17 = Instance.new("UICorner")
    uc_17.CornerRadius = UDim.new(0, 9)
    uc_17.Parent = notif2button2

    if ti then
        title.Text = ti
    else
        title.Text = "Write Hub"
    end

    -- animación de apertura inicial: fade-in + entrada del frame
    main.Size = UDim2.new(0, 0, 0, 0)
    tp(main, UDim2.new(0.5, 0, 0.5, 0), 1)
    game:GetService("TweenService"):Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = NORMAL_SIZE,
        BackgroundTransparency = 0.05
    }):Play()

    window = {}

    -- ===== [-] colapsar la topbar =====
    local isCollapsed = false
    local collapseAnimating = false
    local expandedHeight = NORMAL_SIZE.Y.Offset

    function window:ToggleCollapse()
        if collapseAnimating then return end
        collapseAnimating = true
        isCollapsed = not isCollapsed

        local goalHeight = isCollapsed and 68 or expandedHeight

        if isCollapsed then
            workarea.Visible = false
            sidebar.Visible = false
            profileFrame.Visible = false
        end

        local tw = game:GetService("TweenService"):Create(
            main,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            {Size = UDim2.new(main.Size.X.Scale, main.Size.X.Offset, 0, goalHeight)}
        )
        tw:Play()
        tw.Completed:Wait()

        if not isCollapsed then
            workarea.Visible = true
            sidebar.Visible = true
            profileFrame.Visible = true
            fadeInBackground(workarea, 0, 0.25)
        end

        collapseAnimating = false
    end

    collapseButton.MouseButton1Click:Connect(function()
        window:ToggleCollapse()
    end)

    -- ===== [ ] expandir/restaurar =====
    local isMaximized = false
    local maxAnimating = false

    function window:ToggleMaximize()
        if maxAnimating or isCollapsed then return end
        maxAnimating = true
        isMaximized = not isMaximized

        local goalSize = isMaximized and MAX_SIZE or NORMAL_SIZE
        expandedHeight = goalSize.Y.Offset

        game:GetService("TweenService"):Create(
            main,
            TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = goalSize}
        ):Play()

        task.wait(0.35)
        maxAnimating = false
    end

    expandButton.MouseButton1Click:Connect(function()
        window:ToggleMaximize()
    end)

    -- ===== X cerrar con confirmación sí/no =====
    closeButton.MouseButton1Click:Connect(function()
        window:Notify2(
            "¿Cerrar Write Hub?",
            "Esta acción cerrará el menú por completo.",
            "Sí",
            "No",
            function()
                scrgui:Destroy()
            end,
            function() end
        )
    end)

    -- ===== botón único (fuera del menú): minimiza/reabre el menú completo =====
    local isOpen = true
    local openAnimating = false

    function window:ToggleVisible()
        if openAnimating then return end
        openAnimating = true
        isOpen = not isOpen

        if isOpen then
            main.Visible = true
            main.Size = UDim2.new(0, 0, 0, 0)
            main.BackgroundTransparency = 1
            main.Position = UDim2.new(0.5, 0, 0.5, 0)
            game:GetService("TweenService"):Create(
                main,
                TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Size = isMaximized and MAX_SIZE or NORMAL_SIZE, BackgroundTransparency = 0.05}
            ):Play()
            task.wait(0.35)
        else
            local closeTween = game:GetService("TweenService"):Create(
                main,
                TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}
            )
            closeTween:Play()
            closeTween.Completed:Wait()
            main.Visible = false
        end

        openAnimating = false
    end

    reopenButton.MouseButton1Click:Connect(function()
        window:ToggleVisible()
    end)

    if visiblekey then
        game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == visiblekey then
                window:ToggleVisible()
            end
        end)
    end

    function window:SetSubtitle(text)
        subtitle.Text = text
    end

    function window:TempNotify(text1, text2, icon)
        for b,v in next, scrgui:GetChildren() do
            if v.Name == "tempnotif" then 
                v.Position += UDim2.new(0,0,0,130)
            end
        end
        local tempnotif = Instance.new("Frame")
        tempnotif.Name = "tempnotif"
        tempnotif.Parent = scrgui
        tempnotif.AnchorPoint = Vector2.new(0.5, 0.5)
        tempnotif.BackgroundColor3 = COL_BG
        tempnotif.BackgroundTransparency = 1
        tempnotif.Position = UDim2.new(1, -250, 0.0794737339, 0)
        tempnotif.Size = UDim2.new(0, 447, 0, 117)
        tempnotif.Visible = true
        tempnotif.ZIndex = 4

        local uc_21 = Instance.new("UICorner")
        uc_21.CornerRadius = UDim.new(0, 18)
        uc_21.Parent = tempnotif

        local t2 = Instance.new("TextLabel")
        t2.Name = "t2"
        t2.Parent = tempnotif
        t2.BackgroundColor3 = COL_BG
        t2.BackgroundTransparency = 1
        t2.Position = UDim2.new(0.236927822, 0, 0.470085472, 0)
        t2.Size = UDim2.new(0, 326, 0, 52)
        t2.ZIndex = 4
        t2.Font = Enum.Font.Gotham
        t2.Text = text2
        t2.TextColor3 = COL_SUBTEXT
        t2.TextSize = 16
        t2.TextWrapped = true
        t2.TextXAlignment = Enum.TextXAlignment.Left
        t2.TextYAlignment = Enum.TextYAlignment.Top

        local t1 = Instance.new("TextLabel")
        t1.Name = "t1"
        t1.Parent = tempnotif
        t1.BackgroundColor3 = COL_BG
        t1.BackgroundTransparency = 1
        t1.Position = UDim2.new(0.234690696, 0, 0.193464488, 0)
        t1.Size = UDim2.new(0, 327, 0, 25)
        t1.ZIndex = 4
        t1.Font = Enum.Font.GothamMedium
        t1.Text = text1
        t1.TextColor3 = COL_TEXT
        t1.TextSize = 28
        t1.TextXAlignment = Enum.TextXAlignment.Left

        local ticon = Instance.new("ImageLabel")
        ticon.Name = "ticon"
        ticon.Parent = tempnotif
        ticon.BackgroundColor3 = COL_BG
        ticon.BackgroundTransparency = 1
        ticon.Position = UDim2.new(0.0311112702, 0, 0.193464488, 0)
        ticon.Size = UDim2.new(0, 71, 0, 71)
        ticon.ZIndex = 4
        ticon.Image = icon or CONTROL_IMAGE
        Instance.new("UICorner", ticon).CornerRadius = UDim.new(1, 0)

        local tshadow = Instance.new("ImageLabel")
        tshadow.Name = "tshadow"
        tshadow.Parent = tempnotif
        tshadow.AnchorPoint = Vector2.new(0.5, 0.5)
        tshadow.BackgroundTransparency = 1
        tshadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        tshadow.Size = UDim2.new(1.12, 0, 1.20000005, 0)
        tshadow.ZIndex = 3
        tshadow.Image = "rbxassetid://313486536"
        tshadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        tshadow.ImageTransparency = 0.400
        tshadow.TileSize = UDim2.new(0, 1, 0, 1)

        -- fade-in + deslizamiento de entrada de la notificación temporal
        tempnotif.Position = tempnotif.Position + UDim2.new(0, 40, 0, 0)
        local goalPos = UDim2.new(1, -250, 0.0794737339, 0)
        game:GetService("TweenService"):Create(tempnotif, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = goalPos,
            BackgroundTransparency = 0.100
        }):Play()

        game:GetService("Debris"):AddItem(tempnotif, 5)
    end

    function window:Notify(txt1, txt2, b1, icohn, callback)
        if notif.Visible == true or notif2.Visible == true then return "Already visible" end
        notiftitle.Text = txt1
        notiftext.Text = txt2
        notificon.Image = icohn or "rbxassetid://4871684504"
        notif.Visible = true
        notif.Size = UDim2.new(0, 260, 0, 320)
        notifbutton1.Text = b1
        game:GetService("TweenService"):Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 304, 0, 362)}):Play()
        if callback then
            local con1
            con1 = notifbutton1.MouseButton1Click:Connect(function()
                con1:Disconnect()
                callback()
                notif.Visible = false
            end)
        end
    end

    function window:Notify2(txt1, txt2, b1, b2, callback, callback2)
        if notif.Visible == true or notif2.Visible == true then return "Already visible" end
        notif2title.Text = txt1
        notif2text.Text = txt2
        notif2.Visible = true
        notif2.Size = UDim2.new(0, 260, 0, 220)
        notif2button1.Text = b1
        notif2button2.Text = b2
        game:GetService("TweenService"):Create(notif2, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 304, 0, 260)}):Play()
        
        local con1, con2
        con1 = notif2button1.MouseButton1Click:Connect(function()
            con1:Disconnect()
            if con2 then con2:Disconnect() end
            if callback then callback() end
            notif2.Visible = false
        end)
        con2 = notif2button2.MouseButton1Click:Connect(function()
            if con1 then con1:Disconnect() end
            con2:Disconnect()
            if callback2 then callback2() end
            notif2.Visible = false
        end)
    end

    function window:Divider(name)
        local sidebardivider = Instance.new("TextLabel")
        sidebardivider.Name = "sidebardivider"
        sidebardivider.Parent = sidebar
        sidebardivider.BackgroundColor3 = COL_BG
        sidebardivider.BackgroundTransparency = 1
        sidebardivider.BorderSizePixel = 2
        sidebardivider.Position = UDim2.new(0, 0, 0.00215982716, 0)
        sidebardivider.Size = UDim2.new(0, 226, 0, 26)
        sidebardivider.Font = Enum.Font.Gotham
        sidebardivider.Text = name
        sidebardivider.TextColor3 = COL_SUBTEXT
        sidebardivider.TextSize = 21
        sidebardivider.TextWrapped = true
        sidebardivider.TextXAlignment = Enum.TextXAlignment.Left
        sidebardivider.TextYAlignment = Enum.TextYAlignment.Bottom
    end

    function window:Section(name)
        local sidebar2 = Instance.new("TextButton")
        sidebar2.Name = "sidebar2"
        sidebar2.Parent = sidebar
        sidebar2.BackgroundColor3 = COL_ACCENT
        sidebar2.BackgroundTransparency = 1
        sidebar2.Size = UDim2.new(0, 226, 0, 37)
        sidebar2.ZIndex = 2
        sidebar2.AutoButtonColor = false
        sidebar2.Font = Enum.Font.Gotham
        sidebar2.Text = name
        sidebar2.TextColor3 = COL_TEXT
        sidebar2.TextSize = 21
        
        local uc_10 = Instance.new("UICorner")
        uc_10.CornerRadius = UDim.new(0, 9)
        uc_10.Parent = sidebar2
        table.insert(sections, sidebar2)
        addHover(sidebar2, {scaleUp = 1.03})

        -- animación de entrada del botón de sección al ser creado
        do
            local goalPos = sidebar2.Position
            sidebar2.Position = goalPos - UDim2.new(0, 25, 0, 0)
            game:GetService("TweenService"):Create(sidebar2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = goalPos}):Play()
        end

        local workareamain = Instance.new("ScrollingFrame")
        workareamain.Name = "workareamain"
        workareamain.Parent = workarea
        workareamain.Active = true
        workareamain.BackgroundColor3 = COL_BG2
        workareamain.BackgroundTransparency = 1
        workareamain.BorderSizePixel = 0
        workareamain.Position = UDim2.new(0.0393013097, 0, 0.0958904102, 0)
        workareamain.Size = UDim2.new(0, 422, 0, 460)
        workareamain.ZIndex = 3
        workareamain.CanvasSize = UDim2.new(0, 0, 0, 0)
        workareamain.ScrollBarThickness = 2
        workareamain.Visible = false

        local ull = Instance.new("UIListLayout")
        ull.Parent = workareamain
        ull.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ull.SortOrder = Enum.SortOrder.LayoutOrder
        ull.Padding = UDim.new(0, 5)
    
        table.insert(workareas, workareamain)

        local sec = {}
        function sec:Select()
            for b, v in next, sections do
                v.BackgroundTransparency = 1
                v.TextColor3 = COL_TEXT
            end
            sidebar2.BackgroundTransparency = 0
            sidebar2.TextColor3 = Color3.fromRGB(255, 255, 255)
            for b, v in next, workareas do
                v.Visible = false
            end
            workareamain.Visible = true

            -- animación de aparición: deslizamiento + fade
            workareamain.Position = UDim2.new(0.0393013097, 15, 0.0958904102, 0)
            local goal = UDim2.new(0.0393013097, 0, 0.0958904102, 0)
            game:GetService("TweenService"):Create(workareamain, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = goal}):Play()

            -- entrada escalonada de los elementos dentro de la sección
            local children = {}
            for _, child in ipairs(workareamain:GetChildren()) do
                if child:IsA("GuiObject") and child.Name ~= "UIListLayout" then
                    table.insert(children, child)
                end
            end
            staggerIn(children, 0.04)
        end
        function sec:Divider(name)
            local section = Instance.new("TextLabel")
            section.Name = "section"
            section.Parent = workareamain
            section.BackgroundColor3 = COL_BG2
            section.BackgroundTransparency = 1
            section.BorderSizePixel = 2
            section.Size = UDim2.new(0, 418, 0, 50)
            section.Font = Enum.Font.Gotham
            section.LineHeight = 1.180
            section.Text = name
            section.TextColor3 = COL_TEXT
            section.TextSize = 25
            section.TextWrapped = true
            section.TextXAlignment = Enum.TextXAlignment.Left
            section.TextYAlignment = Enum.TextYAlignment.Bottom
        end
        function sec:Button(name, callback)
            local button = Instance.new("TextButton")
            button.Name = "button"
            button.Text = name
            button.Parent = workareamain
            button.BackgroundColor3 = COL_BTN
            button.BackgroundTransparency = 0
            button.Size = UDim2.new(0, 418, 0, 37)
            button.ZIndex = 2
            button.Font = Enum.Font.Gotham
            button.TextColor3 = COL_TEXT
            button.TextSize = 21

            local uc_3 = Instance.new("UICorner")
            uc_3.CornerRadius = UDim.new(0, 9)
            uc_3.Parent = button

            local us = Instance.new("UIStroke", button)
            us.ApplyStrokeMode = "Border"
            us.Color = COL_ACCENT
            us.Thickness = 1

            addHover(button, {scaleUp = 1.03, hoverColor = Color3.fromRGB(50, 50, 50)})

            if callback then
                button.MouseButton1Click:Connect(function() 
                    -- pulso de click más notorio: encoge y rebota
                    local orig = button.Size
                    local shrink = UDim2.new(orig.X.Scale, orig.X.Offset * 0.97, orig.Y.Scale, orig.Y.Offset * 0.9)
                    local tw1 = game:GetService("TweenService"):Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = shrink})
                    tw1:Play()
                    tw1.Completed:Wait()
                    game:GetService("TweenService"):Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = orig}):Play()
                    callback()
                end)
            end
        end

        function sec:Label(name)
            local label = Instance.new("TextLabel")
            label.Name = "label"
            label.Parent = workareamain
            label.BackgroundColor3 = COL_BG2
            label.BackgroundTransparency = 1
            label.BorderSizePixel = 2
            label.Size = UDim2.new(0, 418, 0, 37)
            label.Font = Enum.Font.Gotham
            label.TextColor3 = COL_SUBTEXT
            label.TextSize = 21
            label.TextWrapped = true
            label.Text = name
        end

        function sec:Switch(name, defaultmode, callback)
            local mode = defaultmode
            local toggleswitch = Instance.new("Frame")
            toggleswitch.Name = "toggleswitch"
            toggleswitch.Parent = workareamain
            toggleswitch.BackgroundColor3 = COL_BTN
            toggleswitch.BackgroundTransparency = 0
            toggleswitch.BorderSizePixel = 0
            toggleswitch.Size = UDim2.new(0, 418, 0, 37)
            toggleswitch.ClipsDescendants = false

            local uc_sw = Instance.new("UICorner")
            uc_sw.CornerRadius = UDim.new(0, 9)
            uc_sw.Parent = toggleswitch

            local swLabel = Instance.new("TextLabel")
            swLabel.Name = "swLabel"
            swLabel.Parent = toggleswitch
            swLabel.BackgroundTransparency = 1
            swLabel.Position = UDim2.new(0, 14, 0, 0)
            swLabel.Size = UDim2.new(1, -100, 1, 0)
            swLabel.Font = Enum.Font.Gotham
            swLabel.Text = name
            swLabel.TextColor3 = COL_TEXT
            swLabel.TextSize = 18
            swLabel.TextWrapped = true
            swLabel.TextXAlignment = Enum.TextXAlignment.Left

            local hitArea = Instance.new("TextButton")
            hitArea.Name = "hitArea"
            hitArea.Parent = toggleswitch
            hitArea.BackgroundTransparency = 1
            hitArea.Size = UDim2.new(1, 0, 1, 0)
            hitArea.Text = ""
            hitArea.ZIndex = 5
            hitArea.AutoButtonColor = false

            local Frame = Instance.new("Frame")
            Frame.Name = "track"
            Frame.Parent = toggleswitch
            Frame.AnchorPoint = Vector2.new(1, 0.5)
            Frame.Position = UDim2.new(1, -8, 0.5, 0)
            Frame.Size = UDim2.new(0, 56, 0, 28)
            Frame.ZIndex = 4

            local uc_4 = Instance.new("UICorner")
            uc_4.CornerRadius = UDim.new(1, 0)
            uc_4.Parent = Frame

            local knob = Instance.new("Frame")
            knob.Name = "knob"
            knob.Parent = Frame
            knob.BackgroundColor3 = COL_TEXT
            knob.Size = UDim2.new(0, 22, 0, 22)
            knob.AnchorPoint = Vector2.new(0, 0.5)
            knob.Position = UDim2.new(0, 3, 0.5, 0)
            knob.ZIndex = 4
            knob.Active = false

            local uc_5 = Instance.new("UICorner")
            uc_5.CornerRadius = UDim.new(1, 0)
            uc_5.Parent = knob

            local function applyState(instant)
                local knobGoal = mode and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
                local colGoal = mode and COL_ACCENT or Color3.fromRGB(60, 60, 60)
                if instant then
                    knob.Position = knobGoal
                    Frame.BackgroundColor3 = colGoal
                else
                    -- knob "estira" ligeramente al moverse para dar sensación elástica
                    local stretchSize = UDim2.new(0, 28, 0, 22)
                    game:GetService("TweenService"):Create(knob, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = stretchSize}):Play()
                    game:GetService("TweenService"):Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = knobGoal, Size = UDim2.new(0, 22, 0, 22)}):Play()
                    game:GetService("TweenService"):Create(Frame, TweenInfo.new(0.15), {BackgroundColor3 = colGoal}):Play()
                end
            end
            applyState(true)

            local function flip()
                mode = not mode
                applyState(false)
                if callback then
                    callback(mode)
                end
            end

            hitArea.MouseButton1Click:Connect(flip)
        end

        function sec:TextField(name, placeholder, callback)
            local textfield = Instance.new("Frame")
            textfield.Name = "textfield"
            textfield.Parent = workareamain
            textfield.BackgroundColor3 = COL_BTN
            textfield.Size = UDim2.new(0, 418, 0, 45)
            Instance.new("UICorner", textfield).CornerRadius = UDim.new(0, 9)

            local label = Instance.new("TextLabel")
            label.Parent = textfield
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 14, 0, 0)
            label.Size = UDim2.new(0, 150, 1, 0)
            label.Font = Enum.Font.Gotham
            label.Text = name
            label.TextColor3 = COL_TEXT
            label.TextSize = 18
            label.TextXAlignment = Enum.TextXAlignment.Left

            local Frame_2 = Instance.new("Frame")
            Frame_2.Parent = textfield
            Frame_2.BackgroundColor3 = COL_BG2
            Frame_2.Position = UDim2.new(1, -240, 0.5, 0)
            Frame_2.AnchorPoint = Vector2.new(0, 0.5)
            Frame_2.Size = UDim2.new(0, 230, 0, 34)
            Instance.new("UICorner", Frame_2).CornerRadius = UDim.new(0, 8)

            local TextBox = Instance.new("TextBox")
            TextBox.Parent = Frame_2
            TextBox.BackgroundTransparency = 1
            TextBox.Position = UDim2.new(0.05, 0, 0, 0)
            TextBox.Size = UDim2.new(0.9, 0, 1, 0)
            TextBox.Font = Enum.Font.Gotham
            TextBox.PlaceholderText = placeholder or "Escribe..."
            TextBox.Text = ""
            TextBox.TextColor3 = COL_TEXT
            TextBox.TextSize = 16
            TextBox.TextXAlignment = Enum.TextXAlignment.Left

            if callback then
                TextBox.FocusLost:Connect(function()
                    callback(TextBox.Text)
                end)
            end
        end

        sidebar2.MouseButton1Click:Connect(function()
            sec:Select()
        end)

        return sec
    end

    return window
end

return lib
