--!strict
-- Shop System GUI installer
-- Run this entire script once from Roblox Studio's Command Bar.
-- It creates the complete editable ShopGui hierarchy under StarterGui.
-- Runtime code only updates these prebuilt instances; it does not construct the UI.

local StarterGui = game:GetService("StarterGui")

local existing = StarterGui:FindFirstChild("ShopGui")
if existing then
	existing:Destroy()
end

local function make(className: string, name: string, parent: Instance, properties: {[string]: any}?): Instance
	local object = Instance.new(className)
	object.Name = name
	if properties then
		for property, value in properties do
			(object :: any)[property] = value
		end
	end
	object.Parent = parent
	return object
end

local function corner(parent: Instance, radius: number)
	make("UICorner", "Corner", parent, {CornerRadius = UDim.new(0, radius)})
end

local function border(parent: Instance, color: Color3, transparency: number, thickness: number?)
	make("UIStroke", "Border", parent, {
		Color = color,
		Transparency = transparency,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function pad(parent: Instance, top: number, right: number, bottom: number, left: number)
	make("UIPadding", "Padding", parent, {
		PaddingTop = UDim.new(0, top),
		PaddingRight = UDim.new(0, right),
		PaddingBottom = UDim.new(0, bottom),
		PaddingLeft = UDim.new(0, left),
	})
end

local C = {
	Canvas = Color3.fromRGB(9, 12, 16),
	Window = Color3.fromRGB(16, 20, 26),
	Panel = Color3.fromRGB(20, 25, 32),
	PanelRaised = Color3.fromRGB(25, 31, 39),
	PanelSelected = Color3.fromRGB(30, 38, 46),
	Line = Color3.fromRGB(57, 66, 77),
	Text = Color3.fromRGB(245, 247, 250),
	Muted = Color3.fromRGB(145, 155, 168),
	Soft = Color3.fromRGB(105, 116, 130),
	Accent = Color3.fromRGB(71, 178, 146),
}

local gui = make("ScreenGui", "ShopGui", StarterGui, {
	DisplayOrder = 20,
	Enabled = true,
	IgnoreGuiInset = false,
	ResetOnSpawn = false,
	ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local overlay = make("Frame", "Overlay", gui, {
	BackgroundColor3 = Color3.fromRGB(4, 6, 8),
	BackgroundTransparency = 0.24,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
})

local window = make("Frame", "Window", overlay, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = C.Canvas,
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.88, 0.86),
})
corner(window, 12)
border(window, C.Line, 0.42)
make("UISizeConstraint", "WindowConstraint", window, {
	MinSize = Vector2.new(720, 520),
	MaxSize = Vector2.new(1240, 780),
})

local header = make("Frame", "Header", window, {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(24, 18),
	Size = UDim2.new(1, -48, 0, 58),
})

make("TextLabel", "Title", header, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "MARKET",
	TextColor3 = C.Text,
	TextSize = 25,
	TextXAlignment = Enum.TextXAlignment.Left,
	Size = UDim2.fromOffset(260, 28),
})
make("TextLabel", "Subtitle", header, {
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Gear, supplies, and useful things for the road.",
	TextColor3 = C.Muted,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(1, 31),
	Size = UDim2.fromOffset(360, 20),
})

local wallet = make("Frame", "Wallet", header, {
	AnchorPoint = Vector2.new(1, 0.5),
	BackgroundColor3 = C.Panel,
	BorderSizePixel = 0,
	Position = UDim2.new(1, -48, 0.5, 0),
	Size = UDim2.fromOffset(230, 42),
})
corner(wallet, 8)
border(wallet, C.Line, 0.55)

local function makeCurrency(name: string, x: number, color: Color3)
	local cell = make("Frame", name, wallet, {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(x, 0),
		Size = UDim2.fromOffset(106, 42),
	})
	make("ImageLabel", "Icon", cell, {
		BackgroundTransparency = 1,
		Image = "",
		ImageColor3 = color,
		ScaleType = Enum.ScaleType.Fit,
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.fromOffset(22, 22),
	})
	make("TextLabel", "Amount", cell, {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "0",
		TextColor3 = C.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(38, 0),
		Size = UDim2.fromOffset(66, 42),
	})
end

makeCurrency("Coins", 0, Color3.fromRGB(231, 187, 76))
makeCurrency("Gems", 115, Color3.fromRGB(116, 177, 235))

local close = make("TextButton", "Close", header, {
	AnchorPoint = Vector2.new(1, 0.5),
	AutoButtonColor = false,
	BackgroundColor3 = C.Panel,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Position = UDim2.new(1, 0, 0.5, 0),
	Size = UDim2.fromOffset(36, 36),
	Text = "X",
	TextColor3 = C.Muted,
	TextSize = 12,
})
corner(close, 8)
border(close, C.Line, 0.5)

make("Frame", "HeaderDivider", window, {
	BackgroundColor3 = C.Line,
	BackgroundTransparency = 0.72,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 24, 0, 88),
	Size = UDim2.new(1, -48, 0, 1),
})

local body = make("Frame", "Body", window, {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(24, 104),
	Size = UDim2.new(1, -48, 1, -128),
})

local categories = make("ScrollingFrame", "Categories", body, {
	Active = true,
	AutomaticCanvasSize = Enum.AutomaticSize.X,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	ScrollingDirection = Enum.ScrollingDirection.X,
	ScrollBarThickness = 0,
	Size = UDim2.new(1, 0, 0, 38),
})
make("UIListLayout", "Layout", categories, {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
	VerticalAlignment = Enum.VerticalAlignment.Center,
})

for index, name in {"Featured", "Weapons", "Tools", "Consumables", "Miscellaneous"} do
	local width = name == "Miscellaneous" and 118 or (name == "Consumables" and 108 or 92)
	local button = make("TextButton", name, categories, {
		Active = true,
		AutoButtonColor = false,
		BackgroundColor3 = index == 1 and C.PanelSelected or C.Panel,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		LayoutOrder = index,
		Size = UDim2.fromOffset(width, 34),
		Text = name,
		TextColor3 = index == 1 and C.Text or C.Muted,
		TextSize = 11,
	})
	corner(button, 7)
	border(button, C.Line, index == 1 and 0.3 or 0.7)
end

local toolbar = make("Frame", "Toolbar", body, {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 46),
	Size = UDim2.new(1, 0, 0, 42),
})

local search = make("TextBox", "Search", toolbar, {
	BackgroundColor3 = C.Panel,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	Font = Enum.Font.Gotham,
	PlaceholderColor3 = C.Soft,
	PlaceholderText = "Search the market",
	Text = "",
	TextColor3 = C.Text,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
	Size = UDim2.new(1, -194, 1, 0),
})
corner(search, 7)
border(search, C.Line, 0.52)
pad(search, 0, 12, 0, 14)

make("TextButton", "Clear", search, {
	AnchorPoint = Vector2.new(1, 0.5),
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Position = UDim2.new(1, -9, 0.5, 0),
	Size = UDim2.fromOffset(42, 24),
	Text = "CLEAR",
	TextColor3 = C.Soft,
	TextSize = 8,
	Visible = false,
})

local sort = make("TextButton", "Sort", toolbar, {
	AnchorPoint = Vector2.new(1, 0),
	AutoButtonColor = false,
	BackgroundColor3 = C.Panel,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamMedium,
	Position = UDim2.new(1, 0, 0, 0),
	Size = UDim2.fromOffset(182, 42),
	Text = "SORT  /  FEATURED",
	TextColor3 = C.Text,
	TextSize = 10,
})
corner(sort, 7)
border(sort, C.Line, 0.52)

local content = make("Frame", "Content", body, {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 102),
	Size = UDim2.new(1, 0, 1, -102),
})

local gridContainer = make("Frame", "GridContainer", content, {
	BackgroundTransparency = 1,
	Size = UDim2.new(0.65, -8, 1, 0),
})

local itemGrid = make("ScrollingFrame", "ItemGrid", gridContainer, {
	Active = true,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	ScrollBarImageColor3 = C.Line,
	ScrollBarImageTransparency = 0.25,
	ScrollBarThickness = 4,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	Size = UDim2.fromScale(1, 1),
})
pad(itemGrid, 1, 8, 12, 1)
make("UIGridLayout", "GridLayout", itemGrid, {
	CellPadding = UDim2.fromOffset(9, 9),
	CellSize = UDim2.new(0.5, -5, 0, 190),
	FillDirectionMaxCells = 2,
	SortOrder = Enum.SortOrder.LayoutOrder,
})

local empty = make("Frame", "EmptyState", gridContainer, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(0.5, 0.46),
	Size = UDim2.fromOffset(300, 120),
	Visible = false,
})
make("TextLabel", "Title", empty, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "NO RESULTS",
	TextColor3 = C.Text,
	TextSize = 15,
	Size = UDim2.new(1, 0, 0, 24),
})
make("TextLabel", "Message", empty, {
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Nothing matches the current search or category.",
	TextColor3 = C.Muted,
	TextSize = 11,
	TextWrapped = true,
	Position = UDim2.fromOffset(0, 30),
	Size = UDim2.new(1, 0, 0, 42),
})

local details = make("Frame", "Details", content, {
	AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = C.Panel,
	BorderSizePixel = 0,
	Position = UDim2.new(1, 0, 0, 0),
	Size = UDim2.new(0.35, -1, 1, 0),
})
corner(details, 9)
border(details, C.Line, 0.48)
pad(details, 14, 14, 14, 14)

make("TextButton", "Back", details, {
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Position = UDim2.fromOffset(0, 0),
	Size = UDim2.fromOffset(70, 28),
	Text = "BACK",
	TextColor3 = C.Muted,
	TextSize = 9,
	Visible = false,
})

local media = make("Frame", "Media", details, {
	BackgroundColor3 = C.PanelRaised,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(0, 0),
	Size = UDim2.new(1, 0, 0, 188),
})
corner(media, 8)
border(media, C.Line, 0.62)
make("ImageLabel", "ItemImage", media, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Image = "",
	ScaleType = Enum.ScaleType.Fit,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.72, 0.72),
})
make("Frame", "RarityMark", media, {
	AnchorPoint = Vector2.new(0, 1),
	BackgroundColor3 = C.Accent,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 10, 1, -10),
	Size = UDim2.fromOffset(5, 30),
})

make("TextLabel", "Rarity", details, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "COMMON",
	TextColor3 = C.Muted,
	TextSize = 9,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(0, 198),
	Size = UDim2.new(1, 0, 0, 18),
})
make("TextLabel", "Name", details, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "Iron Sword",
	TextColor3 = C.Text,
	TextSize = 21,
	TextTruncate = Enum.TextTruncate.AtEnd,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(0, 216),
	Size = UDim2.new(1, 0, 0, 28),
})
make("TextLabel", "Description", details, {
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "",
	TextColor3 = C.Muted,
	TextSize = 11,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	Position = UDim2.fromOffset(0, 248),
	Size = UDim2.new(1, 0, 0, 54),
})

local stats = make("Frame", "Stats", details, {
	BackgroundColor3 = C.PanelRaised,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(0, 310),
	Size = UDim2.new(1, 0, 0, 74),
})
corner(stats, 7)
border(stats, C.Line, 0.68)
pad(stats, 8, 10, 8, 10)
make("UIListLayout", "Layout", stats, {
	FillDirection = Enum.FillDirection.Vertical,
	Padding = UDim.new(0, 3),
	SortOrder = Enum.SortOrder.LayoutOrder,
})
for index = 1, 3 do
	make("TextLabel", "Row" .. index, stats, {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		LayoutOrder = index,
		Text = "",
		TextColor3 = C.Text,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 16),
		Visible = false,
	})
end

make("TextLabel", "Ownership", details, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = "Owned 0",
	TextColor3 = C.Muted,
	TextSize = 9,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(0, 394),
	Size = UDim2.new(0.5, 0, 0, 20),
})

local purchase = make("TextButton", "Purchase", details, {
	AnchorPoint = Vector2.new(1, 1),
	AutoButtonColor = false,
	BackgroundColor3 = C.Accent,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Position = UDim2.new(1, 0, 1, 0),
	Size = UDim2.new(1, 0, 0, 44),
	Text = "PURCHASE",
	TextColor3 = Color3.fromRGB(7, 20, 17),
	TextSize = 11,
})
corner(purchase, 7)

make("TextLabel", "PurchaseHint", details, {
	AnchorPoint = Vector2.new(1, 1),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Position = UDim2.new(1, 0, 1, -48),
	Size = UDim2.new(1, 0, 0, 18),
	Text = "",
	TextColor3 = C.Soft,
	TextSize = 8,
	TextXAlignment = Enum.TextXAlignment.Right,
})

-- Prebuilt card pool. The LocalScript only changes properties and visibility.
for index = 1, 24 do
	local card = make("Frame", string.format("Card%02d", index), itemGrid, {
		BackgroundColor3 = C.Panel,
		BorderSizePixel = 0,
		LayoutOrder = index,
		Visible = false,
	})
	corner(card, 8)
	border(card, C.Line, 0.66)

	local mediaCard = make("Frame", "Media", card, {
		BackgroundColor3 = C.PanelRaised,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(7, 7),
		Size = UDim2.new(1, -14, 0, 112),
	})
	corner(mediaCard, 6)
	make("ImageLabel", "ItemImage", mediaCard, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "",
		ScaleType = Enum.ScaleType.Fit,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.74, 0.74),
	})
	make("Frame", "RarityBar", mediaCard, {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = C.Muted,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 8, 1, -8),
		Size = UDim2.fromOffset(4, 24),
	})
	make("TextLabel", "Name", card, {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "",
		TextColor3 = C.Text,
		TextSize = 11,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(8, 124),
		Size = UDim2.new(1, -16, 0, 18),
	})
	make("TextLabel", "Rarity", card, {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = C.Muted,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(8, 144),
		Size = UDim2.new(0.52, -8, 0, 14),
	})
	make("ImageLabel", "CurrencyIcon", card, {
		BackgroundTransparency = 1,
		Image = "",
		ScaleType = Enum.ScaleType.Fit,
		Position = UDim2.new(1, -65, 0, 145),
		Size = UDim2.fromOffset(12, 12),
	})
	make("TextLabel", "Price", card, {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "",
		TextColor3 = C.Text,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Right,
		Position = UDim2.new(1, -48, 0, 143),
		Size = UDim2.fromOffset(40, 16),
	})
	make("TextLabel", "Owned", card, {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = C.Soft,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(8, 160),
		Size = UDim2.new(0.55, -8, 0, 14),
	})
	make("TextButton", "Select", card, {
		Active = true,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		ZIndex = 5,
	})
end

local modal = make("Frame", "ConfirmModal", overlay, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = C.Panel,
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(420, 300),
	Visible = false,
	ZIndex = 30,
})
corner(modal, 10)
border(modal, C.Line, 0.38)
pad(modal, 20, 20, 20, 20)
make("TextLabel", "Title", modal, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "CONFIRM PURCHASE",
	TextColor3 = C.Text,
	TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Left,
	Size = UDim2.new(1, 0, 0, 24),
	ZIndex = 31,
})
make("TextLabel", "Message", modal, {
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "",
	TextColor3 = C.Muted,
	TextSize = 11,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(0, 34),
	Size = UDim2.new(1, 0, 0, 42),
	ZIndex = 31,
})
make("ImageLabel", "ItemImage", modal, {
	BackgroundColor3 = C.PanelRaised,
	BorderSizePixel = 0,
	Image = "",
	ScaleType = Enum.ScaleType.Fit,
	Position = UDim2.fromOffset(0, 92),
	Size = UDim2.fromOffset(92, 92),
	ZIndex = 31,
})
corner(modal.ItemImage, 7)
make("TextLabel", "ItemName", modal, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "",
	TextColor3 = C.Text,
	TextSize = 14,
	TextTruncate = Enum.TextTruncate.AtEnd,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(108, 98),
	Size = UDim2.new(1, -108, 0, 22),
	ZIndex = 31,
})
make("TextLabel", "Price", modal, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "",
	TextColor3 = C.Accent,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(108, 127),
	Size = UDim2.new(1, -108, 0, 20),
	ZIndex = 31,
})
local cancel = make("TextButton", "Cancel", modal, {
	AutoButtonColor = false,
	BackgroundColor3 = C.PanelRaised,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Position = UDim2.new(0, 0, 1, -48),
	Size = UDim2.new(0.48, -4, 0, 42),
	Text = "CANCEL",
	TextColor3 = C.Muted,
	TextSize = 10,
	ZIndex = 31,
})
corner(cancel, 7)
border(cancel, C.Line, 0.58)
local confirm = make("TextButton", "Confirm", modal, {
	AutoButtonColor = false,
	BackgroundColor3 = C.Accent,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Position = UDim2.new(0.52, 4, 1, -48),
	Size = UDim2.new(0.48, -4, 0, 42),
	Text = "CONFIRM",
	TextColor3 = Color3.fromRGB(7, 20, 17),
	TextSize = 10,
	ZIndex = 31,
})
corner(confirm, 7)

local toastContainer = make("Frame", "ToastContainer", gui, {
	AnchorPoint = Vector2.new(1, 1),
	BackgroundTransparency = 1,
	Position = UDim2.new(1, -24, 1, -24),
	Size = UDim2.fromOffset(320, 250),
	ZIndex = 50,
})
make("UIListLayout", "Layout", toastContainer, {
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	Padding = UDim.new(0, 7),
	SortOrder = Enum.SortOrder.LayoutOrder,
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
})

for index = 1, 4 do
	local toast = make("Frame", string.format("Toast%02d", index), toastContainer, {
		BackgroundColor3 = C.Panel,
		BorderSizePixel = 0,
		LayoutOrder = index,
		Size = UDim2.fromOffset(310, 54),
		Visible = false,
		ZIndex = 51,
	})
	corner(toast, 7)
	border(toast, C.Line, 0.5)
	make("Frame", "Accent", toast, {
		BackgroundColor3 = C.Accent,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(3, 54),
		ZIndex = 52,
	})
	make("TextLabel", "Title", toast, {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "",
		TextColor3 = C.Text,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(14, 7),
		Size = UDim2.new(1, -24, 0, 15),
		ZIndex = 52,
	})
	make("TextLabel", "Message", toast, {
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = C.Muted,
		TextSize = 9,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(14, 23),
		Size = UDim2.new(1, -24, 0, 22),
		ZIndex = 52,
	})
end

print("ShopGui installed. Runtime code will only update the prebuilt hierarchy.")
