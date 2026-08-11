--!strict
-- Command Bar installer for the Shop System GUI.
-- Run this script in Roblox Studio's Command Bar. It creates real, editable
-- Instances under StarterGui; no LocalScript builds the interface at runtime.

local StarterGui = game:GetService("StarterGui")

local existing = StarterGui:FindFirstChild("ShopGui")
if existing then
	existing:Destroy()
end

local function instance(className: string, name: string, parent: Instance, properties: {[string]: any}?): Instance
	local object = Instance.new(className)
	object.Name = name
	object.Parent = parent
	if properties then
		for property, value in properties do
			(object :: any)[property] = value
		end
	end
	return object
end

local function corner(parent: Instance, radius: number)
	instance("UICorner", "Corner", parent, {CornerRadius = UDim.new(0, radius)})
end

local function stroke(parent: Instance, color: Color3, transparency: number, thickness: number)
	instance("UIStroke", "Stroke", parent, {
		Color = color,
		Transparency = transparency,
		Thickness = thickness,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function padding(parent: Instance, top: number, right: number, bottom: number, left: number)
	instance("UIPadding", "Padding", parent, {
		PaddingTop = UDim.new(0, top),
		PaddingRight = UDim.new(0, right),
		PaddingBottom = UDim.new(0, bottom),
		PaddingLeft = UDim.new(0, left),
	})
end

local colors = {
	background = Color3.fromRGB(12, 15, 20),
	panel = Color3.fromRGB(20, 24, 31),
	panelRaised = Color3.fromRGB(25, 30, 38),
	panelSoft = Color3.fromRGB(30, 35, 44),
	line = Color3.fromRGB(55, 62, 73),
	text = Color3.fromRGB(244, 246, 249),
	muted = Color3.fromRGB(155, 163, 175),	
	accent = Color3.fromRGB(77, 181, 150),
	accentDark = Color3.fromRGB(42, 120, 97),
	danger = Color3.fromRGB(226, 104, 104),
}

local gui = instance("ScreenGui", "ShopGui", StarterGui, {
	DisplayOrder = 20,
	IgnoreGuiInset = false,
	ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Enabled = true,
})

local overlay = instance("Frame", "Overlay", gui, {
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.42,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
})

local window = instance("Frame", "Window", overlay, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = colors.background,
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.88, 0.84),
})
corner(window, 14)
stroke(window, colors.line, 0.28, 1)
instance("UISizeConstraint", "WindowSize", window, {
	MinSize = Vector2.new(310, 430),
	MaxSize = Vector2.new(1180, 760),
})

local header = instance("Frame", "Header", window, {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 76),
})
padding(header, 16, 18, 10, 22)

instance("TextLabel", "Title", header, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "MARKET",
	TextColor3 = colors.text,
	TextSize = 26,
	TextXAlignment = Enum.TextXAlignment.Left,
	Size = UDim2.new(0, 230, 0, 30),
	Position = UDim2.fromOffset(0, 4),
})
instance("TextLabel", "Subtitle", header, {
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Gear, supplies, and useful things for the road.",
	TextColor3 = colors.muted,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	Size = UDim2.new(0, 330, 0, 22),
	Position = UDim2.fromOffset(0, 35),
})

local currency = instance("Frame", "CurrencyBar", header, {
	AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = colors.panelRaised,
	BorderSizePixel = 0,
	Position = UDim2.new(1, -48, 0, 8),
	Size = UDim2.new(0, 196, 0, 42),
})
corner(currency, 9)
stroke(currency, colors.line, 0.55, 1)

instance("TextLabel", "Coins", currency, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "◈  2,500",
	TextColor3 = colors.text,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Center,
	Size = UDim2.fromScale(0.5, 1),
})
instance("TextLabel", "Gems", currency, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "◇  120",
	TextColor3 = Color3.fromRGB(178, 205, 255),
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Center,
	Position = UDim2.fromScale(0.5, 0),
	Size = UDim2.fromScale(0.5, 1),
})

local close = instance("TextButton", "Close", header, {
	AnchorPoint = Vector2.new(1, 0.5),
	AutoButtonColor = false,
	BackgroundColor3 = colors.panelRaised,
	BorderSizePixel = 0,
	Position = UDim2.new(1, -4, 0, 29),
	Size = UDim2.fromOffset(34, 34),
	Font = Enum.Font.GothamMedium,
	Text = "×",
	TextColor3 = colors.muted,
	TextSize = 22,
})
corner(close, 8)
stroke(close, colors.line, 0.55, 1)

local body = instance("Frame", "Body", window, {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 76),
	Size = UDim2.new(1, 0, 1, -76),
})

local categories = instance("ScrollingFrame", "Categories", body, {
	Active = true,
	AutomaticCanvasSize = Enum.AutomaticSize.X,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	ScrollingDirection = Enum.ScrollingDirection.X,
	ScrollBarThickness = 0,
	Position = UDim2.fromOffset(20, 0),
	Size = UDim2.new(1, -40, 0, 42),
})
padding(categories, 0, 0, 0, 0)
local categoryLayout = instance("UIListLayout", "Layout", categories, {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 7),
	SortOrder = Enum.SortOrder.LayoutOrder,
	VerticalAlignment = Enum.VerticalAlignment.Center,
})

for index, name in {"Featured", "Weapons", "Tools", "Consumables", "Miscellaneous"} do
	local button = instance("TextButton", name, categories, {
		Active = true,
		AutoButtonColor = false,
		BackgroundColor3 = index == 1 and colors.panelSoft or colors.panel,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		LayoutOrder = index,
		Size = UDim2.fromOffset(index == 5 and 116 or 92, 34),
		Text = name,
		TextColor3 = index == 1 and colors.text or colors.muted,
		TextSize = 12,
	})
	corner(button, 8)
	stroke(button, colors.line, index == 1 and 0.35 or 0.72, 1)
end

local toolbar = instance("Frame", "Toolbar", body, {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(20, 50),
	Size = UDim2.new(1, -40, 0, 46),
})

local search = instance("TextBox", "Search", toolbar, {
	BackgroundColor3 = colors.panel,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	Font = Enum.Font.Gotham,
	PlaceholderColor3 = colors.muted,
	PlaceholderText = "Search items...",
	Text = "",
	TextColor3 = colors.text,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	Size = UDim2.new(1, -170, 1, 0),
})
corner(search, 8)
stroke(search, colors.line, 0.55, 1)
padding(search, 0, 14, 0, 38)
instance("TextLabel", "Icon", search, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = "⌕",
	TextColor3 = colors.muted,
	TextSize = 19,
	Position = UDim2.fromOffset(12, 0),
	Size = UDim2.fromOffset(20, 46),
})

local sort = instance("TextButton", "Sort", toolbar, {
	AnchorPoint = Vector2.new(1, 0),
	AutoButtonColor = false,
	BackgroundColor3 = colors.panel,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamMedium,
	Position = UDim2.new(1, 0, 0, 0),
	Size = UDim2.fromOffset(154, 46),
	Text = "Sort: Featured  ▾",
	TextColor3 = colors.text,
	TextSize = 12,
})
corner(sort, 8)
stroke(sort, colors.line, 0.55, 1)

local content = instance("Frame", "Content", body, {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(20, 104),
	Size = UDim2.new(1, -40, 1, -124),
})

local gridContainer = instance("Frame", "GridContainer", content, {
	BackgroundTransparency = 1,
	Size = UDim2.new(0.63, -8, 1, 0),
})

local grid = instance("ScrollingFrame", "ItemGrid", gridContainer, {
	Active = true,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	ScrollBarImageColor3 = colors.line,
	ScrollBarThickness = 4,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	Size = UDim2.fromScale(1, 1),
})
padding(grid, 2, 8, 10, 2)
instance("UIGridLayout", "GridLayout", grid, {
	CellPadding = UDim2.fromOffset(10, 10),
	CellSize = UDim2.new(0.333, -7, 0, 178),
	FillDirectionMaxCells = 3,
	SortOrder = Enum.SortOrder.LayoutOrder,
})

local empty = instance("Frame", "EmptyState", gridContainer, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(250, 120),
	Visible = false,
})
instance("TextLabel", "Title", empty, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "Nothing here",
	TextColor3 = colors.text,
	TextSize = 16,
	Size = UDim2.new(1, 0, 0, 28),
})
instance("TextLabel", "Message", empty, {
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Try a different search or category.",
	TextColor3 = colors.muted,
	TextSize = 12,
	TextWrapped = true,
	Position = UDim2.fromOffset(0, 34),
	Size = UDim2.new(1, 0, 0, 42),
})

local details = instance("Frame", "Details", content, {
	AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = colors.panel,
	BorderSizePixel = 0,
	Position = UDim2.new(1, 0, 0, 0),
	Size = UDim2.new(0.37, -2, 1, 0),
})
corner(details, 11)
stroke(details, colors.line, 0.48, 1)
padding(details, 16, 16, 16, 16)

local detailIcon = instance("Frame", "IconFrame", details, {
	BackgroundColor3 = colors.panelRaised,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, 190),
})
corner(detailIcon, 10)
stroke(detailIcon, colors.line, 0.55, 1)
instance("ImageLabel", "Icon", detailIcon, {
	BackgroundTransparency = 1,
	Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
	ImageTransparency = 0.35,
	ScaleType = Enum.ScaleType.Fit,
	Size = UDim2.fromScale(0.58, 0.58),
	Position = UDim2.fromScale(0.21, 0.18),
})
instance("TextLabel", "Glyph", detailIcon, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "◆",
	TextColor3 = colors.accent,
	TextSize = 48,
	Size = UDim2.fromScale(1, 1),
})

instance("TextLabel", "Rarity", details, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "COMMON",
	TextColor3 = colors.accent,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(0, 202),
	Size = UDim2.new(1, 0, 0, 18),
})
instance("TextLabel", "Name", details, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "Iron Sword",
	TextColor3 = colors.text,
	TextSize = 20,
	TextTruncate = Enum.TextTruncate.AtEnd,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(0, 220),
	Size = UDim2.new(1, 0, 0, 28),
})
instance("TextLabel", "Description", details, {
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "A dependable blade for new adventurers.",
	TextColor3 = colors.muted,
	TextSize = 12,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	Position = UDim2.fromOffset(0, 252),
	Size = UDim2.new(1, 0, 0, 54),
})

local stats = instance("Frame", "Stats", details, {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 312),
	Size = UDim2.new(1, 0, 0, 72),
})
instance("TextLabel", "Damage", stats, {
	BackgroundColor3 = colors.panelRaised,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamMedium,
	Text = "DAMAGE   15",
	TextColor3 = colors.text,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(0, 0),
	Size = UDim2.new(1, 0, 0, 30),
})
corner(stats:FindFirstChild("Damage") :: Instance, 7)
padding(stats:FindFirstChild("Damage") :: Instance, 0, 10, 0, 10)
instance("TextLabel", "Owned", stats, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = "Owned  •  0",
	TextColor3 = colors.muted,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(0, 38),
	Size = UDim2.new(1, 0, 0, 24),
})

local purchase = instance("TextButton", "Purchase", details, {
	AutoButtonColor = false,
	BackgroundColor3 = colors.accent,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Position = UDim2.new(0, 0, 1, -50),
	Size = UDim2.new(1, 0, 0, 46),
	Text = "Purchase   •   ◈ 250",
	TextColor3 = Color3.fromRGB(9, 30, 24),
	TextSize = 13,
})
corner(purchase, 8)

local modal = instance("Frame", "ConfirmModal", overlay, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = colors.panel,
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(360, 210),
	Visible = false,
	ZIndex = 50,
})
corner(modal, 12)
stroke(modal, colors.line, 0.35, 1)
padding(modal, 20, 20, 20, 20)
instance("TextLabel", "Title", modal, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "Confirm purchase",
	TextColor3 = colors.text,
	TextSize = 19,
	TextXAlignment = Enum.TextXAlignment.Left,
	Size = UDim2.new(1, 0, 0, 28),
	ZIndex = 51,
})
instance("TextLabel", "Message", modal, {
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Purchase Emberblade for ◈ 850?",
	TextColor3 = colors.muted,
	TextSize = 12,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(0, 38),
	Size = UDim2.new(1, 0, 0, 48),
	ZIndex = 51,
})
local cancel = instance("TextButton", "Cancel", modal, {
	AutoButtonColor = false,
	BackgroundColor3 = colors.panelRaised,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamMedium,
	Position = UDim2.new(0, 0, 1, -52),
	Size = UDim2.new(0.48, -4, 0, 40),
	Text = "Cancel",
	TextColor3 = colors.text,
	TextSize = 12,
	ZIndex = 51,
})
corner(cancel, 8)
local confirm = instance("TextButton", "Confirm", modal, {
	AutoButtonColor = false,
	BackgroundColor3 = colors.accent,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Position = UDim2.new(0.52, 4, 1, -52),
	Size = UDim2.new(0.48, -4, 0, 40),
	Text = "Confirm",
	TextColor3 = Color3.fromRGB(9, 30, 24),
	TextSize = 12,
	ZIndex = 51,
})
corner(confirm, 8)

local toastContainer = instance("Frame", "ToastContainer", gui, {
	AnchorPoint = Vector2.new(1, 0),
	BackgroundTransparency = 1,
	Position = UDim2.new(1, -20, 0, 74),
	Size = UDim2.fromOffset(320, 260),
	ZIndex = 100,
})
instance("UIListLayout", "Layout", toastContainer, {
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
	VerticalAlignment = Enum.VerticalAlignment.Top,
})

print("ShopGui installed to StarterGui. The GUI is now a normal, editable Studio hierarchy.")
