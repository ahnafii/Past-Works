--!strict

export type Item = {
	Id: string,
	Name: string,
	Description: string,
	Category: string,
	Price: number,
	Currency: string,
	Rarity: string,
	Icon: string,
	Glyph: string,
	Stackable: boolean,
	MaxOwned: number?,
	Featured: boolean?,
	Stock: number?,
	Stats: {[string]: number}?,
}

local Items: {[string]: Item} = {
	iron_sword = {
		Id = "iron_sword", Name = "Iron Sword",
		Description = "A dependable blade for new adventurers. Balanced, practical, and easy to maintain.",
		Category = "Weapons", Price = 250, Currency = "Coins", Rarity = "Common",
		Icon = "", Glyph = "◆", Stackable = false, MaxOwned = 1, Featured = true,
		Stats = {Damage = 15},
	},
	emberblade = {
		Id = "emberblade", Name = "Emberblade",
		Description = "A warm-edged sword forged around a fragment of volcanic glass.",
		Category = "Weapons", Price = 850, Currency = "Coins", Rarity = "Rare",
		Icon = "", Glyph = "◈", Stackable = false, MaxOwned = 1, Featured = true,
		Stats = {Damage = 31, Crit = 8},
	},
	hunters_bow = {
		Id = "hunters_bow", Name = "Hunter's Bow",
		Description = "A light bow built for quick shots and long days outside the walls.",
		Category = "Weapons", Price = 620, Currency = "Coins", Rarity = "Uncommon",
		Icon = "", Glyph = "⌁", Stackable = false, MaxOwned = 1,
		Stats = {Damage = 22, Range = 34},
	},
	frost_staff = {
		Id = "frost_staff", Name = "Frost Staff",
		Description = "A polished staff that leaves a thin trail of frost behind every spell.",
		Category = "Weapons", Price = 1450, Currency = "Gems", Rarity = "Epic",
		Icon = "", Glyph = "✦", Stackable = false, MaxOwned = 1, Featured = true,
		Stats = {Damage = 44, Slow = 18},
	},
	shadow_dagger = {
		Id = "shadow_dagger", Name = "Shadow Dagger",
		Description = "A narrow blade prized by scouts who prefer to leave no trace.",
		Category = "Weapons", Price = 2200, Currency = "Coins", Rarity = "Legendary",
		Icon = "", Glyph = "✧", Stackable = false, MaxOwned = 1,
		Stats = {Damage = 57, Crit = 18},
	},
	explorers_lantern = {
		Id = "explorers_lantern", Name = "Explorer's Lantern",
		Description = "A reliable lantern with enough oil for a full night beyond the trail.",
		Category = "Tools", Price = 340, Currency = "Coins", Rarity = "Common",
		Icon = "", Glyph = "◉", Stackable = false, MaxOwned = 1,
		Stats = {Radius = 24},
	},
	grappling_hook = {
		Id = "grappling_hook", Name = "Grappling Hook",
		Description = "A compact climbing tool for reaching ledges that would otherwise be out of reach.",
		Category = "Tools", Price = 780, Currency = "Coins", Rarity = "Uncommon",
		Icon = "", Glyph = "⌁", Stackable = false, MaxOwned = 1,
		Stats = {Range = 48},
	},
	health_potion = {
		Id = "health_potion", Name = "Health Potion",
		Description = "Restores a portion of health when consumed. Always worth keeping one close.",
		Category = "Consumables", Price = 90, Currency = "Coins", Rarity = "Common",
		Icon = "", Glyph = "●", Stackable = true, MaxOwned = 25,
		Stats = {Healing = 35},
	},
	focus_elixir = {
		Id = "focus_elixir", Name = "Focus Elixir",
		Description = "A concentrated tonic that briefly improves ability recovery.",
		Category = "Consumables", Price = 160, Currency = "Coins", Rarity = "Uncommon",
		Icon = "", Glyph = "◌", Stackable = true, MaxOwned = 15,
		Stats = {Duration = 30},
	},
	traveler_pack = {
		Id = "traveler_pack", Name = "Traveler's Pack",
		Description = "A sturdy pack with enough room for the essentials on a long expedition.",
		Category = "Miscellaneous", Price = 540, Currency = "Coins", Rarity = "Uncommon",
		Icon = "", Glyph = "▣", Stackable = false, MaxOwned = 1,
		Stats = {Capacity = 12},
	},
	guild_token = {
		Id = "guild_token", Name = "Guild Token",
		Description = "A polished token accepted by guild merchants for special services.",
		Category = "Miscellaneous", Price = 15, Currency = "Gems", Rarity = "Rare",
		Icon = "", Glyph = "◇", Stackable = true, MaxOwned = 50,
	},
}

return Items
