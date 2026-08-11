--!strict
-- Shop System GUI installer
-- Run this entire script once from Roblox Studio's Command Bar.
-- It creates the complete, editable ShopGui hierarchy under StarterGui.
-- Runtime code only updates these prebuilt instances; it never constructs UI.

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
	Background = Color3.fromRGB(8, 11, 15),
	Surface = Color3.fromRGB(15, 19, 25),
	Surface2 = Color3.fromRGB(19, 24, 31),
	Surface3 = Color3.fromRGB(23, 29, 37),
	Selected = Color3.fromRGB(28, 37, 45),
	Line = Color3.fromRGB(49, 59, 70),
	Text = Color3.fromRGB(244, 246, 249),
	Muted = Color3.fromRGB(151, 160, 172),
	Soft = Color3.fromRGB(101, 113, 128),
	Accent = Color3.fromRGB(68, 180, 148),
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
	BackgroundColor3 = Color3.fromRGB(3, 5, 7),
	BackgroundTransparency = 0.28,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
})

local window = make("Frame", "Window", overlay, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = C.Background,
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.91, 0.86),
})
corner(window, 14)
border(window, C.Line, 0.28)
make("UISizeConstraint", "WindowConstraint", window, {
	MinSize = Vector2.new(760, 540),
	MaxSize = Vector2.new(1320, 820),
})

local header = make("Frame", "Header", window, {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(28, 22),
	Size = UDim2.new(1, -56, 0, 66),
})

make("TextLabel", "Eyebrow", header, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = "ADVENTURER'S SUPPLY",
	TextColor3 = C.Accent,
	TextSize = 8,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(1, 0),
	Size = UDim2.fromOffset(220, 16),
})
make("TextLabel", "Title", header, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "MARKET",
	TextColor3 = C.Text,
	TextSize = 26,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(0, 13),
	Size = UDim2.fromOffset(280, 31),
})
make("TextLabel", "Subtitle", header, {
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Gear, supplies, and useful things for the road.",
	TextColor3 = C.Muted,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(1, 43),
	Size = UDim2.fromOffset(380, 19),
})

local wallet = make("Frame", "Wallet", header, {
	AnchorPoint = Vector2.new(1, 0.5),
	BackgroundColor3 = C.Surface,
	BorderSizePixel = 0,
	Position = UDim2.new(1, -52, 0.5, 0),
	Size = UDim2.fromOffset(244, 46),
})
corner(wallet, 9)
border(wallet, C.Line, 0.45)

local function makeCurrency(name: string, x: number, color: Color3)
	local cell = make("Frame", name, wallet, {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(x, 0),
		Size = UDim2.fromOffset(114, 46),
	})
	make("ImageLabel", "Icon", cell, {
		BackgroundTransparency = 1,
		Image = "",
		ImageColor3 = color,
		ScaleType = Enum.ScaleType.Fit,
		Position = UDim2.fromOffset(10, 11),
		Size = UDim2.fromOffset(24, 24),
	})
	make("TextLabel", "Amount", cell, {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "0",
		TextColor3 = C.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(42, 0),
		Size = UDim2.fromOffset(70, 46),
	})
end

makeCurrency("Coins", 0, Color3.fromRGB(229, 183, 71))
makeCurrency("Gems", 120, Color3.fromRGB(116, 177, 235))

local close = make("TextButton", "Close", header, {
	AnchorPoint = Vector2.new(1, 0.5),
	AutoButtonColor = false,
	BackgroundColor3 = C.Surface,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamMedium,
	Position = UDim2.new(1, 0, 0.5, 0),
	Size = UDim2.fromOffset(38, 38),
	Text = "X",
	TextColor3 = C.Muted,
	TextSize = 11,
})
corner(close, 9)
border(close, C.Line, 0.5)

make("Frame", "HeaderDivider", window, {
	BackgroundColor3 = C.Line,
	BackgroundTransparency = 0.72,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 28, 0, 94),
	Size = UDim2.new(1, -56, 0, 1),
})

local body = make("Frame", "Body", window, {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(28, 110),
	Size = UDim2.new(1, -56, 1, -138),
})

local categories = make("ScrollingFrame", "Categories", body, {
	Active = true,
	AutomaticCanvasSize = Enum.AutomaticSize.X,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	ScrollingDirection = Enum.ScrollingDirection.X,
	ScrollBarThickness = 0,
	Size = UDim2.new(1, 0, 0, 34),
})
make("UIListLayout", "Layout", categories, {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder,
	VerticalAlignment = Enum.VerticalAlignment.Center,
})

for index, name in {"Featured", "Weapons", "Tools", "Consumables", "Miscellaneous"} do
	local width = name == "Miscellaneous" and 118 or (name == "Consumables" and 108 or 92)
	local button = make("TextButton", name, categories, {
		Active = true,
		AutoButtonColor = false,
		BackgroundColor3 = index == 1 and C.Selected or C.Surface,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		LayoutOrder = index,
		Size = UDim2.fromOffset(width, 32),
		Text = name,
		TextColor3 = index == 1 and C.Text or C.Muted,
		TextSize = 10,
	})
	corner(button, 7)
	border(button, index == 1 and C.Accent or C.Line, index == 1 and 0.25 or 0.72)
end

local toolbar = make("Frame", "Toolbar", body, {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 43),
	Size = UDim2.new(1, 0, 0, 42),
})

local search = make("TextBox", "Search", toolbar, {
	BackgroundColor3 = C.Surface,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	Font = Enum.Font.Gotham,
	PlaceholderColor3 = C.Soft,
	PlaceholderText = "Search items by name",
	Text = "",
	TextColor3 = C.Text,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left,
	Size = UDim2.new(1, -194, 1, 0),
})
corner(search, 8)
border(search, C.Line, 0.48)
pad(search, 0, 12, 0, 14)

make("TextButton", "Clear", search, {
	AnchorPoint = Vector2.new(1, 0.5),
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Position = UDim2.new(1, -8, 0.5, 0),
	Size = UDim2.fromOffset(42, 24),
	Text = "CLEAR",
	TextColor3 = C.Soft,
	TextSize = 8,
	Visible = false,
})

local sort = make("TextButton", "Sort", toolbar, {
	AnchorPoint = Vector2.new(1, 0),
	AutoButtonColor = false,
	BackgroundColor3 = C.Surface,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamMedium,
	Position = UDim2.new(1, 0, 0, 0),
	Size = UDim2.fromOffset(184, 42),
	Text = "SORT  /  FEATURED",
	TextColor3 = C.Text,
	TextSize = 9,
})
corner(sort, 8)
border(sort, C.Line, 0.48)

local content = make("Frame", "Content", body, {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 96),
	Size = UDim2.new(1, 0, 1, -96),
})

local gridContainer = make("Frame", "GridContainer", content, {
	BackgroundTransparency = 1,
	Size = UDim2.new(0.68, -8, 1, 0),
})

local itemGrid = make("ScrollingFrame", "ItemGrid", gridContainer, {
	Active = true,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	ScrollBarImageColor3 = C.Line,
	ScrollBarImageTransparency = 0.2,
	ScrollBarThickness = 4,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	Size = UDim2.fromScale(1, 1),
})
pad(itemGrid, 1, 7, 12, 1)
make("UIGridLayout", "GridLayout", itemGrid, {
	CellPadding = UDim2.fromOffset(9, 9),
	CellSize = UDim2.new(0.333, -6, 0, 176),
	FillDirectionMaxCells = 3,
	SortOrder = Enum.SortOrder.LayoutOrder,
})

local empty = make("Frame", "EmptyState", gridContainer, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(0.5, 0.45),
	Size = UDim2.fromOffset(320, 110),
	Visible = false,
})
make("Frame", "Rule", empty, {
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundColor3 = C.Line,
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0.5, 0),
	Size = UDim2.fromOffset(36, 1),
})
make("TextLabel", "Title", empty, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "NO RESULTS",
	TextColor3 = C.Text,
	TextSize = 14,
	Position = UDim2.fromOffset(0, 15),
	Size = UDim2.new(1, 0, 0, 22),
})
make("TextLabel", "Message", empty, {
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Try another search or choose a different category.",
	TextColor3 = C.Muted,
	TextSize = 10,
	TextWrapped = true,
	Position = UDim2.fromOffset(0, 43),
	Size = UDim2.new(1, 0, 0, 38),
})

local details = make("Frame", "Details", content, {
	AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = C.Surface,
	BorderSizePixel = 0,
	Position = UDim2.new(1, 0, 0, 0),
	Size = UDim2.new(0.32, -1, 1, 0),
})
corner(details, 10)
border(details, C.Line, 0.42)
pad(details, 14, 14, 14, 14)

make("TextButton", "Back", details, {
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Position = UDim2.fromOffset(0, 0),
	Size = UDim2.fromOffset(70, 26),
	Text = "BACK",
	TextColor3 = C.Muted,
	TextSize = 8,
	Visible = false,
})

local media = make("Frame", "Media", details, {
	BackgroundColor3 = C.Surface3,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(0, 0),
	Size = UDim2.new(1, 0, 0, 154),
})
corner(media, 8)
border(media, C.Line, 0.58)
make("ImageLabel", "ItemImage", media, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Image = "",
	ScaleType = Enum.ScaleType.Fit,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.64, 0.78),
})
make("Frame", "RarityMark", media, {
	AnchorPoint = Vector2.new(0, 1),
	BackgroundColor3 = C.Accent,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 10, 1, -10),
	Size = UDim2.fromOffset(4, 26),
})

make("TextLabel", "Rarity", details, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = "COMMON",
	TextColor3 = C.Muted,
	TextSize = 8,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(0, 164),
	Size = UDim2.new(1, 0, 0, 16),
})
make("TextLabel", "ItemName", details, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "Iron Sword",
	TextColor3 = C.Text,
	TextSize = 20,
	TextTruncate = Enum.TextTruncate.AtEnd,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(0, 181),
	Size = UDim2.new(1, 0, 0, 27),
})
make("TextLabel", "Description", details, {
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "",
	TextColor3 = C.Muted,
	TextSize = 10,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	Position = UDim2.fromOffset(0, 211),
	Size = UDim2.new(1, 0, 0, 54),
})

local stats = make("Frame", "Stats", details, {
	BackgroundColor3 = C.Surface2,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(0, 272),
	Size = UDim2.new(1, 0, 0, 70),
})
corner(stats, 7)
border(stats, C.Line, 0.62)
pad(stats, 7, 10, 7, 10)
make("UIListLayout", "Layout", stats, {
	FillDirection = Enum.FillDirection.Vertical,
	Padding = UDim.new(0, 2),
	SortOrder = Enum.SortOrder.LayoutOrder,
})
for index = 1, 3 do
	make("TextLabel", "Row" .. index, stats, {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		LayoutOrder = index,
		Text = "",
		TextColor3 = C.Text,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 16),
		Visible = false,
	})
end

make("TextLabel", "Ownership", details, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = "Not owned",
	TextColor3 = C.Muted,
	TextSize = 8,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(0, 350),
	Size = UDim2.new(0.6, 0, 0, 18),
})
make("TextLabel", "PurchaseHint", details, {
	AnchorPoint = Vector2.new(1, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Position = UDim2.new(1, 0, 0, 350),
	Size = UDim2.new(0.65, 0, 0, 18),
	Text = "",
	TextColor3 = C.Soft,
	TextSize = 7,
	TextXAlignment = Enum.TextXAlignment.Right,
})

local purchase = make("TextButton", "Purchase", details, {
	AnchorPoint = Vector2.new(1, 1),
	AutoButtonColor = false,
	BackgroundColor3 = C.Accent,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Position = UDim2.new(1, 0, 1, 0),
	Size = UDim2.new(1, 0, 0, 46),
	Text = "PURCHASE",
	TextColor3 = Color3.fromRGB(6, 20, 16),
	TextSize = 10,
})
corner(purchase, 8)

for index = 1, 24 do
	local card = make("Frame", string.format("Card%02d", index), itemGrid, {
		BackgroundColor3 = C.Surface,
		BorderSizePixel = 0,
		LayoutOrder = index,
		Visible = false,
	})
	corner(card, 9)
	border(card, C.Line, 0.64)

	local mediaCard = make("Frame", "Media", card, {
		BackgroundColor3 = C.Surface2,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.new(1, -12, 0, 102),
	})
	corner(mediaCard, 7)
	make("ImageLabel", "ItemImage", mediaCard, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "",
		ScaleType = Enum.ScaleType.Fit,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.72, 0.78),
	})
	make("Frame", "RarityBar", mediaCard, {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = C.Muted,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 8, 1, -8),
		Size = UDim2.fromOffset(3, 22),
	})

	make("TextLabel", "ItemName", card, {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "",
		TextColor3 = C.Text,
		TextSize = 10,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(8, 113),
		Size = UDim2.new(1, -16, 0, 18),
	})
	make("TextLabel", "Rarity", card, {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = C.Muted,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(8, 132),
		Size = UDim2.new(0.48, -8, 0, 13),
	})
	make("ImageLabel", "CurrencyIcon", card, {
		BackgroundTransparency = 1,
		Image = "",
		ScaleType = Enum.ScaleType.Fit,
		Position = UDim2.new(1, -58, 0, 132),
		Size = UDim2.fromOffset(12, 12),
	})
	make("TextLabel", "Price", card, {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "",
		TextColor3 = C.Text,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Right,
		Position = UDim2.new(1, -43, 0, 130),
		Size = UDim2.fromOffset(36, 16),
	})
	make("TextLabel", "Owned", card, {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = C.Soft,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(8, 148),
		Size = UDim2.new(0.55, -8, 0, 13),
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
	BackgroundColor3 = C.Surface,
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(430, 292),
	Visible = false,
	ZIndex = 30,
})
corner(modal, 11)
border(modal, C.Line, 0.25)
pad(modal, 20, 20, 20, 20)
make("TextLabel", "Title", modal, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "CONFIRM PURCHASE",
	TextColor3 = C.Text,
	TextSize = 15,
	TextXAlignment = Enum.TextXAlignment.Left,
	Size = UDim2.new(1, 0, 0, 22),
	ZIndex = 31,
})
make("TextLabel", "Message", modal, {
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "",
	TextColor3 = C.Muted,
	TextSize = 10,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(0, 32),
	Size = UDim2.new(1, 0, 0, 42),
	ZIndex = 31,
})
make("ImageLabel", "ItemImage", modal, {
	BackgroundColor3 = C.Surface2,
	BorderSizePixel = 0,
	Image = "",
	ScaleType = Enum.ScaleType.Fit,
	Position = UDim2.fromOffset(0, 92),
	Size = UDim2.fromOffset(86, 86),
	ZIndex = 31,
})
corner(modal.ItemImage, 8)
make("TextLabel", "ItemName", modal, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "",
	TextColor3 = C.Text,
	TextSize = 14,
	TextTruncate = Enum.TextTruncate.AtEnd,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(104, 98),
	Size = UDim2.new(1, -104, 0, 22),
	ZIndex = 31,
})
make("TextLabel", "Price", modal, {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "",
	TextColor3 = C.Accent,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromOffset(104, 126),
	Size = UDim2.new(1, -104, 0, 18),
	ZIndex = 31,
})
local cancel = make("TextButton", "Cancel", modal, {
	AutoButtonColor = false,
	BackgroundColor3 = C.Surface2,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Position = UDim2.new(0, 0, 1, -48),
	Size = UDim2.new(0.48, -4, 0, 42),
	Text = "CANCEL",
	TextColor3 = C.Muted,
	TextSize = 9,
	ZIndex = 31,
})
corner(cancel, 8)
border(cancel, C.Line, 0.5)
local confirm = make("TextButton", "Confirm", modal, {
	AutoButtonColor = false,
	BackgroundColor3 = C.Accent,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Position = UDim2.new(0.52, 4, 1, -48),
	Size = UDim2.new(0.48, -4, 0, 42),
	Text = "CONFIRM",
	TextColor3 = Color3.fromRGB(6, 20, 16),
	TextSize = 9,
	ZIndex = 31,
})
corner(confirm, 8)

local toastContainer = make("Frame", "ToastContainer", gui, {
	AnchorPoint = Vector2.new(1, 1),
	BackgroundTransparency = 1,
	Position = UDim2.new(1, -24, 1, -24),
	Size = UDim2.fromOffset(330, 250),
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
		BackgroundColor3 = C.Surface,
		BorderSizePixel = 0,
		LayoutOrder = index,
		Size = UDim2.fromOffset(320, 56),
		Visible = false,
		ZIndex = 51,
	})
	corner(toast, 8)
	border(toast, C.Line, 0.46)
	make("Frame", "Accent", toast, {
		BackgroundColor3 = C.Accent,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(3, 56),
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
		Position = UDim2.fromOffset(14, 24),
		Size = UDim2.new(1, -24, 0, 20),
		ZIndex = 52,
	})
end

print("ShopGui installed. Runtime code only updates the prebuilt hierarchy.")
