--!strict

local ShopConfig = {}

ShopConfig.Version = 3
ShopConfig.DataStoreName = "PortfolioShop_v3"
ShopConfig.DefaultCurrency = {
	Coins = 2500,
	Gems = 120,
}

-- Demo currency imagery uses real Roblox Creator Store thumbnails.
-- Replace these with your own uploaded assets for a production game.
ShopConfig.Currencies = {
	Coins = {
		DisplayName = "Coins",
		Icon = "rbxthumb://type=Asset&id=4937522724&w=150&h=150",
		Color = Color3.fromRGB(229, 183, 71),
	},
	Gems = {
		DisplayName = "Gems",
		Icon = "rbxthumb://type=Asset&id=93266672&w=150&h=150",
		Color = Color3.fromRGB(116, 177, 235),
	},
}

ShopConfig.Rarities = {
	Common = {Color = Color3.fromRGB(164, 172, 184), Order = 1},
	Uncommon = {Color = Color3.fromRGB(79, 176, 119), Order = 2},
	Rare = {Color = Color3.fromRGB(80, 143, 218), Order = 3},
	Epic = {Color = Color3.fromRGB(148, 99, 213), Order = 4},
	Legendary = {Color = Color3.fromRGB(216, 157, 67), Order = 5},
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
