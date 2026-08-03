-- [[ Write Hub - Premium Complete Edition ]]
-- Elegante, Minimalista y Funcional

local lib = {}
local sections = {}
local workareas = {}
local visible = true

-- Paleta de colores Premium (Deep Dark & Vivid Red)
local COL_BG = Color3.fromRGB(10, 10, 10)
local COL_BG2 = Color3.fromRGB(15, 15, 15)
local COL_BTN = Color3.fromRGB(22, 22, 22)
local COL_TEXT = Color3.fromRGB(245, 245, 245)
local COL_SUBTEXT = Color3.fromRGB(160, 160, 160)
local COL_ACCENT = Color3.fromRGB(255, 45, 55)
local COL_STROKE = Color3.fromRGB(40, 40, 40)

-- Assets
local CONTROL_IMAGE = "rbxthumb://type=Asset&id=86868808077613&w=150&h=150"
local ICON_CLOSE = "rbxthumb://type=Asset&id=111147657950432&w=150&h=150"
local ICON_COLLAPSE = "rbxthumb://type=Asset&id=119364000008939&w=150&h=150"
local ICON_EXPAND = "rbxthumb://type=Asset&id=76932851909318&w=150&h=150"

local NORMAL_SIZE = UDim2.new(0, 720, 0, 540)
local MAX_SIZE = UDim2.new(0, 880, 0, 680)

-- [[ Utilidades de Animación ]]
local function tween(ins, info, goal)
    local tw = game:GetService("TweenService"):Create(ins, info, goal)
    tw:Play()
    return tw
end

local function addHover(btn, opts)
    opts = opts or {}
    local scaleUp = opts.scaleUp or 1.02
    local hoverColor = opts.hoverColor
    local baseColor = btn.BackgroundColor3
    local baseSize = btn.Size

    btn.MouseEnter:Connect(function()
        tween(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(baseSize.X.Scale, baseSize.X.Offset * scaleUp, baseSize.Y.Scale, baseSize.Y.Offset * scaleUp),
            BackgroundColor3 = hoverColor or baseColor
        })
    end)

    btn.MouseLeave:Connect(function()
        tween(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = baseSize,
            BackgroundColor3 = baseColor
        })
    end)
end

function lib:init(ti, dosplash, visiblekey, deleteprevious)
    local scrgui = Instance.new("ScreenGui")
    if syn and syn.protect_gui then syn.protect_gui(scrgui) end
    scrgui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
    scrgui.Name = "WriteHub_Premium"

    if deleteprevious then
        for _, v in pairs(scrgui.Parent:GetChildren()) do
            if v.Name == scrgui.Name and v ~= scrgui then v:Destroy() end
        end
    end

    -- Main Frame
    local main = Instance.new("Frame")
    main.Name = "main"
    main.Parent = scrgui
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = COL_BG
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.Size = UDim2.new(0, 0, 0, 0)
    main.ClipsDescendants = true
    
    local uc = Instance.new("UICorner")
    uc.CornerRadius = UDim.new(0, 14)
    uc.Parent = main

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.2
    stroke.Color = COL_STROKE
    stroke.Parent = main

    -- Draggable
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    main.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Sidebar Area
    local sidebar = Instance.new("ScrollingFrame")
    sidebar.Name = "sidebar"
    sidebar.Parent = main
    sidebar.BackgroundTransparency = 1
    sidebar.Position = UDim2.new(0, 15, 0, 70)
    sidebar.Size = UDim2.new(0, 200, 1, -150)
    sidebar.ScrollBarThickness = 0
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.AutomaticCanvasSize = "Y"

    local ull = Instance.new("UIListLayout")
    ull.Parent = sidebar
    ull.Padding = UDim.new(0, 8)

    -- Workarea
    local workarea = Instance.new("Frame")
    workarea.Name = "workarea"
    workarea.Parent = main
    workarea.BackgroundColor3 = COL_BG2
    workarea.Position = UDim2.new(0, 230, 0, 70)
    workarea.Size = UDim2.new(1, -245, 1, -85)
    
    local uc2 = Instance.new("UICorner")
    uc2.CornerRadius = UDim.new(0, 12)
    uc2.Parent = workarea

    local wstroke = Instance.new("UIStroke")
    wstroke.Thickness = 1
    wstroke.Color = COL_STROKE
    wstroke.Transparency = 0.5
    wstroke.Parent = workarea

    -- Topbar
    local topbar = Instance.new("Frame")
    topbar.Name = "topbar"
    topbar.Parent = main
    topbar.BackgroundTransparency = 1
    topbar.Size = UDim2.new(1, 0, 0, 60)

    local title = Instance.new("TextLabel")
    title.Parent = topbar
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 20, 0, 0)
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = ti or "WRITE HUB"
    title.TextColor3 = COL_TEXT
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left

    local subtitle = Instance.new("TextLabel")
    subtitle.Parent = topbar
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.new(0, 20, 0, 35)
    subtitle.Size = UDim2.new(0, 200, 0, 15)
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = "PREMIUM EDITION"
    subtitle.TextColor3 = COL_SUBTEXT
    subtitle.TextSize = 10
    subtitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Control Buttons
    local controls = Instance.new("Frame")
    controls.Parent = topbar
    controls.BackgroundTransparency = 1
    controls.Position = UDim2.new(1, -110, 0, 0)
    controls.Size = UDim2.new(0, 100, 1, 0)

    local function createControl(name, icon, color)
        local btn = Instance.new("ImageButton")
        btn.Name = name
        btn.Parent = controls
        btn.BackgroundTransparency = 1
        btn.Size = UDim2.new(0, 22, 0, 22)
        btn.Image = icon
        btn.ImageColor3 = color or COL_SUBTEXT
        return btn
    end

    local closeBtn = createControl("Close", ICON_CLOSE, COL_ACCENT)
    local maxBtn = createControl("Max", ICON_EXPAND)
    local minBtn = createControl("Min", ICON_COLLAPSE)

    local cll = Instance.new("UIListLayout")
    cll.Parent = controls
    cll.FillDirection = Enum.FillDirection.Horizontal
    cll.HorizontalAlignment = Enum.HorizontalAlignment.Right
    cll.VerticalAlignment = Enum.VerticalAlignment.Center
    cll.Padding = UDim.new(0, 12)

    -- Profile Section
    local player = game:GetService("Players").LocalPlayer
    local profile = Instance.new("Frame")
    profile.Name = "profile"
    profile.Parent = main
    profile.BackgroundColor3 = COL_BG2
    profile.Position = UDim2.new(0, 15, 1, -75)
    profile.Size = UDim2.new(0, 200, 0, 60)
    
    local uc3 = Instance.new("UICorner")
    uc3.CornerRadius = UDim.new(0, 10)
    uc3.Parent = profile

    local pstroke = Instance.new("UIStroke")
    pstroke.Thickness = 1
    pstroke.Color = COL_STROKE
    pstroke.Parent = profile

    local avatar = Instance.new("ImageLabel")
    avatar.Parent = profile
    avatar.Position = UDim2.new(0, 10, 0.5, 0)
    avatar.AnchorPoint = Vector2.new(0, 0.5)
    avatar.Size = UDim2.new(0, 40, 0, 40)
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
    avatar.BackgroundColor3 = COL_BTN
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

    local userLabel = Instance.new("TextLabel")
    userLabel.Parent = profile
    userLabel.BackgroundTransparency = 1
    userLabel.Position = UDim2.new(0, 60, 0.25, 0)
    userLabel.Size = UDim2.new(1, -70, 0, 15)
    userLabel.Font = Enum.Font.GothamBold
    userLabel.Text = player.Name:upper()
    userLabel.TextColor3 = COL_TEXT
    userLabel.TextSize = 12
    userLabel.TextXAlignment = Enum.TextXAlignment.Left

    local idLabel = Instance.new("TextLabel")
    idLabel.Parent = profile
    idLabel.BackgroundTransparency = 1
    idLabel.Position = UDim2.new(0, 60, 0.55, 0)
    idLabel.Size = UDim2.new(1, -70, 0, 15)
    idLabel.Font = Enum.Font.Gotham
    idLabel.Text = "ID: " .. player.UserId
    idLabel.TextColor3 = COL_SUBTEXT
    idLabel.TextSize = 10
    idLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Notifications
    local notifFrame = Instance.new("Frame")
    notifFrame.Name = "notifFrame"
    notifFrame.Parent = main
    notifFrame.BackgroundColor3 = COL_BG
    notifFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    notifFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    notifFrame.Size = UDim2.new(0, 300, 0, 200)
    notifFrame.Visible = false
    notifFrame.ZIndex = 100
    Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", notifFrame).Color = COL_ACCENT

    local notifTitle = Instance.new("TextLabel")
    notifTitle.Parent = notifFrame
    notifTitle.Size = UDim2.new(1, 0, 0, 40)
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.TextColor3 = COL_TEXT
    notifTitle.TextSize = 16
    notifTitle.BackgroundTransparency = 1

    local notifText = Instance.new("TextLabel")
    notifText.Parent = notifFrame
    notifText.Position = UDim2.new(0, 15, 0, 45)
    notifText.Size = UDim2.new(1, -30, 0, 80)
    notifText.Font = Enum.Font.Gotham
    notifText.TextColor3 = COL_SUBTEXT
    notifText.TextSize = 14
    notifText.TextWrapped = true
    notifText.BackgroundTransparency = 1

    local notifBtn1 = Instance.new("TextButton")
    notifBtn1.Parent = notifFrame
    notifBtn1.Size = UDim2.new(0, 120, 0, 35)
    notifBtn1.Position = UDim2.new(0.5, -60, 1, -50)
    notifBtn1.BackgroundColor3 = COL_ACCENT
    notifBtn1.Font = Enum.Font.GothamBold
    notifBtn1.TextColor3 = COL_TEXT
    notifBtn1.TextSize = 14
    Instance.new("UICorner", notifBtn1).CornerRadius = UDim.new(0, 8)

    -- Initial Animation
    tween(main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = NORMAL_SIZE})

    -- Logic
    closeBtn.MouseButton1Click:Connect(function()
        tween(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
        task.wait(0.4)
        scrgui:Destroy()
    end)

    local isMax = false
    maxBtn.MouseButton1Click:Connect(function()
        isMax = not isMax
        tween(main, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = isMax and MAX_SIZE or NORMAL_SIZE})
    end)

    local isCollapsed = false
    minBtn.MouseButton1Click:Connect(function()
        isCollapsed = not isCollapsed
        tween(main, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = isCollapsed and UDim2.new(0, NORMAL_SIZE.X.Offset, 0, 60) or NORMAL_SIZE})
        workarea.Visible = not isCollapsed
        sidebar.Visible = not isCollapsed
        profile.Visible = not isCollapsed
    end)

    local window = {}

    function window:SetSubtitle(text)
        subtitle.Text = text:upper()
    end

    function window:Notify(txt1, txt2, b1, callback)
        notifTitle.Text = txt1:upper()
        notifText.Text = txt2
        notifBtn1.Text = b1:upper()
        notifBtn1.Size = UDim2.new(0, 200, 0, 35)
        notifBtn1.Position = UDim2.new(0.5, -100, 1, -50)
        notifFrame.Visible = true
        local conn
        conn = notifBtn1.MouseButton1Click:Connect(function()
            conn:Disconnect()
            notifFrame.Visible = false
            if callback then callback() end
        end)
    end

    function window:Notify2(txt1, txt2, b1, b2, callback1, callback2)
        notifTitle.Text = txt1:upper()
        notifText.Text = txt2
        
        local btn1 = notifBtn1
        btn1.Text = b1:upper()
        btn1.Size = UDim2.new(0, 130, 0, 35)
        btn1.Position = UDim2.new(0.5, -135, 1, -50)

        local btn2 = btn1:Clone()
        btn2.Parent = notifFrame
        btn2.Text = b2:upper()
        btn2.Position = UDim2.new(0.5, 5, 1, -50)
        btn2.BackgroundColor3 = COL_BTN
        btn2.UIStroke.Color = COL_STROKE

        notifFrame.Visible = true
        
        local c1, c2
        c1 = btn1.MouseButton1Click:Connect(function()
            c1:Disconnect(); c2:Disconnect()
            notifFrame.Visible = false
            btn2:Destroy()
            if callback1 then callback1() end
        end)
        c2 = btn2.MouseButton1Click:Connect(function()
            c1:Disconnect(); c2:Disconnect()
            notifFrame.Visible = false
            btn2:Destroy()
            if callback2 then callback2() end
        end)
    end

    function window:TempNotify(txt1, txt2)
        local t = Instance.new("Frame")
        t.Parent = scrgui
        t.Size = UDim2.new(0, 280, 0, 80)
        t.Position = UDim2.new(1, 20, 0.9, -100)
        t.BackgroundColor3 = COL_BG
        Instance.new("UICorner", t).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", t).Color = COL_ACCENT
        
        local tl1 = Instance.new("TextLabel")
        tl1.Parent = t
        tl1.Position = UDim2.new(0, 15, 0, 10)
        tl1.Size = UDim2.new(1, -30, 0, 20)
        tl1.Font = Enum.Font.GothamBold
        tl1.Text = txt1:upper()
        tl1.TextColor3 = COL_TEXT
        tl1.TextSize = 14
        tl1.TextXAlignment = Enum.TextXAlignment.Left
        tl1.BackgroundTransparency = 1

        local tl2 = Instance.new("TextLabel")
        tl2.Parent = t
        tl2.Position = UDim2.new(0, 15, 0, 30)
        tl2.Size = UDim2.new(1, -30, 0, 40)
        tl2.Font = Enum.Font.Gotham
        tl2.Text = txt2
        tl2.TextColor3 = COL_SUBTEXT
        tl2.TextSize = 12
        tl2.TextWrapped = true
        tl2.TextXAlignment = Enum.TextXAlignment.Left
        tl2.BackgroundTransparency = 1

        tween(t, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(1, -300, 0.9, -100)})
        task.delay(4, function()
            tween(t, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 0.9, -100)})
            task.wait(0.5)
            t:Destroy()
        end)
    end

    function window:Section(name)
        local btn = Instance.new("TextButton")
        btn.Parent = sidebar
        btn.BackgroundColor3 = COL_BTN
        btn.Size = UDim2.new(1, 0, 0, 42)
        btn.Font = Enum.Font.GothamMedium
        btn.Text = name:upper()
        btn.TextColor3 = COL_SUBTEXT
        btn.TextSize = 13
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local bstroke = Instance.new("UIStroke", btn)
        bstroke.Thickness = 1
        bstroke.Color = COL_STROKE

        local container = Instance.new("ScrollingFrame")
        container.Parent = workarea
        container.Size = UDim2.new(1, -20, 1, -20)
        container.Position = UDim2.new(0, 10, 0, 10)
        container.BackgroundTransparency = 1
        container.Visible = false
        container.ScrollBarThickness = 0
        container.CanvasSize = UDim2.new(0, 0, 0, 0)
        container.AutomaticCanvasSize = "Y"
        
        local cll2 = Instance.new("UIListLayout")
        cll2.Parent = container
        cll2.Padding = UDim.new(0, 10)
        cll2.HorizontalAlignment = Enum.HorizontalAlignment.Center

        table.insert(sections, btn)
        table.insert(workareas, container)

        btn.MouseButton1Click:Connect(function()
            for _, v in pairs(sections) do 
                tween(v, TweenInfo.new(0.3), {BackgroundColor3 = COL_BTN, TextColor3 = COL_SUBTEXT})
                v.UIStroke.Color = COL_STROKE
            end
            for _, v in pairs(workareas) do v.Visible = false end
            tween(btn, TweenInfo.new(0.3), {BackgroundColor3 = COL_ACCENT, TextColor3 = COL_TEXT})
            btn.UIStroke.Color = COL_ACCENT
            container.Visible = true
        end)

        local sec = {}
        
        function sec:Button(text, callback)
            local b = Instance.new("TextButton")
            b.Parent = container
            b.BackgroundColor3 = COL_BTN
            b.Size = UDim2.new(0, 420, 0, 40)
            b.Font = Enum.Font.Gotham
            b.Text = text
            b.TextColor3 = COL_TEXT
            b.TextSize = 14
            b.AutoButtonColor = false
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            local bs = Instance.new("UIStroke", b)
            bs.Thickness = 1
            bs.Color = COL_STROKE

            addHover(b, {hoverColor = Color3.fromRGB(30, 30, 30)})
            b.MouseButton1Click:Connect(callback)
        end

        function sec:Switch(text, default, callback)
            local state = default
            local f = Instance.new("Frame")
            f.Parent = container
            f.BackgroundColor3 = COL_BTN
            f.Size = UDim2.new(0, 420, 0, 40)
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", f).Color = COL_STROKE

            local l = Instance.new("TextLabel")
            l.Parent = f
            l.BackgroundTransparency = 1
            l.Position = UDim2.new(0, 15, 0, 0)
            l.Size = UDim2.new(1, -70, 1, 0)
            l.Font = Enum.Font.Gotham
            l.Text = text
            l.TextColor3 = COL_TEXT
            l.TextSize = 14
            l.TextXAlignment = Enum.TextXAlignment.Left

            local tog = Instance.new("TextButton")
            tog.Parent = f
            tog.AnchorPoint = Vector2.new(1, 0.5)
            tog.Position = UDim2.new(1, -10, 0.5, 0)
            tog.Size = UDim2.new(0, 38, 0, 20)
            tog.BackgroundColor3 = state and COL_ACCENT or COL_STROKE
            tog.Text = ""
            Instance.new("UICorner", tog).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame")
            knob.Parent = tog
            knob.Size = UDim2.new(0, 16, 0, 16)
            knob.Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            knob.AnchorPoint = Vector2.new(0, 0.5)
            knob.BackgroundColor3 = COL_TEXT
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            tog.MouseButton1Click:Connect(function()
                state = not state
                tween(tog, TweenInfo.new(0.2), {BackgroundColor3 = state and COL_ACCENT or COL_STROKE})
                tween(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)})
                callback(state)
            end)
        end

        function sec:TextField(text, placeholder, callback)
            local f = Instance.new("Frame")
            f.Parent = container
            f.BackgroundColor3 = COL_BTN
            f.Size = UDim2.new(0, 420, 0, 45)
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", f).Color = COL_STROKE

            local l = Instance.new("TextLabel")
            l.Parent = f
            l.BackgroundTransparency = 1
            l.Position = UDim2.new(0, 15, 0, 0)
            l.Size = UDim2.new(0, 150, 1, 0)
            l.Font = Enum.Font.Gotham
            l.Text = text
            l.TextColor3 = COL_TEXT
            l.TextSize = 14
            l.TextXAlignment = Enum.TextXAlignment.Left

            local tb = Instance.new("TextBox")
            tb.Parent = f
            tb.BackgroundColor3 = COL_BG2
            tb.Position = UDim2.new(1, -240, 0.5, 0)
            tb.AnchorPoint = Vector2.new(0, 0.5)
            tb.Size = UDim2.new(0, 230, 0, 30)
            tb.Font = Enum.Font.Gotham
            tb.PlaceholderText = placeholder or "Escribe aquí..."
            tb.Text = ""
            tb.TextColor3 = COL_TEXT
            tb.TextSize = 13
            Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", tb).Color = COL_STROKE

            tb.FocusLost:Connect(function()
                callback(tb.Text)
            end)
        end

        function sec:Label(text)
            local l = Instance.new("TextLabel")
            l.Parent = container
            l.BackgroundTransparency = 1
            l.Size = UDim2.new(0, 420, 0, 30)
            l.Font = Enum.Font.Gotham
            l.Text = text
            l.TextColor3 = COL_SUBTEXT
            l.TextSize = 14
        end

        return sec
    end

    return window
end

return lib
