--!strict

local ShopConfig = {}

ShopConfig.Version = 1
ShopConfig.DataStoreName = "PortfolioShop_v1"
ShopConfig.DefaultCurrency = {
	Coins = 2500,
	Gems = 120,
}

ShopConfig.Currencies = {
	Coins = {
		DisplayName = "Coins",
		Symbol = "◈",
		Color = Color3.fromRGB(244, 198, 83),
	},
	Gems = {
		DisplayName = "Gems",
		Symbol = "◇",
		Color = Color3.fromRGB(178, 205, 255),
	},
}

ShopConfig.Rarities = {
	Common = {Color = Color3.fromRGB(158, 166, 178), Order = 1},
	Uncommon = {Color = Color3.fromRGB(92, 190, 126), Order = 2},
	Rare = {Color = Color3.fromRGB(89, 151, 224), Order = 3},
	Epic = {Color = Color3.fromRGB(163, 112, 224), Order = 4},
	Legendary = {Color = Color3.fromRGB(225, 164, 72), Order = 5},
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

return ShopConfig
