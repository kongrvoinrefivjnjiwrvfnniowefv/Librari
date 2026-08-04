local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local RED = Color3.fromRGB(220, 40, 40)
local BG = Color3.fromRGB(18, 18, 20)
local PANEL = Color3.fromRGB(26, 26, 30)
local TEXT = Color3.fromRGB(235, 235, 235)
local SUBTEXT = Color3.fromRGB(160, 160, 160)

local gui = Instance.new("ScreenGui")
gui.Name = "TestMenu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main window
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 860, 0, 560)
main.Position = UDim2.new(0.5, -430, 0.5, -280)
main.BackgroundColor3 = BG
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

-- Top bar
local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 44)
top.BackgroundColor3 = PANEL
top.Parent = main
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 8)

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0, 28, 0, 28)
logo.Position = UDim2.new(0, 10, 0.5, -14)
logo.BackgroundTransparency = 1
logo.Image = "rbxthumb://type=Asset&id=86868808077613&w=150&h=150"
Instance.new("UICorner", logo).CornerRadius = UDim.new(1, 0)
logo.Parent = top

local function tag(text, x, filled)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(0, 46, 0, 20)
	t.Position = UDim2.new(0, x, 0.5, -10)
	t.BackgroundColor3 = filled and RED or BG
	t.Text = text
	t.TextColor3 = TEXT
	t.Font = Enum.Font.GothamBold
	t.TextSize = 11
	Instance.new("UICorner", t).CornerRadius = UDim.new(0, 5)
	t.Parent = top
	return t
end
tag("FREE", 45, true)
tag("v2.6.0", 95, false)

local search = Instance.new("TextBox")
search.Size = UDim2.new(0, 620, 0, 26)
search.Position = UDim2.new(0, 150, 0.5, -13)
search.BackgroundColor3 = BG
search.PlaceholderText = "Search features..."
search.Text = ""
search.TextColor3 = TEXT
search.PlaceholderColor3 = SUBTEXT
search.Font = Enum.Font.Gotham
search.TextSize = 12
Instance.new("UICorner", search).CornerRadius = UDim.new(0, 5)
search.Parent = top

-- Minimize button (inside top bar)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -34, 0.5, -13)
minBtn.BackgroundColor3 = BG
minBtn.Text = "-"
minBtn.TextColor3 = TEXT
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 5)
minBtn.Parent = top

-- Reopen button (outside menu, floating)
local reopenBtn = Instance.new("ImageButton")
reopenBtn.Size = UDim2.new(0, 46, 0, 46)
reopenBtn.Position = UDim2.new(0, 20, 0, 20)
reopenBtn.BackgroundColor3 = PANEL
reopenBtn.Image = "rbxthumb://type=Asset&id=86868808077613&w=150&h=150"
reopenBtn.Visible = false
Instance.new("UICorner", reopenBtn).CornerRadius = UDim.new(1, 0)
reopenBtn.Parent = gui

minBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	reopenBtn.Visible = true
end)
reopenBtn.MouseButton1Click:Connect(function()
	main.Visible = true
	reopenBtn.Visible = false
end)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 44, 1, -44)
sidebar.Position = UDim2.new(0, 0, 0, 44)
sidebar.BackgroundColor3 = PANEL
sidebar.Parent = main

local sideIcons = {
	"rbxassetid://6031091004",
	"rbxassetid://6034287594",
	"rbxassetid://6031280882",
	"rbxassetid://6031280935",
}
for i, id in ipairs(sideIcons) do
	local btn = Instance.new("ImageButton")
	btn.Size = UDim2.new(0, 22, 0, 22)
	btn.Position = UDim2.new(0.5, -11, 0, 14 + (i - 1) * 44)
	btn.BackgroundTransparency = 1
	btn.Image = id
	btn.ImageColor3 = i == 1 and RED or TEXT
	btn.Parent = sidebar
end

-- Content
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -44, 1, -44)
content.Position = UDim2.new(0, 44, 0, 44)
content.BackgroundTransparency = 1
content.CanvasSize = UDim2.new(0, 0, 0, 900)
content.ScrollBarThickness = 3
content.Parent = main

local leftCol = Instance.new("Frame")
leftCol.Size = UDim2.new(0.5, -15, 1, 0)
leftCol.Position = UDim2.new(0, 8, 0, 8)
leftCol.BackgroundTransparency = 1
leftCol.Parent = content
local leftLayout = Instance.new("UIListLayout")
leftLayout.Padding = UDim.new(0, 8)
leftLayout.Parent = leftCol

local rightCol = leftCol:Clone()
rightCol.Position = UDim2.new(0.5, 7, 0, 8)
rightCol.Parent = content

local function makeSection(parent, title, iconId, order)
	local sec = Instance.new("Frame")
	sec.Size = UDim2.new(1, 0, 0, 30)
	sec.BackgroundColor3 = PANEL
	sec.AutomaticSize = Enum.AutomaticSize.Y
	sec.LayoutOrder = order
	Instance.new("UICorner", sec).CornerRadius = UDim.new(0, 6)
	sec.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 6)
	layout.Parent = sec

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = sec

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 16)
	header.BackgroundTransparency = 1
	header.LayoutOrder = 0
	header.Parent = sec

	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.new(0, 14, 0, 14)
	icon.Position = UDim2.new(0, 0, 0.5, -7)
	icon.BackgroundTransparency = 1
	icon.Image = iconId
	icon.ImageColor3 = TEXT
	icon.Parent = header

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, 0)
	label.Position = UDim2.new(0, 20, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = title
	label.TextColor3 = TEXT
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = header

	return sec
end

local function addLabel(sec, text, order)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 14)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = SUBTEXT
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.LayoutOrder = order
	lbl.Parent = sec
end

local function addDropdown(sec, text, order)
	addLabel(sec, text, order)
	local dd = Instance.new("TextButton")
	dd.Size = UDim2.new(1, 0, 0, 28)
	dd.BackgroundColor3 = BG
	dd.Text = "test"
	dd.TextColor3 = TEXT
	dd.Font = Enum.Font.Gotham
	dd.TextSize = 12
	dd.LayoutOrder = order + 1
	Instance.new("UICorner", dd).CornerRadius = UDim.new(0, 5)
	dd.Parent = sec
	dd.MouseButton1Click:Connect(function() print("test") end)
end

local function addToggle(sec, text, order)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 20)
	row.BackgroundTransparency = 1
	row.LayoutOrder = order
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
	track.BackgroundColor3 = BG
	track.Text = ""
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
	track.Parent = row

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new(0, 2, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
	knob.Parent = track

	local on = false
	track.MouseButton1Click:Connect(function()
		on = not on
		track.BackgroundColor3 = on and RED or BG
		knob:TweenPosition(on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.15, true)
		print("test")
	end)
end

local function addSlider(sec, text, order, defaultVal)
	addLabel(sec, text .. "  " .. tostring(defaultVal), order)
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, 0, 0, 3)
	bar.BackgroundColor3 = BG
	bar.LayoutOrder = order + 1
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
	bar.Parent = sec

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0.5, 0, 1, 0)
	fill.BackgroundColor3 = RED
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
	fill.Parent = bar

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = UDim2.new(0.5, -6, 0.5, -6)
	knob.BackgroundColor3 = RED
	knob.Text = ""
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
	knob.Parent = bar

	local dragging = false
	knob.MouseButton1Down:Connect(function() dragging = true end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, -6, 0.5, -6)
			print("test")
		end
	end)
end

local autoWin = makeSection(leftCol, "Auto Win", "rbxassetid://6034953241", 0)
addDropdown(autoWin, "Target Win Block", 1)
addDropdown(autoWin, "Start from checkpoint", 3)
addToggle(autoWin, "Auto Collect Special Key", 5)
addSlider(autoWin, "Travel speed (% WalkSpeed)", 6, 120)
addSlider(autoWin, "Delay each run (s)", 8, 0.0)
addToggle(autoWin, "Auto Win (tween)", 10)

local autoSpeed = makeSection(leftCol, "Auto Speed", "rbxassetid://6034973618", 1)
addDropdown(autoSpeed, "Treadmill tier", 1)
addSlider(autoSpeed, "Fire interval (s)", 3, 0.10)

local rebirth = makeSection(rightCol, "Rebirth", "rbxassetid://6031091004", 0)
addToggle(rebirth, "Auto Rebirth (when eligible)", 1)
local rebirthBtn = Instance.new("TextButton")
rebirthBtn.Size = UDim2.new(1, 0, 0, 28)
rebirthBtn.BackgroundColor3 = RED
rebirthBtn.Text = "Rebirth Now"
rebirthBtn.TextColor3 = TEXT
rebirthBtn.Font = Enum.Font.GothamBold
rebirthBtn.TextSize = 12
rebirthBtn.LayoutOrder = 2
Instance.new("UICorner", rebirthBtn).CornerRadius = UDim.new(0, 5)
rebirthBtn.Parent = rebirth
rebirthBtn.MouseButton1Click:Connect(function() print("test") end)

local autoFuse = makeSection(rightCol, "Auto Fuse", "rbxassetid://6034958990", 1)
addDropdown(autoFuse, "Items to fuse", 1)
addSlider(autoFuse, "Stop at tier", 3, 5)
addToggle(autoFuse, "Auto Fuse Items", 5)

local safety = makeSection(rightCol, "Safety", "rbxassetid://6034967855", 2)
addToggle(safety, "Remove All Obstacles", 1)
addToggle(safety, "God Mode", 2)

local walkspeed = makeSection(rightCol, "WalkSpeed", "rbxassetid://6034953238", 3)
addSlider(walkspeed, "WalkSpeed", 1, 16)
