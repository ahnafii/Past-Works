--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("ShopGui")
local remotes = ReplicatedStorage:WaitForChild("ShopRemotes")
local purchaseRemote = remotes:WaitForChild("PurchaseItem") :: RemoteFunction
local getStateRemote = remotes:WaitForChild("GetState") :: RemoteFunction
local stateChanged = remotes:WaitForChild("StateChanged") :: RemoteEvent

local config = require(script.Parent.Parent.Shared.ShopConfig)
local items = require(script.Parent.Parent.Shared.ItemCatalog)

local overlay = gui:WaitForChild("Overlay") :: Frame
local window = overlay:WaitForChild("Window") :: Frame
local categories = window.Body.Categories :: ScrollingFrame
local toolbar = window.Body.Toolbar :: Frame
local search = toolbar.Search :: TextBox
local sort = toolbar.Sort :: TextButton
local grid = window.Body.Content.GridContainer.ItemGrid :: ScrollingFrame
local gridLayout = grid.GridLayout :: UIGridLayout
local emptyState = window.Body.Content.GridContainer.EmptyState :: Frame
local details = window.Body.Content.Details :: Frame
local modal = overlay.ConfirmModal :: Frame
local toastContainer = gui.ToastContainer :: Frame

local selectedId: string? = nil
local selectedCategory = "Featured"
local sortMode = "Featured"
local playerState = {Currencies = {}, Inventory = {}}
local isMobile = false
local originalWindowSize = window.Size

local sortModes = {"Featured", "Price: Low", "Price: High", "Rarity", "A-Z"}

local function formatNumber(value: number): string
	local text = tostring(math.floor(value))
	while true do
		local replaced, count = text:gsub("^(%-?%d+)(%d%d%d)", "%1,%2")
		text = replaced
		if count == 0 then
			break
		end
	end
	return text
end

local function tween(object: Instance, duration: number, properties: {[string]: any})
	TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties):Play()
end

local function showToast(message: string, kind: string)
	local card = Instance.new("Frame")
	card.Name = "Toast"
	card.BackgroundColor3 = kind == "success" and Color3.fromRGB(28, 47, 41) or Color3.fromRGB(52, 32, 34)
	card.BorderSizePixel = 0
	card.Size = UDim2.fromOffset(300, 58)
	card.BackgroundTransparency = 1
	card.Parent = toastContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 9)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = kind == "success" and config.Currencies.Coins.Color or Color3.fromRGB(180, 83, 88)
	stroke.Transparency = 0.65
	stroke.Parent = card

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamMedium
	label.Text = message
	label.TextColor3 = Color3.fromRGB(244, 246, 249)
	label.TextSize = 12
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Position = UDim2.fromOffset(15, 0)
	label.Size = UDim2.new(1, -30, 1, 0)
	label.Parent = card

	tween(card, 0.16, {BackgroundTransparency = 0})
	task.delay(3.2, function()
		if card.Parent then
			tween(card, 0.16, {BackgroundTransparency = 1})
			task.wait(0.18)
			card:Destroy()
		end
	end)
end

local function rarityColor(rarity: string): Color3
	local definition = config.Rarities[rarity]
	return definition and definition.Color or config.Rarities.Common.Color
end

local function getVisibleItems(): {any}
	local result = {}
	local query = string.lower(search.Text)
	for _, item in items do
		local categoryMatches = selectedCategory == "Featured" and item.Featured == true or item.Category == selectedCategory
		local searchMatches = query == "" or string.find(string.lower(item.Name), query, 1, true) ~= nil
		if categoryMatches and searchMatches then
			table.insert(result, item)
		end
	end

	table.sort(result, function(a, b)
		if sortMode == "Price: Low" then
			return a.Price < b.Price
		elseif sortMode == "Price: High" then
			return a.Price > b.Price
		elseif sortMode == "Rarity" then
			local aOrder = config.Rarities[a.Rarity].Order
			local bOrder = config.Rarities[b.Rarity].Order
			if aOrder == bOrder then
				return a.Name < b.Name
			end
			return aOrder > bOrder
		elseif sortMode == "A-Z" then
			return a.Name < b.Name
		else
			if (a.Featured and not b.Featured) then
				return true
			end
			if (b.Featured and not a.Featured) then
				return false
			end
			return a.Name < b.Name
		end
	end)
	return result
end

local function setSelected(id: string)
	selectedId = id
	local item = items[id]
	if not item then
		return
	end

	details.Rarity.Text = string.upper(item.Rarity)
	details.Rarity.TextColor3 = rarityColor(item.Rarity)
	details.Name.Text = item.Name
	details.Description.Text = item.Description
	details.IconFrame.Glyph.Text = item.Glyph
	details.IconFrame.Glyph.TextColor3 = rarityColor(item.Rarity)

	local statsText = ""
	if item.Stats then
		for stat, value in item.Stats do
			statsText ..= string.upper(stat) .. "   " .. tostring(value) .. "\n"
		end
	end
	details.Stats.Damage.Text = statsText ~= "" and string.sub(statsText, 1, -2) or "NO STATS"

	local owned = playerState.Inventory[item.Id] or 0
	details.Stats.Owned.Text = (item.Stackable and "Owned  •  " or "Owned  •  ") .. tostring(owned)

	local currency = config.Currencies[item.Currency]
	details.Purchase.Text = currency.Symbol .. " " .. formatNumber(item.Price) .. "   •   Purchase"
	details.Purchase.BackgroundColor3 = currency.Color

	if isMobile then
		details.Visible = true
		grid.Parent.Visible = false
	end
end

local function clearCards()
	for _, child in grid:GetChildren() do
		if child:IsA("Frame") and child.Name == "ItemCard" then
			child:Destroy()
		end
	end
end

local function makeCard(item: any, index: number)
	local card = Instance.new("Frame")
	card.Name = "ItemCard"
	card.BackgroundColor3 = Color3.fromRGB(20, 24, 31)
	card.BorderSizePixel = 0
	card.LayoutOrder = index
	card.Parent = grid

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = rarityColor(item.Rarity)
	stroke.Transparency = 0.78
	stroke.Parent = card

	local iconFrame = Instance.new("Frame")
	iconFrame.Name = "IconFrame"
	iconFrame.BackgroundColor3 = Color3.fromRGB(28, 34, 42)
	iconFrame.BorderSizePixel = 0
	iconFrame.Position = UDim2.fromOffset(8, 8)
	iconFrame.Size = UDim2.new(1, -16, 0, 88)
	iconFrame.Parent = card
	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 8)
	iconCorner.Parent = iconFrame

	local glyph = Instance.new("TextLabel")
	glyph.BackgroundTransparency = 1
	glyph.Font = Enum.Font.GothamBold
	glyph.Text = item.Glyph
	glyph.TextColor3 = rarityColor(item.Rarity)
	glyph.TextSize = 30
	glyph.Size = UDim2.fromScale(1, 1)
	glyph.Parent = iconFrame

	local name = Instance.new("TextLabel")
	name.BackgroundTransparency = 1
	name.Font = Enum.Font.GothamBold
	name.Text = item.Name
	name.TextColor3 = Color3.fromRGB(244, 246, 249)
	name.TextSize = 11
	name.TextTruncate = Enum.TextTruncate.AtEnd
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.Position = UDim2.fromOffset(9, 103)
	name.Size = UDim2.new(1, -18, 0, 20)
	name.Parent = card

	local rarity = Instance.new("TextLabel")
	rarity.BackgroundTransparency = 1
	rarity.Font = Enum.Font.GothamMedium
	rarity.Text = string.upper(item.Rarity)
	rarity.TextColor3 = rarityColor(item.Rarity)
	rarity.TextSize = 8
	rarity.TextXAlignment = Enum.TextXAlignment.Left
	rarity.Position = UDim2.fromOffset(9, 123)
	rarity.Size = UDim2.new(0.5, -9, 0, 15)
	rarity.Parent = card

	local price = Instance.new("TextLabel")
	price.BackgroundTransparency = 1
	price.Font = Enum.Font.GothamBold
	price.Text = config.Currencies[item.Currency].Symbol .. " " .. formatNumber(item.Price)
	price.TextColor3 = config.Currencies[item.Currency].Color
	price.TextSize = 10
	price.TextXAlignment = Enum.TextXAlignment.Right
	price.Position = UDim2.new(0.5, 0, 1, -27)
	price.Size = UDim2.new(0.5, -9, 0, 18)
	price.Parent = card

	local owned = playerState.Inventory[item.Id] or 0
	if owned > 0 then
		local ownedLabel = Instance.new("TextLabel")
		ownedLabel.BackgroundTransparency = 1
		ownedLabel.Font = Enum.Font.GothamMedium
		ownedLabel.Text = item.Stackable and ("Owned " .. owned) or "OWNED"
		ownedLabel.TextColor3 = Color3.fromRGB(155, 163, 175)
		ownedLabel.TextSize = 8
		ownedLabel.TextXAlignment = Enum.TextXAlignment.Left
		ownedLabel.Position = UDim2.fromOffset(9, 140)
		ownedLabel.Size = UDim2.new(0.5, -9, 0, 14)
		ownedLabel.Parent = card
	end

	local hitbox = Instance.new("TextButton")
	hitbox.Name = "Select"
	hitbox.BackgroundTransparency = 1
	hitbox.Text = ""
	hitbox.Size = UDim2.fromScale(1, 1)
	hitbox.Parent = card
	hitbox.Activated:Connect(function()
		setSelected(item.Id)
		for _, other in grid:GetChildren() do
			if other:IsA("Frame") and other.Name == "ItemCard" then
				local otherStroke = other:FindFirstChildOfClass("UIStroke")
				if otherStroke then
					otherStroke.Transparency = other == card and 0.15 or 0.78
				end
			end
		end
	end)
	hitbox.MouseEnter:Connect(function()
		if not isMobile then
			tween(card, 0.1, {BackgroundColor3 = Color3.fromRGB(27, 32, 40)})
		end
	end)
	hitbox.MouseLeave:Connect(function()
		if not isMobile then
			tween(card, 0.12, {BackgroundColor3 = Color3.fromRGB(20, 24, 31)})
		end
	end)
end

local function render()
	clearCards()
	local visible = getVisibleItems()
	emptyState.Visible = #visible == 0
	for index, item in visible do
		makeCard(item, index)
	end

	if selectedId then
		local selectedStillVisible = false
		for _, item in visible do
			if item.Id == selectedId then
				selectedStillVisible = true
				break
			end
		end
		if not selectedStillVisible then
			selectedId = nil
		end
	end

	if not selectedId and #visible > 0 then
		setSelected(visible[1].Id)
	end
end

local function applyResponsive()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local width = camera.ViewportSize.X
	isMobile = width < 700

	if isMobile then
		window.Size = UDim2.fromScale(0.94, 0.90)
		gridLayout.FillDirectionMaxCells = 2
		gridLayout.CellSize = UDim2.new(0.5, -7, 0, 176)
		details.Size = UDim2.fromScale(1, 1)
		details.Position = UDim2.fromScale(0, 0)
		details.AnchorPoint = Vector2.zero
		details.Visible = selectedId ~= nil
		window.Body.Content.GridContainer.Visible = not details.Visible
	else
		window.Size = width < 980 and UDim2.fromScale(0.92, 0.86) or originalWindowSize
		gridLayout.FillDirectionMaxCells = width < 900 and 2 or 3
		gridLayout.CellSize = width < 900 and UDim2.new(0.5, -7, 0, 178) or UDim2.new(0.333, -7, 0, 178)
		details.AnchorPoint = Vector2.new(1, 0)
		details.Position = UDim2.new(1, 0, 0, 0)
		details.Size = width < 900 and UDim2.new(0.42, -2, 1, 0) or UDim2.new(0.37, -2, 1, 0)
		details.Visible = true
		window.Body.Content.GridContainer.Visible = true
	end
end

local function updateCurrencyDisplay()
	local currencyBar = window.Header.CurrencyBar
	local coins = playerState.Currencies.Coins or 0
	local gems = playerState.Currencies.Gems or 0
	currencyBar.Coins.Text = config.Currencies.Coins.Symbol .. "  " .. formatNumber(coins)
	currencyBar.Gems.Text = config.Currencies.Gems.Symbol .. "  " .. formatNumber(gems)
end

local function refreshState()
	local success, result = pcall(function()
		return getStateRemote:InvokeServer()
	end)
	if success and type(result) == "table" then
		playerState = result
		updateCurrencyDisplay()
		render()
	end
end

local function closeShop()
	tween(overlay, 0.15, {BackgroundTransparency = 1})
	tween(window, 0.18, {Position = UDim2.fromScale(0.5, 0.53)})
	task.delay(0.18, function()
		if gui.Parent then
			gui.Enabled = false
		end
	end)
end

local function openShop()
	gui.Enabled = true
	overlay.BackgroundTransparency = 1
	window.Position = UDim2.fromScale(0.5, 0.53)
	tween(overlay, 0.16, {BackgroundTransparency = 0.42})
	tween(window, 0.2, {Position = UDim2.fromScale(0.5, 0.5)})
	refreshState()
end

window.Header.Close.Activated:Connect(closeShop)

search:GetPropertyChangedSignal("Text"):Connect(render)

sort.Activated:Connect(function()
	local currentIndex = table.find(sortModes, sortMode) or 1
	sortMode = sortModes[currentIndex % #sortModes + 1]
	sort.Text = "Sort: " .. sortMode .. "  ▾"
	render()
end)

for _, child in categories:GetChildren() do
	if child:IsA("TextButton") then
		child.Activated:Connect(function()
			selectedCategory = child.Name
			for _, button in categories:GetChildren() do
				if button:IsA("TextButton") then
					local active = button == child
					button.BackgroundColor3 = active and Color3.fromRGB(30, 35, 44) or Color3.fromRGB(20, 24, 31)
					button.TextColor3 = active and Color3.fromRGB(244, 246, 249) or Color3.fromRGB(155, 163, 175)
				end
			end
			render()
		end)
	end
end

window.Body.Content.Details.Purchase.Activated:Connect(function()
	if not selectedId then
		return
	end
	local item = items[selectedId]
	if not item then
		return
	end
	modal.Message.Text = ("Purchase %s for %s %d?"):format(item.Name, config.Currencies[item.Currency].Symbol, item.Price)
	modal.Visible = true
end)

modal.Cancel.Activated:Connect(function()
	modal.Visible = false
end)

modal.Confirm.Activated:Connect(function()
	modal.Visible = false
	if not selectedId then
		return
	end

	local requestedId = selectedId
	local success, result = pcall(function()
		return purchaseRemote:InvokeServer(requestedId, 1)
	end)
	if not success then
		showToast("The purchase could not be completed. Please try again.", "error")
		return
	end
	if type(result) ~= "table" then
		showToast("The server returned an invalid response.", "error")
		return
	end
	if result.Success then
		playerState = result.State or playerState
		updateCurrencyDisplay()
		showToast(result.Message or "Purchase complete.", "success")
		render()
	else
		showToast(result.Message or "Purchase failed.", "error")
	end
end)

stateChanged.OnClientEvent:Connect(function(state)
	if type(state) == "table" then
		playerState = state
		updateCurrencyDisplay()
		render()
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.Escape then
		if modal.Visible then
			modal.Visible = false
		elseif gui.Enabled then
			closeShop()
		end
	end
end)

local camera = workspace.CurrentCamera
if camera then
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsive)
end

applyResponsive()
updateCurrencyDisplay()
render()
openShop()
