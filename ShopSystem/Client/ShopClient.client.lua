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

local shared = ReplicatedStorage:WaitForChild("ShopSystem"):WaitForChild("Shared")
local config = require(shared:WaitForChild("ShopConfig"))
local items = require(shared:WaitForChild("ItemCatalog"))

local overlay = gui.Overlay :: Frame
local window = overlay.Window :: Frame
local header = window.Header :: Frame
local body = window.Body :: Frame
local categories = body.Categories :: ScrollingFrame
local toolbar = body.Toolbar :: Frame
local search = toolbar.Search :: TextBox
local clearSearch = search.Clear :: TextButton
local sortButton = toolbar.Sort :: TextButton
local content = body.Content :: Frame
local gridContainer = content.GridContainer :: Frame
local grid = gridContainer.ItemGrid :: ScrollingFrame
local gridLayout = grid.GridLayout :: UIGridLayout
local emptyState = gridContainer.EmptyState :: Frame
local details = content.Details :: Frame
local modal = overlay.ConfirmModal :: Frame
local toastContainer = gui.ToastContainer :: Frame

local selectedId: string? = nil
local selectedCategory = "Featured"
local sortMode = "Featured"
local playerState = {Currencies = {}, Inventory = {}}
local isMobile = false
local detailOpenOnMobile = false
local modalItemId: string? = nil
local toastSerial = 0
local sortModes = {"Featured", "Price: Low", "Price: High", "Rarity", "A-Z"}
local sortIndex = 1

local function formatNumber(value: number): string
	local text = tostring(math.floor(value))
	while true do
		local replaced, count = text:gsub("^(%-?%d+)(%d%d%d)", "%1,%2")
		text = replaced
		if count == 0 then break end
	end
	return text
end

local function tween(object: Instance, duration: number, properties: {[string]: any})
	TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties):Play()
end

local function rarityColor(rarity: string): Color3
	local definition = config.Rarities[rarity]
	return definition and definition.Color or config.Rarities.Common.Color
end

local function getCurrency(name: string)
	return config.Currencies[name]
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
			if aOrder == bOrder then return a.Name < b.Name end
			return aOrder > bOrder
		elseif sortMode == "A-Z" then
			return a.Name < b.Name
		end
		if a.Featured and not b.Featured then return true end
		if b.Featured and not a.Featured then return false end
		return a.Name < b.Name
	end)

	return result
end

local function updateWallet()
	header.Wallet.Coins.Icon.Image = config.Currencies.Coins.Icon
	header.Wallet.Coins.Amount.Text = formatNumber(playerState.Currencies.Coins or 0)
	header.Wallet.Gems.Icon.Image = config.Currencies.Gems.Icon
	header.Wallet.Gems.Amount.Text = formatNumber(playerState.Currencies.Gems or 0)

	if isMobile then
		header.Subtitle.Text = string.format("Coins %s    Gems %s", formatNumber(playerState.Currencies.Coins or 0), formatNumber(playerState.Currencies.Gems or 0))
	end
end

local function updateCategoryVisuals()
	for _, button in categories:GetChildren() do
		if button:IsA("TextButton") then
			local active = button.Name == selectedCategory
			button.BackgroundColor3 = active and Color3.fromRGB(28, 37, 45) or Color3.fromRGB(15, 19, 25)
			button.TextColor3 = active and Color3.fromRGB(244, 246, 249) or Color3.fromRGB(151, 160, 172)
			local border = button:FindFirstChild("Border")
			if border and border:IsA("UIStroke") then
				border.Color = active and Color3.fromRGB(68, 180, 148) or Color3.fromRGB(49, 59, 70)
				border.Transparency = active and 0.25 or 0.72
			end
		end
	end
end

local function updateSortButton()
	sortButton.Text = "SORT  /  " .. string.upper(sortModes[sortIndex])
end

local function updateCard(card: Frame, item: any, selected: boolean)
	local rarity = rarityColor(item.Rarity)
	local currency = getCurrency(item.Currency)
	local owned = playerState.Inventory[item.Id] or 0

	card.Visible = true
	card.BackgroundColor3 = selected and Color3.fromRGB(28, 37, 45) or Color3.fromRGB(15, 19, 25)

	local border = card:FindFirstChild("Border")
	if border and border:IsA("UIStroke") then
		border.Color = rarity
		border.Transparency = selected and 0.18 or 0.68
	end

	card.Media.ItemImage.Image = item.Icon
	card.Media.RarityBar.BackgroundColor3 = rarity
	card.Name.Text = item.Name
	card.Rarity.Text = string.upper(item.Rarity)
	card.Rarity.TextColor3 = rarity
	card.CurrencyIcon.Image = currency.Icon
	card.Price.Text = formatNumber(item.Price)
	card.Price.TextColor3 = currency.Color
	card.Owned.Text = owned > 0 and (item.Stackable and ("OWNED " .. owned) or "OWNED") or ""
end

local function hideUnusedCards(fromIndex: number)
	for index = fromIndex, config.MaxVisibleCards do
		local card = grid:FindFirstChild(string.format("Card%02d", index))
		if card and card:IsA("Frame") then card.Visible = false end
	end
end

local function updateDetails(item: any)
	if not item then return end
	local rarity = rarityColor(item.Rarity)
	local currency = getCurrency(item.Currency)
	local owned = playerState.Inventory[item.Id] or 0

	details.Media.ItemImage.Image = item.Icon
	details.Media.RarityMark.BackgroundColor3 = rarity
	details.Rarity.Text = string.upper(item.Rarity)
	details.Rarity.TextColor3 = rarity
	details.Name.Text = item.Name
	details.Description.Text = item.Description
	details.Ownership.Text = item.Stackable and ("Owned " .. owned .. "  /  " .. (item.MaxOwned or "∞")) or (owned > 0 and "Owned" or "Not owned")

	for _, child in details.Stats:GetChildren() do
		if child:IsA("TextLabel") and child.Name:match("^Row") then child.Visible = false end
	end

	local statNames = {}
	if item.Stats then
		for statName in item.Stats do table.insert(statNames, statName) end
		table.sort(statNames)
	end

	local rowIndex = 1
	for _, statName in statNames do
		if rowIndex > 3 then break end
		local row = details.Stats:FindFirstChild("Row" .. rowIndex) :: TextLabel
		row.Text = string.upper(statName) .. "   " .. tostring(item.Stats[statName])
		row.TextColor3 = rowIndex == 1 and Color3.fromRGB(244, 246, 249) or Color3.fromRGB(185, 193, 203)
		row.Visible = true
		rowIndex += 1
	end

	if rowIndex == 1 then
		details.Stats.Row1.Text = "NO ADDITIONAL STATS"
		details.Stats.Row1.TextColor3 = Color3.fromRGB(101, 113, 128)
		details.Stats.Row1.Visible = true
	end

	local canPurchase = true
	local hint = "Validated securely by the server"
	if not item.Stackable and owned > 0 then
		canPurchase = false
		hint = "Already owned"
	elseif item.MaxOwned and owned >= item.MaxOwned then
		canPurchase = false
		hint = "Maximum owned"
	end

	details.Purchase:SetAttribute("CanPurchase", canPurchase)
	details.Purchase.BackgroundColor3 = canPurchase and Color3.fromRGB(68, 180, 148) or Color3.fromRGB(49, 59, 70)
	details.Purchase.TextColor3 = canPurchase and Color3.fromRGB(6, 20, 16) or Color3.fromRGB(151, 160, 172)
	details.Purchase.Text = canPurchase and ("PURCHASE  /  " .. formatNumber(item.Price) .. " " .. string.upper(currency.DisplayName)) or hint
	details.PurchaseHint.Text = canPurchase and hint or ""

	if isMobile then
		detailOpenOnMobile = true
		details.Visible = true
		details.Back.Visible = true
		gridContainer.Visible = false
	end
end

local function selectItem(id: string)
	if items[id] then
		selectedId = id
		updateDetails(items[id])
	end
end

local function render()
	updateCategoryVisuals()
	clearSearch.Visible = search.Text ~= ""

	local visible = getVisibleItems()
	emptyState.Visible = #visible == 0

	if #visible == 0 then
		selectedId = nil
		hideUnusedCards(1)
		return
	end

	local selectedVisible = false
	if selectedId then
		for _, item in visible do
			if item.Id == selectedId then selectedVisible = true break end
		end
	end
	if not selectedVisible then selectedId = visible[1].Id end

	for index = 1, math.min(#visible, config.MaxVisibleCards) do
		local item = visible[index]
		local card = grid:FindFirstChild(string.format("Card%02d", index)) :: Frame
		updateCard(card, item, item.Id == selectedId)
	end
	hideUnusedCards(math.min(#visible + 1, config.MaxVisibleCards + 1))
	updateDetails(items[selectedId :: string])
end

local function hideModal()
	modal.Visible = false
	modalItemId = nil
	overlay.BackgroundTransparency = 0.28
end

local function showModal(item: any)
	modalItemId = item.Id
	local currency = getCurrency(item.Currency)
	modal.ItemImage.Image = item.Icon
	modal.ItemName.Text = item.Name
	modal.Price.Text = formatNumber(item.Price) .. " " .. string.upper(currency.DisplayName)
	modal.Message.Text = "Confirm this purchase. The server will validate the item, price, balance, ownership, and request."
	modal.Visible = true
	overlay.BackgroundTransparency = 0.10
end

local function showToast(title: string, message: string, success: boolean)
	toastSerial += 1
	local slot = ((toastSerial - 1) % 4) + 1
	local toast = toastContainer:FindFirstChild(string.format("Toast%02d", slot)) :: Frame
	toast.Visible = true
	toast.BackgroundTransparency = 1
	toast.Title.Text = title
	toast.Message.Text = message
	toast.Accent.BackgroundColor3 = success and Color3.fromRGB(68, 180, 148) or Color3.fromRGB(211, 88, 96)
	tween(toast, 0.14, {BackgroundTransparency = 0})
	task.delay(3.2, function()
		if toast.Parent then
			tween(toast, 0.14, {BackgroundTransparency = 1})
			task.wait(0.15)
			toast.Visible = false
		end
	end)
end

local function closeShop()
	if modal.Visible then hideModal() return end
	tween(overlay, 0.14, {BackgroundTransparency = 1})
	tween(window, 0.18, {Position = UDim2.fromScale(0.5, 0.53)})
	task.delay(0.18, function()
		if gui.Parent then gui.Enabled = false end
	end)
end

local function openShop()
	gui.Enabled = true
	overlay.BackgroundTransparency = 1
	window.Position = UDim2.fromScale(0.5, 0.53)
	tween(overlay, 0.14, {BackgroundTransparency = 0.28})
	tween(window, 0.18, {Position = UDim2.fromScale(0.5, 0.5)})
end

local function applyResponsive()
	local camera = workspace.CurrentCamera
	if not camera then return end

	local width = camera.ViewportSize.X
	isMobile = width < 720
	window.WindowConstraint.MinSize = isMobile and Vector2.new(320, 420) or Vector2.new(760, 540)

	if isMobile then
		window.Size = UDim2.fromScale(0.95, 0.92)
		gridLayout.FillDirectionMaxCells = 2
		gridLayout.CellSize = UDim2.new(0.5, -5, 0, 176)
		details.Size = UDim2.fromScale(1, 1)
		details.Position = UDim2.fromScale(0, 0)
		details.AnchorPoint = Vector2.zero
		details.Visible = detailOpenOnMobile
		details.Back.Visible = detailOpenOnMobile
		gridContainer.Visible = not detailOpenOnMobile
		header.Wallet.Visible = false
		header.Title.TextSize = 21
	else
		window.Size = width < 980 and UDim2.fromScale(0.94, 0.89) or UDim2.fromScale(0.91, 0.86)
		local columns = width < 1120 and 2 or 3
		gridLayout.FillDirectionMaxCells = columns
		gridLayout.CellSize = UDim2.new(1 / columns, -6, 0, 176)
		details.AnchorPoint = Vector2.new(1, 0)
		details.Position = UDim2.new(1, 0, 0, 0)
		details.Size = UDim2.new(width < 980 and 0.39 or 0.32, -1, 1, 0)
		details.Visible = true
		details.Back.Visible = false
		gridContainer.Visible = true
		header.Wallet.Visible = true
		header.Title.TextSize = 26
		header.Subtitle.Text = "Gear, supplies, and useful things for the road."
	end
	updateWallet()
end

local function refreshState()
	local success, result = pcall(function()
		return getStateRemote:InvokeServer()
	end)
	if success and type(result) == "table" then
		playerState = result
		updateWallet()
		render()
	else
		showToast("SHOP UNAVAILABLE", "Unable to load your shop state.", false)
	end
end

for index = 1, config.MaxVisibleCards do
	local card = grid:FindFirstChild(string.format("Card%02d", index)) :: Frame
	local selectButton = card.Select :: TextButton
	selectButton.Activated:Connect(function()
		local visible = getVisibleItems()
		local item = visible[index]
		if item then
			selectItem(item.Id)
			render()
		end
	end)

	selectButton.MouseEnter:Connect(function()
		if isMobile then return end
		local visible = getVisibleItems()
		local item = visible[index]
		if item and item.Id ~= selectedId then
			tween(card, 0.1, {BackgroundColor3 = Color3.fromRGB(23, 30, 37)})
		end
	end)

	selectButton.MouseLeave:Connect(function()
		if isMobile then return end
		local visible = getVisibleItems()
		local item = visible[index]
		if item then updateCard(card, item, item.Id == selectedId) end
	end)
end

for _, button in categories:GetChildren() do
	if button:IsA("TextButton") then
		button.Activated:Connect(function()
			selectedCategory = button.Name
			grid.CanvasPosition = Vector2.zero
			render()
		end)
	end
end

search:GetPropertyChangedSignal("Text"):Connect(function()
	grid.CanvasPosition = Vector2.zero
	render()
end)

clearSearch.Activated:Connect(function()
	search.Text = ""
	search:ReleaseFocus()
end)

sortButton.Activated:Connect(function()
	sortIndex = sortIndex % #sortModes + 1
	sortMode = sortModes[sortIndex]
	grid.CanvasPosition = Vector2.zero
	updateSortButton()
	render()
end)

header.Close.Activated:Connect(closeShop)

details.Back.Activated:Connect(function()
	detailOpenOnMobile = false
	details.Visible = false
	details.Back.Visible = false
	gridContainer.Visible = true
end)

details.Purchase.Activated:Connect(function()
	if not selectedId or not details.Purchase:GetAttribute("CanPurchase") then return end
	local item = items[selectedId]
	if item then showModal(item) end
end)

modal.Cancel.Activated:Connect(hideModal)
modal.Confirm.Activated:Connect(function()
	local id = modalItemId
	if not id then return end

	modal.Confirm.Active = false
	modal.Confirm.Text = "PROCESSING..."
	local success, result = pcall(function()
		return purchaseRemote:InvokeServer(id, 1)
	end)
	modal.Confirm.Active = true
	modal.Confirm.Text = "CONFIRM"
	hideModal()

	if not success or type(result) ~= "table" then
		showToast("PURCHASE FAILED", "The server did not return a valid response.", false)
		return
	end

	if result.Success then
		if type(result.State) == "table" then playerState = result.State end
		updateWallet()
		render()
		showToast("PURCHASE COMPLETE", result.Message or "Purchase completed.", true)
	else
		showToast("PURCHASE FAILED", result.Message or "The purchase was rejected.", false)
		refreshState()
	end
end)

stateChanged.OnClientEvent:Connect(function(newState)
	if type(newState) == "table" then
		playerState = newState
		updateWallet()
		render()
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Escape then
		if modal.Visible then
			hideModal()
		elseif gui.Enabled then
			closeShop()
		end
	end
end)

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsive)

updateSortButton()
applyResponsive()
openShop()
refreshState()
