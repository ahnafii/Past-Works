--!strict

local ShopConfig = {}

ShopConfig.Version = 2
ShopConfig.DataStoreName = "PortfolioShop_v2"
ShopConfig.DefaultCurrency = {
	Coins = 2500,
	Gems = 120,
}

ShopConfig.Currencies = {
	Coins = {
		DisplayName = "Coins",
		Icon = "rbxassetid://1053639089",
		Color = Color3.fromRGB(231, 187, 76),
	},
	Gems = {
		DisplayName = "Gems",
		Icon = "rbxassetid://18896714246",
		Color = Color3.fromRGB(116, 177, 235),
	},
}

ShopConfig.Rarities = {
	Common = {Color = Color3.fromRGB(166, 173, 183), Order = 1},
	Uncommon = {Color = Color3.fromRGB(83, 178, 119), Order = 2},
	Rare = {Color = Color3.fromRGB(82, 145, 218), Order = 3},
	Epic = {Color = Color3.fromRGB(151, 101, 215), Order = 4},
	Legendary = {Color = Color3.fromRGB(215, 157, 66), Order = 5},
}

ShopConfig.Categories = {
	{Name = "Featured", Featured = true},
	{Name = "Weapons"},
	{Name = "Tools"},
	{Name = "Consumables"},
	{Name = "Miscellaneous"},
}

ShopConfig.PurchaseCooldown = 0.35
ShopConfig.MaxPurchaseQuantity = 25
ShopConfig.StartingItemId = "iron_sword"
ShopConfig.MaxVisibleCards = 24

return ShopConfig
