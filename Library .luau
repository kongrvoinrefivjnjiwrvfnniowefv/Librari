-- vars

local lib = {}
local sections = {}
local workareas = {}
local notifs = {}
local visible = true
local dbcooper = false

-- paleta (tema negro absoluto + rojo)
local COL_BG = Color3.fromRGB(4, 4, 4)
local COL_BG2 = Color3.fromRGB(8, 8, 8)
local COL_BTN = Color3.fromRGB(18, 18, 18)
local COL_TEXT = Color3.fromRGB(255, 255, 255)
local COL_SUBTEXT = Color3.fromRGB(200, 200, 200)
local COL_ACCENT = Color3.fromRGB(220, 25, 25)
local COL_RED = Color3.fromRGB(230, 40, 40)

local CONTROL_IMAGE = "rbxthumb://type=Asset&id=86868808077613&w=150&h=150"

local NORMAL_SIZE = UDim2.new(0, 721, 0, 584)
local MAX_SIZE = UDim2.new(0, 900, 0, 720)
local TOPBAR_ONLY_SIZE = UDim2.new(0, 721, 0, 64)

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
    ring.ImageColor3 = COL_RED
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
    main.BackgroundTransparency = 0.050
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
    workarea.Position = UDim2.new(0.36403501, 0, 0, 0)
    workarea.Size = UDim2.new(0, 458, 0, 584)

    local uc_2 = Instance.new("UICorner")
    uc_2.CornerRadius = UDim.new(0, 18)
    uc_2.Parent = workarea

    local workareacornerhider = Instance.new("Frame")
    workareacornerhider.Name = "workareacornerhider"
    workareacornerhider.Parent = workarea
    workareacornerhider.BackgroundColor3 = COL_BG2
    workareacornerhider.BorderSizePixel = 0
    workareacornerhider.Size = UDim2.new(0, 18, 0.99895674, 0)


    -- searchbar

    local search = Instance.new("Frame")
    search.Name = "search"
    search.Parent = main
    search.BackgroundColor3 = COL_BG2
    search.Position = UDim2.new(0.0256588068, 0, 0.161, 0)
    search.Size = UDim2.new(0, 225, 0, 34)

    local uc_8 = Instance.new("UICorner")
    uc_8.CornerRadius = UDim.new(0, 9)
    uc_8.Parent = search

    local searchicon = Instance.new("ImageButton")
    searchicon.Name = "searchicon"
    searchicon.Parent = search
    searchicon.BackgroundColor3 = COL_BG2
    searchicon.BackgroundTransparency = 1
    searchicon.BorderColor3 = Color3.fromRGB(27, 42, 53)
    searchicon.Position = UDim2.new(0.0379999988, -2, 0.138999999, 2)
    searchicon.Size = UDim2.new(0, 24, 0, 21)
    searchicon.Image = "rbxassetid://2804603863"
    searchicon.ImageColor3 = COL_TEXT
    searchicon.ScaleType = Enum.ScaleType.Fit

    local searchtextbox = Instance.new("TextBox")
    searchtextbox.Name = "searchtextbox"
    searchtextbox.Parent = search
    searchtextbox.BackgroundColor3 = COL_BG2
    searchtextbox.BackgroundTransparency = 1
    searchtextbox.ClipsDescendants = true
    searchtextbox.Position = UDim2.new(0.180257514, 0, -0.0162218884, 0)
    searchtextbox.Size = UDim2.new(0, 176, 0, 34)
    searchtextbox.Font = Enum.Font.Gotham
    searchtextbox.LineHeight = 0.870
    searchtextbox.PlaceholderText = "Search"
    searchtextbox.PlaceholderColor3 = COL_SUBTEXT
    searchtextbox.Text = ""
    searchtextbox.TextColor3 = COL_TEXT
    searchtextbox.TextSize = 22
    searchtextbox.TextXAlignment = Enum.TextXAlignment.Left

    searchicon.MouseButton1Click:Connect(function()
        searchtextbox:CaptureFocus()
    end)

    -- sidebar

    local sidebar = Instance.new("ScrollingFrame")
    sidebar.Name = "sidebar"
    sidebar.Parent = main
    sidebar.Active = true
    sidebar.BackgroundColor3 = COL_BG
    sidebar.BackgroundTransparency = 1
    sidebar.BorderSizePixel = 0
    sidebar.Position = UDim2.new(0.0249653254, 0, 0.245, 0)
    sidebar.Size = UDim2.new(0, 233, 0, 400)
    sidebar.AutomaticCanvasSize = "Y"
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.ScrollBarThickness = 2

    local ull_2 = Instance.new("UIListLayout")
    ull_2.Parent = sidebar
    ull_2.SortOrder = Enum.SortOrder.LayoutOrder
    ull_2.Padding = UDim.new(0, 5)

    game:GetService("RunService"):BindToRenderStep("search", 1, function()
        if not searchtextbox:IsFocused() then 
            for b,v in next, sidebar:GetChildren() do
                if not v:IsA("TextButton") then return end
                v.Visible = true
            end
        end
        local InputText=string.upper(searchtextbox.Text)
        for _,button in pairs(sidebar:GetChildren())do
            if button:IsA("TextButton")then
                if InputText==""or string.find(string.upper(button.Text),InputText)~=nil then
                    button.Visible=true
                else
                    button.Visible=false
                end
            end
        end
    end)

    -- ===== TOPBAR: icono grande + título a la izquierda, controles elegantes [-] [◻] [X] a la derecha =====

    local topbarIcon = Instance.new("ImageLabel")
    topbarIcon.Name = "topbarIcon"
    topbarIcon.Parent = main
    topbarIcon.BackgroundTransparency = 1
    topbarIcon.Position = UDim2.new(0, 16, 0, 10)
    topbarIcon.Size = UDim2.new(0, 48, 0, 48)
    topbarIcon.Image = CONTROL_IMAGE
    topbarIcon.ScaleType = Enum.ScaleType.Fit
    topbarIcon.ZIndex = 10

    local uc_ticon = Instance.new("UICorner")
    uc_ticon.CornerRadius = UDim.new(1, 0)
    uc_ticon.Parent = topbarIcon

    local title = Instance.new("TextLabel")
    title.Name = "title"
    title.Parent = main
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 74, 0, 10)
    title.Size = UDim2.new(0, 250, 0, 48)
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = COL_ACCENT
    title.TextSize = 22
    title.TextWrapped = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center
    title.ZIndex = 10
    title.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    title.TextStrokeTransparency = 0.75 -- difuminado blanco sutil alrededor del texto rojo

    -- pulso suave del difuminado para dar sensación de "glow" animado
    task.spawn(function()
        while title.Parent do
            game:GetService("TweenService"):Create(title, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextStrokeTransparency = 0.4}):Play()
            task.wait(1.2)
            game:GetService("TweenService"):Create(title, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextStrokeTransparency = 0.75}):Play()
            task.wait(1.2)
        end
    end)

    -- ===== FPS y nombre del juego, debajo del título =====
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "statsLabel"
    statsLabel.Parent = main
    statsLabel.BackgroundTransparency = 1
    statsLabel.Position = UDim2.new(0, 74, 0, 34)
    statsLabel.Size = UDim2.new(0, 320, 0, 22)
    statsLabel.Font = Enum.Font.Gotham
    statsLabel.TextColor3 = COL_SUBTEXT
    statsLabel.TextSize = 14
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.TextYAlignment = Enum.TextYAlignment.Top
    statsLabel.ZIndex = 10

    local gameName = "?"
    local okName, resName = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
    if okName and resName then
        gameName = resName
    else
        gameName = game.Name
    end

    local fpsCount = 0
    local fpsAccum = 0
    local fpsTimer = 0
    game:GetService("RunService").Heartbeat:Connect(function(dt)
        fpsAccum += 1
        fpsTimer += dt
        if fpsTimer >= 1 then
            fpsCount = fpsAccum
            fpsAccum = 0
            fpsTimer = 0
            statsLabel.Text = "Fps = " .. fpsCount .. "    Game = " .. gameName
        end
    end)
    statsLabel.Text = "Fps = 0    Game = " .. gameName

    -- fila de controles elegantes (derecha)
    local controls = Instance.new("Frame")
    controls.Name = "controls"
    controls.Parent = main
    controls.AnchorPoint = Vector2.new(1, 0)
    controls.BackgroundTransparency = 1
    controls.Position = UDim2.new(1, -16, 0, 18)
    controls.Size = UDim2.new(0, 106, 0, 28)
    controls.ZIndex = 10

    local ull_ctrl = Instance.new("UIListLayout")
    ull_ctrl.Parent = controls
    ull_ctrl.FillDirection = Enum.FillDirection.Horizontal
    ull_ctrl.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ull_ctrl.VerticalAlignment = Enum.VerticalAlignment.Center
    ull_ctrl.SortOrder = Enum.SortOrder.LayoutOrder
    ull_ctrl.Padding = UDim.new(0, 10)

    local function styledControlButton(nameStr, symbol, baseColor, symbolSize)
        local btn = Instance.new("TextButton")
        btn.Name = nameStr
        btn.Parent = controls
        btn.BackgroundColor3 = baseColor
        btn.BackgroundTransparency = 0.25
        btn.Size = UDim2.new(0, 28, 0, 28)
        btn.AutoButtonColor = false
        btn.Font = Enum.Font.GothamMedium
        btn.Text = symbol
        btn.TextColor3 = COL_TEXT
        btn.TextSize = symbolSize or 16
        btn.ZIndex = 10

        local uc_b = Instance.new("UICorner")
        uc_b.CornerRadius = UDim.new(1, 0)
        uc_b.Parent = btn

        local stroke = Instance.new("UIStroke")
        stroke.Parent = btn
        stroke.Color = Color3.fromRGB(70, 70, 70)
        stroke.Thickness = 1
        stroke.Transparency = 0.4

        addHover(btn, {scaleUp = 1.12, hoverColor = baseColor})
        return btn
    end

    -- [-] colapsar (deja solo la topbar visible)
    local collapseButton = styledControlButton("collapseButton", "–", COL_BTN, 18)

    -- [◻] maximizar/restaurar
    local maximizeButton = styledControlButton("maximizeButton", "▢", COL_BTN, 14)

    -- [X] cerrar (con confirmación sí/no)
    local closeButton = styledControlButton("closeButton", "✕", Color3.fromRGB(60, 20, 20), 14)
    closeButton.BackgroundColor3 = Color3.fromRGB(50, 20, 20)

    -- ===== botón flotante NEGRO, sin bordes, FUERA del menú, siempre visible, movible: minimiza/reabre el menú =====
    local reopenButton = Instance.new("ImageButton")
    reopenButton.Name = "reopenButton"
    reopenButton.Parent = scrgui
    reopenButton.AnchorPoint = Vector2.new(1, 1)
    reopenButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    reopenButton.BackgroundTransparency = 0
    reopenButton.BorderSizePixel = 0
    reopenButton.Position = UDim2.new(1, -30, 1, -30)
    reopenButton.Size = UDim2.new(0, 64, 0, 64)
    reopenButton.Image = CONTROL_IMAGE
    reopenButton.ScaleType = Enum.ScaleType.Fit
    reopenButton.Visible = true
    reopenButton.ZIndex = 50
    -- sin UICorner ni UIStroke: botón plano, cuadrado, sin bordes

    -- animación de aparición
    reopenButton.Size = UDim2.new(0, 0, 0, 0)
    game:GetService("TweenService"):Create(reopenButton, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 64, 0, 64)}):Play()

    addHover(reopenButton, {scaleUp = 1.1})

    -- drag propio para el botón de minimizar (independiente del drag del menú)
    local rbDragging, rbDragStart, rbStartPos, rbDragInput
    local rbMoved = false

    reopenButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            rbDragging = true
            rbMoved = false
            rbDragStart = input.Position
            rbStartPos = reopenButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    rbDragging = false
                end
            end)
        end
    end)

    reopenButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            rbDragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == rbDragInput and rbDragging then
            local delta = input.Position - rbDragStart
            if delta.Magnitude > 3 then
                rbMoved = true
            end
            reopenButton.Position = UDim2.new(
                rbStartPos.X.Scale, rbStartPos.X.Offset + delta.X,
                rbStartPos.Y.Scale, rbStartPos.Y.Offset + delta.Y
            )
        end
    end)

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

    -- notifcation 2 (two button) -- usada para la confirmación de cerrar

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
    main.Size = UDim2.new(0, 0, 0, 0)
    game:GetService("TweenService"):Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0), Size = NORMAL_SIZE}):Play()
    window = {}

    -- ===== [◻] maximizar/restaurar =====
    local isMaximized = false
    local maxAnimating = false

    function window:ToggleMaximize()
        if maxAnimating then return end
        maxAnimating = true
        isMaximized = not isMaximized

        local goalSize = isMaximized and MAX_SIZE or NORMAL_SIZE

        game:GetService("TweenService"):Create(
            main,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            {Size = goalSize}
        ):Play()

        maximizeButton.Text = isMaximized and "❐" or "▢"

        task.wait(0.3)
        maxAnimating = false
    end

    maximizeButton.MouseButton1Click:Connect(function()
        window:ToggleMaximize()
    end)

    -- ===== [X] cerrar con confirmación sí/no =====
    closeButton.MouseButton1Click:Connect(function()
        window:Notify2(
            "¿Cerrar Write Hub?",
            "Esta acción cerrará el menú por completo.",
            "Sí",
            "No",
            nil,
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
            main.Position = UDim2.new(0.5, 0, 0.5, 0)
            game:GetService("TweenService"):Create(
                main,
                TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Size = isMaximized and MAX_SIZE or NORMAL_SIZE}
            ):Play()
            task.wait(0.35)
        else
            local closeTween = game:GetService("TweenService"):Create(
                main,
                TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                {Size = UDim2.new(0, 0, 0, 0)}
            )
            closeTween:Play()
            closeTween.Completed:Wait()
            main.Visible = false
        end

        openAnimating = false
    end

    -- el botón flotante externo oculta/reabre el menú completo
    reopenButton.MouseButton1Click:Connect(function()
        if rbMoved then return end -- evita reabrir el menú justo después de arrastrar el botón
        window:ToggleVisible()
    end)

    -- ===== [-] colapsar: deja visible solo la topbar (icono + título + fps/game + controles) =====
    local isCollapsed = false
    local collapseAnimating = false
    local sizeBeforeCollapse = NORMAL_SIZE
    local collapsibleChildren = {workarea, search, sidebar}

    function window:ToggleCollapse()
        if collapseAnimating then return end
        collapseAnimating = true
        isCollapsed = not isCollapsed

        if isCollapsed then
            sizeBeforeCollapse = isMaximized and MAX_SIZE or NORMAL_SIZE
            for _, child in ipairs(collapsibleChildren) do
                game:GetService("TweenService"):Create(child, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
            end
            local tw = game:GetService("TweenService"):Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = TOPBAR_ONLY_SIZE})
            tw:Play()
            tw.Completed:Wait()
            for _, child in ipairs(collapsibleChildren) do
                child.Visible = false
            end
            collapseButton.Text = "▭"
        else
            for _, child in ipairs(collapsibleChildren) do
                child.Visible = true
                child.BackgroundTransparency = child == workarea and 0 or (child == search and 0 or 1)
            end
            game:GetService("TweenService"):Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = sizeBeforeCollapse}):Play()
            collapseButton.Text = "–"
        end

        collapseAnimating = false
    end

    collapseButton.MouseButton1Click:Connect(function()
        window:ToggleCollapse()
    end)

    if visiblekey then
        game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if input.KeyCode == visiblekey then
                window:ToggleVisible()
            end
        end)
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
        tempnotif.BackgroundTransparency = 0.100
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
        ticon.Image = icon
        ticon.ImageColor3 = COL_TEXT
        ticon.ScaleType = Enum.ScaleType.Fit

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
        game:GetService("Debris"):AddItem(tempnotif, 5)
    end

    function window:Notify(txt1, txt2, b1, icohn, callback)
        if notif.Visible == true or notif2.Visible == true then return "Already visible" end
        notiftitle.Text = txt1
        notiftext.Text = txt2
        notificon = icohn
        notif.Visible = true
        notifbutton1.Text = b1
        if callback then
            con1 = notifbutton1.MouseButton1Click:Connect(function()
                con1:Disconnect()
                callback()
                notif.Visible = false
            end)
        end
    end

    function window:Notify2(txt1, txt2, b1, b2, icohn, callback, callback2)
        if notif.Visible == true or notif2.Visible == true then return "Already visible" end
        notif2title.Text = txt1
        notif2text.Text = txt2
        notif2icon = icohn
        notif2.Visible = true
        notif2button1.Text = b1
        notif2button2.Text = b2
        if callback and callback2 then
            con1 = notif2button1.MouseButton1Click:Connect(function()
                con1:Disconnect()
                con2:Disconnect()
                callback()
                notif2.Visible = false
            end)
            con2 = notif2button2.MouseButton1Click:Connect(function()
                con1:Disconnect()
                con2:Disconnect()
                callback2()
                notif2.Visible = false
            end)
        end
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

        local workareamain = Instance.new("ScrollingFrame")
        workareamain.Name = "workareamain"
        workareamain.Parent = workarea
        workareamain.Active = true
        workareamain.BackgroundColor3 = COL_BG2
        workareamain.BackgroundTransparency = 1
        workareamain.BorderSizePixel = 0
        workareamain.Position = UDim2.new(0.0393013097, 0, 0.0958904102, 0)
        workareamain.Size = UDim2.new(0, 422, 0, 512)
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

            workareamain.Position = UDim2.new(0.0393013097, 15, 0.0958904102, 0)
            local goal = UDim2.new(0.0393013097, 0, 0.0958904102, 0)
            game:GetService("TweenService"):Create(workareamain, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = goal}):Play()
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
                    coroutine.wrap(function()
                        button.TextSize -= 3
                        task.wait(0.06)
                        button.TextSize += 3
                    end)()
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

            -- pista del switch: ahora es un TextButton que ocupa toda la fila detectando clic en cualquier parte
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
            -- el knob no debe interceptar el input; el click siempre lo procesa hitArea
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
                    game:GetService("TweenService"):Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {Position = knobGoal}):Play()
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
            local textfield = Instance.new("TextLabel")
            textfield.Name = "textfield"
            textfield.Parent = workareamain
            textfield.BackgroundColor3 = COL_BG2
            textfield.BackgroundTransparency = 1
            textfield.BorderSizePixel = 2
            textfield.Size = UDim2.new(0, 418, 0, 37)
            textfield.Font = Enum.Font.Gotham
            textfield.Text = name
            textfield.TextColor3 = COL_TEXT
            textfield.TextSize = 21
            textfield.TextWrapped = true
            textfield.TextXAlignment = Enum.TextXAlignment.Left

            local Frame_2 = Instance.new("Frame")
            Frame_2.Parent = textfield
            Frame_2.BackgroundColor3 = COL_BTN
            Frame_2.Position = UDim2.new(0.441926777, 0, 0.0270270277, 0)
            Frame_2.Size = UDim2.new(0, 233, 0, 34)

            local uc_6 = Instance.new("UICorner")
            uc_6.CornerRadius = UDim.new(0, 9)
            uc_6.Parent = Frame_2

            local TextBox = Instance.new("TextBox")
            TextBox.Parent = Frame_2
            TextBox.BackgroundColor3 = COL_BG2
            TextBox.BackgroundTransparency = 1
            TextBox.BorderColor3 = Color3.fromRGB(27, 42, 53)
            TextBox.BorderSizePixel = 0
            TextBox.ClipsDescendants = true
            TextBox.Position = UDim2.new(0.0643776804, 0, 0, -2)
            TextBox.Size = UDim2.new(0, 203, 0, 34)
            TextBox.ClearTextOnFocus = false
            TextBox.Font = Enum.Font.Gotham
            TextBox.LineHeight = 0.870
            TextBox.PlaceholderColor3 = COL_SUBTEXT
            TextBox.PlaceholderText = placeholder or "Type..."
            TextBox.Text = ""
            TextBox.TextColor3 = COL_TEXT
            TextBox.TextSize = 21
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
