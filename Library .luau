local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Library = {}
Library.__index = Library

local BG = Color3.fromRGB(4, 4, 6)
local PANEL = Color3.fromRGB(9, 9, 12)
local FIELD = Color3.fromRGB(3, 3, 5)
local RED = Color3.fromRGB(255, 0, 35)
local TEXT = Color3.fromRGB(255, 255, 255)
local SUBTEXT = Color3.fromRGB(150, 150, 150)

local function corner(inst, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = inst
	return c
end

local function pad(inst, t, b, l, r)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, t)
	p.PaddingBottom = UDim.new(0, b)
	p.PaddingLeft = UDim.new(0, l)
	p.PaddingRight = UDim.new(0, r)
	p.Parent = inst
	return p
end

function Library.new(title, iconId)
	local self = setmetatable({}, Library)

	local gui = Instance.new("ScreenGui")
	gui.Name = "LibraryGui"
	gui.ResetOnSpawn = false
	gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	self.Gui = gui

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 860, 0, 560)
	main.Position = UDim2.new(0.5, -430, 0.5, -280)
	main.BackgroundColor3 = BG
	main.Parent = gui
	corner(main, 8)
	self.Main = main

	local top = Instance.new("Frame")
	top.Size = UDim2.new(1, 0, 0, 54)
	top.BackgroundColor3 = PANEL
	top.Parent = main
	corner(top, 8)

	local topFix = Instance.new("Frame")
	topFix.Size = UDim2.new(1, 0, 0, 8)
	topFix.Position = UDim2.new(0, 0, 1, -8)
	topFix.BackgroundColor3 = PANEL
	topFix.BorderSizePixel = 0
	topFix.Parent = top

	local logo = Instance.new("ImageLabel")
	logo.Size = UDim2.new(0, 44, 0, 44)
	logo.Position = UDim2.new(0, 8, 0.5, -22)
	logo.BackgroundTransparency = 1
	logo.Image = iconId
	corner(logo, 8)
	logo.Parent = top

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0, 220, 1, 0)
	titleLabel.Position = UDim2.new(0, 62, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 22
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = TEXT
	titleLabel.Parent = top

	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, RED),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, RED),
	})
	grad.Parent = titleLabel

	local search = Instance.new("TextBox")
	search.Size = UDim2.new(0, 520, 0, 30)
	search.Position = UDim2.new(0, 300, 0.5, -15)
	search.BackgroundColor3 = FIELD
	search.PlaceholderText = "Search features..."
	search.Text = ""
	search.TextColor3 = TEXT
	search.PlaceholderColor3 = SUBTEXT
	search.Font = Enum.Font.Gotham
	search.TextSize = 12
	corner(search, 6)
	search.Parent = top

	local sidebar = Instance.new("Frame")
	sidebar.Size = UDim2.new(0, 46, 1, -54)
	sidebar.Position = UDim2.new(0, 0, 0, 54)
	sidebar.BackgroundColor3 = PANEL
	sidebar.Parent = main
	self.Sidebar = sidebar

	local sideLayout = Instance.new("UIListLayout")
	sideLayout.Padding = UDim.new(0, 10)
	sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	sideLayout.Parent = sidebar
	pad(sidebar, 14, 0, 0, 0)

	local pages = Instance.new("Frame")
	pages.Size = UDim2.new(1, -46, 1, -54)
	pages.Position = UDim2.new(0, 46, 0, 54)
	pages.BackgroundTransparency = 1
	pages.Parent = main
	self.Pages = pages

	local toggleBtn = Instance.new("ImageButton")
	toggleBtn.Size = UDim2.new(0, 64, 0, 64)
	toggleBtn.Position = UDim2.new(0, 24, 0, 24)
	toggleBtn.BackgroundColor3 = PANEL
	toggleBtn.Image = iconId
	toggleBtn.ScaleType = Enum.ScaleType.Fit
	corner(toggleBtn, 16)
	local stroke = Instance.new("UIStroke")
	stroke.Color = RED
	stroke.Thickness = 3
	stroke.Parent = toggleBtn
	toggleBtn.Parent = gui

	local visible = true
	toggleBtn.MouseButton1Click:Connect(function()
		visible = not visible
		main.Visible = visible
	end)
	self.ToggleButton = toggleBtn

	local dragging, dragStart, startPos
	top.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)

	self._tabCount = 0
	return self
end

function Library:CreateTab(iconId)
	self._tabCount = self._tabCount + 1
	local index = self._tabCount

	local btn = Instance.new("ImageButton")
	btn.Size = UDim2.new(0, 22, 0, 22)
	btn.BackgroundTransparency = 1
	btn.Image = iconId
	btn.ImageColor3 = index == 1 and RED or TEXT
	btn.LayoutOrder = index
	btn.Parent = self.Sidebar

	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.CanvasSize = UDim2.new(0, 0, 0, 900)
	page.ScrollBarThickness = 3
	page.Visible = index == 1
	page.Parent = self.Pages

	local leftCol = Instance.new("Frame")
	leftCol.Size = UDim2.new(0.5, -14, 1, 0)
	leftCol.Position = UDim2.new(0, 8, 0, 8)
	leftCol.BackgroundTransparency = 1
	leftCol.AutomaticSize = Enum.AutomaticSize.Y
	leftCol.Parent = page
	local ll = Instance.new("UIListLayout")
	ll.Padding = UDim.new(0, 8)
	ll.Parent = leftCol

	local rightCol = Instance.new("Frame")
	rightCol.Size = UDim2.new(0.5, -14, 1, 0)
	rightCol.Position = UDim2.new(0.5, 6, 0, 8)
	rightCol.BackgroundTransparency = 1
	rightCol.AutomaticSize = Enum.AutomaticSize.Y
	rightCol.Parent = page
	local rl = Instance.new("UIListLayout")
	rl.Padding = UDim.new(0, 8)
	rl.Parent = rightCol

	for _, otherPage in ipairs(self.Pages:GetChildren()) do
		if otherPage:IsA("ScrollingFrame") then otherPage.Visible = false end
	end
	page.Visible = index == 1

	btn.MouseButton1Click:Connect(function()
		for _, otherPage in ipairs(self.Pages:GetChildren()) do
			if otherPage:IsA("ScrollingFrame") then otherPage.Visible = false end
		end
		for _, otherBtn in ipairs(self.Sidebar:GetChildren()) do
			if otherBtn:IsA("ImageButton") then otherBtn.ImageColor3 = TEXT end
		end
		page.Visible = true
		btn.ImageColor3 = RED
	end)

	return { LeftColumn = leftCol, RightColumn = rightCol, Page = page }
end

function Library:CreateSection(column, title, iconId, order)
	local libGui = self.Gui

	local sec = Instance.new("Frame")
	sec.Size = UDim2.new(1, 0, 0, 30)
	sec.BackgroundColor3 = PANEL
	sec.AutomaticSize = Enum.AutomaticSize.Y
	sec.LayoutOrder = order or 0
	corner(sec, 6)
	sec.Parent = column

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.Parent = sec
	pad(sec, 8, 8, 10, 10)

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 16)
	header.BackgroundTransparency = 1
	header.LayoutOrder = 0
	header.Parent = sec

	if iconId then
		local icon = Instance.new("ImageLabel")
		icon.Size = UDim2.new(0, 14, 0, 14)
		icon.Position = UDim2.new(0, 0, 0.5, -7)
		icon.BackgroundTransparency = 1
		icon.Image = iconId
		icon.ImageColor3 = TEXT
		icon.Parent = header
	end

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, 0)
	label.Position = UDim2.new(0, iconId and 20 or 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = title
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = TEXT
	label.Parent = header

	local order2 = 0
	local section = {}

	local function nextOrder()
		order2 = order2 + 2
		return order2
	end

	function section:AddLabel(text)
		local o = nextOrder()
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, 0, 0, 14)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = SUBTEXT
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 11
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.LayoutOrder = o
		lbl.Parent = sec
		return lbl
	end

	function section:AddDropdown(text, options, callback)
		section:AddLabel(text)
		local o = nextOrder()

		local dd = Instance.new("TextButton")
		dd.Size = UDim2.new(1, 0, 0, 30)
		dd.BackgroundColor3 = FIELD
		dd.Text = (options and options[1]) or "Select..."
		dd.TextColor3 = TEXT
		dd.Font = Enum.Font.Gotham
		dd.TextSize = 12
		dd.TextXAlignment = Enum.TextXAlignment.Left
		dd.LayoutOrder = o
		corner(dd, 5)
		pad(dd, 0, 0, 10, 10)
		dd.Parent = sec

		local arrow = Instance.new("TextLabel")
		arrow.Size = UDim2.new(0, 20, 1, 0)
		arrow.Position = UDim2.new(1, -26, 0, 0)
		arrow.BackgroundTransparency = 1
		arrow.Text = "v"
		arrow.TextColor3 = RED
		arrow.Font = Enum.Font.GothamBold
		arrow.TextSize = 12
		arrow.Parent = dd

		local listFrame, open = nil, false

		local function closeList()
			if listFrame then
				listFrame:Destroy()
				listFrame = nil
			end
			open = false
			arrow.Text = "v"
		end

		local function openList()
			closeList()
			open = true
			arrow.Text = "^"

			listFrame = Instance.new("Frame")
			listFrame.BackgroundColor3 = FIELD
			listFrame.BorderSizePixel = 0
			listFrame.ZIndex = 50
			corner(listFrame, 5)
			local os_ = Instance.new("UIStroke")
			os_.Color = RED
			os_.Thickness = 1
			os_.Parent = listFrame

			local ll = Instance.new("UIListLayout")
			ll.Parent = listFrame

			local absPos = dd.AbsolutePosition
			local absSize = dd.AbsoluteSize
			listFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
			listFrame.Size = UDim2.new(0, absSize.X, 0, math.min(#(options or {}), 6) * 26)
			listFrame.Parent = libGui

			for _, opt in ipairs(options or {}) do
				local optBtn = Instance.new("TextButton")
				optBtn.Size = UDim2.new(1, 0, 0, 26)
				optBtn.BackgroundColor3 = FIELD
				optBtn.Text = opt
				optBtn.TextColor3 = TEXT
				optBtn.Font = Enum.Font.Gotham
				optBtn.TextSize = 12
				optBtn.ZIndex = 51
				optBtn.Parent = listFrame
				optBtn.MouseButton1Click:Connect(function()
					dd.Text = opt
					closeList()
					if callback then callback(opt) end
				end)
			end
		end

		dd.MouseButton1Click:Connect(function()
			if open then closeList() else openList() end
		end)

		UIS.InputBegan:Connect(function(input)
			if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
				local mp = UIS:GetMouseLocation()
				if listFrame then
					local lp, ls = listFrame.AbsolutePosition, listFrame.AbsoluteSize
					local ddp, dds = dd.AbsolutePosition, dd.AbsoluteSize
					local insideList = mp.X >= lp.X and mp.X <= lp.X + ls.X and mp.Y >= lp.Y and mp.Y <= lp.Y + ls.Y
					local insideDd = mp.X >= ddp.X and mp.X <= ddp.X + dds.X and mp.Y >= ddp.Y and mp.Y <= ddp.Y + dds.Y
					if not insideList and not insideDd then closeList() end
				end
			end
		end)

		return dd
	end

	function section:AddToggle(text, callback)
		local o = nextOrder()
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 20)
		row.BackgroundTransparency = 1
		row.LayoutOrder = o
		row.Parent = sec

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -50, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = TEXT
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 12
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local track = Instance.new("TextButton")
		track.Size = UDim2.new(0, 36, 0, 18)
		track.Position = UDim2.new(1, -36, 0.5, -9)
		track.BackgroundColor3 = FIELD
		track.Text = ""
		corner(track, 9)
		track.Parent = row

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 14, 0, 14)
		knob.Position = UDim2.new(0, 2, 0.5, -7)
		knob.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
		corner(knob, 7)
		knob.Parent = track

		local state = false
		track.MouseButton1Click:Connect(function()
			state = not state
			track.BackgroundColor3 = state and RED or FIELD
			TweenService:Create(knob, TweenInfo.new(0.15), {
				Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
			}):Play()
			if callback then callback(state) end
		end)
		return row
	end

	function section:AddSlider(text, min, max, default, callback)
		local o = nextOrder()
		local lbl = section:AddLabel(text .. "  " .. tostring(default))
		lbl.LayoutOrder = o

		local o2 = nextOrder()
		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1, 0, 0, 3)
		bar.BackgroundColor3 = FIELD
		bar.LayoutOrder = o2
		corner(bar, 2)
		bar.Parent = sec

		local ratio = (default - min) / (max - min)
		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(ratio, 0, 1, 0)
		fill.BackgroundColor3 = RED
		corner(fill, 2)
		fill.Parent = bar

		local knob = Instance.new("TextButton")
		knob.Size = UDim2.new(0, 12, 0, 12)
		knob.Position = UDim2.new(ratio, -6, 0.5, -6)
		knob.BackgroundColor3 = RED
		knob.Text = ""
		corner(knob, 6)
		knob.Parent = bar

		local dragging = false
		knob.MouseButton1Down:Connect(function() dragging = true end)
		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
		UIS.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
				local value = min + (max - min) * rel
				fill.Size = UDim2.new(rel, 0, 1, 0)
				knob.Position = UDim2.new(rel, -6, 0.5, -6)
				lbl.Text = text .. "  " .. tostring(math.floor(value * 100) / 100)
				if callback then callback(value) end
			end
		end)
		return bar
	end

	function section:AddButton(text, callback)
		local o = nextOrder()
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 28)
		btn.BackgroundColor3 = RED
		btn.Text = text
		btn.TextColor3 = TEXT
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.LayoutOrder = o
		corner(btn, 5)
		btn.Parent = sec
		btn.MouseButton1Click:Connect(function()
			if callback then callback() end
		end)
		return btn
	end

	return section
end

return Library
