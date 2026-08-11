--!strict

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local shared = ReplicatedStorage:WaitForChild("ShopSystem"):WaitForChild("Shared")
local ShopConfig = require(shared:WaitForChild("ShopConfig"))
local Items = require(shared:WaitForChild("ItemCatalog"))

local remotes = ReplicatedStorage:FindFirstChild("ShopRemotes") or Instance.new("Folder")
remotes.Name = "ShopRemotes"
remotes.Parent = ReplicatedStorage

local purchase = remotes:FindFirstChild("PurchaseItem") or Instance.new("RemoteFunction")
purchase.Name = "PurchaseItem"
purchase.Parent = remotes

local getState = remotes:FindFirstChild("GetState") or Instance.new("RemoteFunction")
getState.Name = "GetState"
getState.Parent = remotes

local stateChanged = remotes:FindFirstChild("StateChanged") or Instance.new("RemoteEvent")
stateChanged.Name = "StateChanged"
stateChanged.Parent = remotes

local store = DataStoreService:GetDataStore(ShopConfig.DataStoreName)

type PlayerState = {
	Currencies: {[string]: number},
	Inventory: {[string]: number},
}

local sessions: {[Player]: PlayerState} = {}
local purchaseTimes: {[Player]: number} = {}
local serverStock: {[string]: number} = {}

for id, item in Items do
	if item.Stock then
		serverStock[id] = item.Stock
	end
end

local function cloneDefaults(): PlayerState
	local currencies = {}
	for currency, amount in ShopConfig.DefaultCurrency do
		currencies[currency] = amount
	end
	return {Currencies = currencies, Inventory = {}}
end

local function sanitizeState(raw: any): PlayerState
	local state = cloneDefaults()
	if type(raw) ~= "table" then
		return state
	end

	if type(raw.Currencies) == "table" then
		for currency in ShopConfig.Currencies do
			if type(raw.Currencies[currency]) == "number" then
				state.Currencies[currency] = math.max(0, math.floor(raw.Currencies[currency]))
			end
		end
	end

	if type(raw.Inventory) == "table" then
		for itemId, quantity in raw.Inventory do
			local item = Items[itemId]
			if item and type(quantity) == "number" and quantity > 0 then
				local maxOwned = item.MaxOwned or math.huge
				state.Inventory[itemId] = math.min(maxOwned, math.floor(quantity))
			end
		end
	end

	return state
end

local function loadState(player: Player): PlayerState
	local success, data = pcall(function()
		return store:GetAsync(("player_%d"):format(player.UserId))
	end)

	if not success then
		warn(("[Shop] Failed to load %s: %s"):format(player.Name, tostring(data)))
		return cloneDefaults()
	end

	return sanitizeState(data)
end

local function saveState(player: Player)
	local state = sessions[player]
	if not state then
		return
	end

	local payload = {
		Version = ShopConfig.Version,
		Currencies = state.Currencies,
		Inventory = state.Inventory,
		SavedAt = os.time(),
	}

	local success, err = pcall(function()
		store:UpdateAsync(("player_%d"):format(player.UserId), function()
			return payload
		end)
	end)

	if not success then
		warn(("[Shop] Failed to save %s: %s"):format(player.Name, tostring(err)))
	end
end

local function publicState(state: PlayerState)
	return {
		Currencies = table.clone(state.Currencies),
		Inventory = table.clone(state.Inventory),
	}
end

local function validRequest(player: Player, itemId: any, quantity: any): (boolean, string?)
	if type(itemId) ~= "string" or #itemId < 1 or #itemId > 64 then
		return false, "Invalid item."
	end

	if type(quantity) ~= "number" or quantity ~= quantity or quantity % 1 ~= 0 then
		return false, "Invalid quantity."
	end

	if quantity < 1 or quantity > ShopConfig.MaxPurchaseQuantity then
		return false, "Invalid quantity."
	end

	local now = os.clock()
	local last = purchaseTimes[player] or 0
	if now - last < ShopConfig.PurchaseCooldown then
		return false, "Please slow down."
	end
	purchaseTimes[player] = now

	return true
end

local function purchaseItem(player: Player, itemId: any, quantity: any)
	local ok, reason = validRequest(player, itemId, quantity)
	if not ok then
		return {Success = false, Code = "INVALID_REQUEST", Message = reason}
	end

	local state = sessions[player]
	local item = Items[itemId]
	if not state or not item then
		return {Success = false, Code = "UNAVAILABLE", Message = "That item is unavailable."}
	end

	local currency = ShopConfig.Currencies[item.Currency]
	if not currency then
		return {Success = false, Code = "CONFIGURATION", Message = "That item is not configured correctly."}
	end

	local owned = state.Inventory[itemId] or 0
	local maxOwned = item.MaxOwned or math.huge

	if not item.Stackable and owned > 0 then
		return {Success = false, Code = "OWNED", Message = "You already own this item."}
	end

	if owned + quantity > maxOwned then
		return {Success = false, Code = "LIMIT", Message = ("You can only hold %d of this item."):format(maxOwned)}
	end

	local available = serverStock[itemId]
	if available ~= nil and quantity > available then
		return {Success = false, Code = "STOCK", Message = "That item is out of stock."}
	end

	local price = item.Price * quantity
	local balance = state.Currencies[item.Currency] or 0
	if balance < price then
		return {
			Success = false,
			Code = "FUNDS",
			Message = ("You need %s %d more."):format(currency.DisplayName, price - balance),
		}
	end

	-- The server is the only authority over the economic mutation.
	state.Currencies[item.Currency] = balance - price
	state.Inventory[itemId] = owned + quantity

	if available ~= nil then
		serverStock[itemId] = available - quantity
	end

	local newState = publicState(state)
	stateChanged:FireClient(player, newState)

	return {
		Success = true,
		Code = "PURCHASED",
		Message = quantity > 1
			and ("Purchased %dx %s."):format(quantity, item.Name)
			or ("Purchased %s."):format(item.Name),
		ItemId = itemId,
		Quantity = quantity,
		TransactionId = HttpService:GenerateGUID(false),
		State = newState,
	}
end

getState.OnServerInvoke = function(player: Player)
	local state = sessions[player]
	if not state then
		return {Currencies = {}, Inventory = {}}
	end
	return publicState(state)
end

purchase.OnServerInvoke = function(player: Player, itemId: any, quantity: any)
	return purchaseItem(player, itemId, quantity)
end

Players.PlayerAdded:Connect(function(player)
	sessions[player] = loadState(player)
end)

Players.PlayerRemoving:Connect(function(player)
	saveState(player)
	sessions[player] = nil
	purchaseTimes[player] = nil
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		saveState(player)
	end
end)
