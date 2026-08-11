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
		if count == 0 then
			break
		end
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

local function currencyDefinition(currencyName: string)
	return config.Currencies[currencyName]
end

local function getVisibleItems(): {any}
	local result = {}
	local query = string.lower(search.Text)

	for _, item in items do
		local categoryMatches = selectedCategory == "Featured"
			and item.Featured == true
			or item.Category == selectedCategory
		local searchMatches = query == ""
			or string.find(string.lower(item.Name), query, 1, true) ~= nil

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
		end

		if a.Featured and not b.Featured then
			return true
		end
		if b.Featured and not a.Featured then
			return false
		end
		return a.Name < b.Name
	end)

	return result
end

local function setCategoryVisuals()
	for _, categoryButton in categories:GetChildren() do
		if categoryButton:IsA("TextButton") then
			local active = categoryButton.Name == selectedCategory
			categoryButton.BackgroundColor3 = active
				and Color3.fromRGB(30, 38, 46)
				or Color3.fromRGB(20, 25, 32)
			categoryButton.TextColor3 = active
				and Color3.fromRGB(245, 247, 250)
				or Color3.fromRGB(145, 155, 168)

			local border = categoryButton:FindFirstChild("Border")
			if border and border:IsA("UIStroke") then
				border.Transparency = active and 0.3 or 0.7
			end
		end
	end
end

local function updateCurrencyDisplay()
	local coins = playerState.Currencies.Coins or 0
	local gems = playerState.Currencies.Gems or 0

	header.Wallet.Coins.Icon.Image = config.Currencies.Coins.Icon
	header.Wallet.Coins.Amount.Text = formatNumber(coins)
	header.Wallet.Gems.Icon.Image = config.Currencies.Gems.Icon
	header.Wallet.Gems.Amount.Text = formatNumber(gems)
end

local function updateSortButton()
	sortButton.Text = "SORT  /  " .. string.upper(sortModes[sortIndex])
end

local function updateCard(card: Frame, item: any, selected: boolean)
	local rarity = rarityColor(item.Rarity)
	local currency = currencyDefinition(item.Currency)
	local owned = playerState.Inventory[item.Id] or 0

	card.Visible = true
	card.BackgroundColor3 = selected
		and Color3.fromRGB(29, 38, 46)
		or Color3.fromRGB(20, 25, 32)

	local border = card:FindFirstChild("Border")
	if border and border:IsA("UIStroke") then
		border.Color = rarity
		border.Transparency = selected and 0.15 or 0.68
	end

	local media = card.Media :: Frame
	media.ItemImage.Image = item.Icon
	media.RarityBar.BackgroundColor3 = rarity

	card.Name.Text = item.Name
	card.Rarity.Text = string.upper(item.Rarity)
	card.Rarity.TextColor3 = rarity
	card.CurrencyIcon.Image = currency.Icon
	card.Price.Text = formatNumber(item.Price)
	card.Price.TextColor3 = currency.Color

	if owned > 0 then
		card.Owned.Text = item.Stackable and ("OWNED " .. tostring(owned)) or "OWNED"
	else
		card.Owned.Text = ""
	end
end

local function clearUnusedCards(startIndex: number)
	for index = startIndex, config.MaxVisibleCards do
		local card = grid:FindFirstChild(string.format("Card%02d", index))
		if card and card:IsA("Frame") then
			card.Visible = false
		end
	end
end

local function updateDetails(item: any)
	local rarity = rarityColor(item.Rarity)
	local currency = currencyDefinition(item.Currency)
	local owned = playerState.Inventory[item.Id] or 0

	details.Media.ItemImage.Image = item.Icon
	details.Media.RarityMark.BackgroundColor3 = rarity
	details.Rarity.Text = string.upper(item.Rarity)
	details.Rarity.TextColor3 = rarity
	details.Name.Text = item.Name
	details.Description.Text = item.Description
	details.Ownership.Text = item.Stackable
		and ("Owned " .. tostring(owned) .. "  /  " .. tostring(item.MaxOwned or "∞"))
		or (owned > 0 and "Owned" or "Not owned")

	local rowIndex = 1
	for _, row in details.Stats:GetChildren() do
		if row:IsA("TextLabel") and row.Name:match("^Row") then
			row.Visible = false
		end
	end

	if item.Stats then
		local statNames = {}
		for statName in item.Stats do
			table.insert(statNames, statName)
		end
		table.sort(statNames)

		for _, statName in statNames do
			if rowIndex > 3 then
				break
			end
			local row = details.Stats:FindFirstChild("Row" .. rowIndex) :: TextLabel
			local value = item.Stats[statName]
			row.Text = string.upper(statName) .. "   " .. tostring(value)
			row.TextColor3 = rowIndex == 1 and Color3.fromRGB(245, 247, 250) or Color3.fromRGB(185, 193, 203)
			row.Visible = true
			rowIndex += 1
		end
	end

	if rowIndex == 1 then
		local row = details.Stats.Row1 :: TextLabel
		row.Text = "NO ADDITIONAL STATS"
		row.TextColor3 = Color3.fromRGB(105, 116, 130)
		row.Visible = true
	end

	local canBuy = true
	local hint = ""
	if not item.Stackable and owned > 0 then
		canBuy = false
		hint = "Already owned"
	elseif item.MaxOwned and owned >= item.MaxOwned then
		canBuy = false
		hint = "Maximum owned"
	end

	details.Purchase.BackgroundColor3 = canBuy and Color3.fromRGB(71, 178, 146) or Color3.fromRGB(57, 66, 77)
	details.Purchase.TextColor3 = canBuy and Color3.fromRGB(7, 20, 17) or Color3.fromRGB(145, 155, 168)
	details.Purchase.Text = canBuy
		and ("PURCHASE  /  " .. formatNumber(item.Price) .. " " .. string.upper(currency.DisplayName))
		or hint
	details.PurchaseHint.Text = canBuy and "Purchase is validated by the server" or ""
	details.Purchase:SetAttribute("CanPurchase", canBuy)

	if isMobile then
		details.Visible = true
		detailOpenOnMobile = true
		gridContainer.Visible = false
		details.Back.Visible = true
	else
		details.Visible = true
	end
end

local function selectItem(id: string)
	local item = items[id]
	if not item then
		return
	end
	selectedId = id
	updateDetails(item)
end

local function render()
	setCategoryVisuals()
	clearSearch.Visible = search.Text ~= ""

	local visible = getVisibleItems()
	emptyState.Visible = #visible == 0

	for index, item in visible do
		if index > config.MaxVisibleCards then
			break
		end
		local card = grid:FindFirstChild(string.format("Card%02d", index)) :: Frame?
		if card then
			updateCard(card, item, item.Id == selectedId)
		end
	end
	clearUnusedCards(math.min(#visible + 1, config.MaxVisibleCards + 1))

	if #visible == 0 then
		selectedId = nil
		return
	end

	local selectedStillVisible = false
	if selectedId then
		for _, item in visible do
			if item.Id == selectedId then
				selectedStillVisible = true
				break
			end
		end
	end

	if not selectedStillVisible then
		selectedId = visible[1].Id
	end

	for index, item in visible do
		if index > config.MaxVisibleCards then
			break
		end
		local card = grid:FindFirstChild(string.format("Card%02d", index)) :: Frame?
		if card then
			updateCard(card, item, item.Id == selectedId)
		end
	end

	updateDetails(items[selectedId :: string])
end

local function hideModal()
	modal.Visible = false
	modalItemId = nil
	overlay.BackgroundTransparency = 0.24
end

local function showModal(item: any)
	modalItemId = item.Id
	modal.ItemImage.Image = item.Icon
	modal.ItemName.Text = item.Name
	modal.Price.Text = formatNumber(item.Price) .. " " .. string.upper(currencyDefinition(item.Currency).DisplayName)
	modal.Message.Text = "Confirm that you want to purchase this item for your current " .. string.lower(currencyDefinition(item.Currency).DisplayName) .. " balance."
	modal.Visible = true
	overlay.BackgroundTransparency = 0.08
end

local function showToast(title: string, message: string, success: boolean)
	toastSerial += 1
	local slotIndex = ((toastSerial - 1) % 4) + 1
	local toast = toastContainer:FindFirstChild(string.format("Toast%02d", slotIndex)) :: Frame
	toast.Visible = true
	toast.BackgroundTransparency = 1
	toast.Title.Text = title
	toast.Message.Text = message
	toast.Accent.BackgroundColor3 = success and Color3.fromRGB(71, 178, 146) or Color3.fromRGB(216, 91, 97)

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
	if modal.Visible then
		hideModal()
		return
	end

	tween(overlay, 0.14, {BackgroundTransparency = 1})
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
	tween(overlay, 0.14, {BackgroundTransparency = 0.24})
	tween(window, 0.18, {Position = UDim2.fromScale(0.5, 0.5)})
end

local function applyResponsive()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	local width = camera.ViewportSize.X
	isMobile = width < 720

	if isMobile then
		window.Size = UDim2.fromScale(0.95, 0.92)
		gridLayout.FillDirectionMaxCells = 2
		gridLayout.CellSize = UDim2.new(0.5, -5, 0, 190)
		details.Size = UDim2.fromScale(1, 1)
		details.Position = UDim2.fromScale(0, 0)
		details.AnchorPoint = Vector2.zero
		details.Back.Visible = detailOpenOnMobile
		details.Visible = detailOpenOnMobile
		gridContainer.Visible = not detailOpenOnMobile
	else
		window.Size = width < 980 and UDim2.fromScale(0.93, 0.88) or UDim2.fromScale(0.88, 0.86)
		gridLayout.FillDirectionMaxCells = width < 1050 and 2 or 2
		gridLayout.CellSize = UDim2.new(0.5, -5, 0, 190)
		details.AnchorPoint = Vector2.new(1, 0)
		details.Position = UDim2.new(1, 0, 0, 0)
		details.Size = UDim2.new(width < 980 and 0.39 or 0.35, -1, 1, 0)
		details.Visible = true
		details.Back.Visible = false
		gridContainer.Visible = true
	end
end

local function refreshState()
	local success, result = pcall(function()
		return getStateRemote:InvokeServer()
	end)
	if success and type(result) == "table" then
		playerState = result
		updateCurrencyDisplay()
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
		if isMobile then
			return
		end
		local border = card:FindFirstChild("Border")
		if border and border:IsA("UIStroke") and selectedId ~= getVisibleItems()[index].Id then
			tween(card, 0.1, {BackgroundColor3 = Color3.fromRGB(26, 33, 41)})
		end
	end)

	selectButton.MouseLeave:Connect(function()
		if isMobile then
			return
		end
		local visible = getVisibleItems()
		local item = visible[index]
		if item then
			updateCard(card, item, item.Id == selectedId)
		end
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
	gridContainer.Visible = true
end)

details.Purchase.Activated:Connect(function()
	local id = selectedId
	if not id or not details.Purchase:GetAttribute("CanPurchase") then
		return
	end
	local item = items[id]
	if item then
		showModal(item)
	end
end)

modal.Cancel.Activated:Connect(hideModal)
modal.Confirm.Activated:Connect(function()
	local id = modalItemId
	if not id then
		return
	end

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
		if type(result.State) == "table" then
			playerState = result.State
		end
		updateCurrencyDisplay()
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
