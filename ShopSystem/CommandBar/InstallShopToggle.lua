--!strict
-- Shop toggle installer
-- Run this after CreateShopGUI.lua in Roblox Studio's Command Bar.
-- The button is a normal editable StarterGui instance; runtime code only listens to it.

local StarterGui = game:GetService("StarterGui")
local gui = StarterGui:FindFirstChild("ShopGui")
if not gui or not gui:IsA("ScreenGui") then
	error("ShopGui was not found. Run CreateShopGUI.lua first.")
end

local existing = gui:FindFirstChild("ShopToggle")
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

local button = make("TextButton", "ShopToggle", gui, {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 24, 1, -24),
	Size = UDim2.fromOffset(116, 44),
	BackgroundColor3 = Color3.fromRGB(18, 23, 30),
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Font = Enum.Font.GothamSemibold,
	Text = "SHOP",
	TextColor3 = Color3.fromRGB(239, 243, 247),
	TextSize = 12,
	ZIndex = 100,
})

make("UICorner", "Corner", button, {CornerRadius = UDim.new(0, 10)})
make("UIStroke", "Border", button, {
	Color = Color3.fromRGB(62, 73, 85),
	Transparency = 0.25,
	Thickness = 1,
})

make("ImageLabel", "Icon", button, {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(13, 10),
	Size = UDim2.fromOffset(24, 24),
	Image = "rbxassetid://6031071053",
	ImageColor3 = Color3.fromRGB(221, 228, 234),
	ScaleType = Enum.ScaleType.Fit,
	ZIndex = 101,
})

make("TextLabel", "Label", button, {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(45, 0),
	Size = UDim2.new(1, -53, 1, 0),
	Font = Enum.Font.GothamSemibold,
	Text = "SHOP",
	TextColor3 = Color3.fromRGB(239, 243, 247),
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 101,
})

print("ShopToggle installed. It is now a normal StarterGui instance and is controlled by ShopToggle.client.lua.")
