--!strict

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("ShopGui") :: ScreenGui
local overlay = gui:WaitForChild("Overlay") :: Frame
local window = overlay:WaitForChild("Window") :: Frame
local closeButton = window:WaitForChild("Header"):WaitForChild("Close") :: TextButton
local launcher = gui:WaitForChild("ShopToggle") :: TextButton

-- ShopGui itself stays enabled for the lifetime of the player so the launcher
-- remains available. Only the shop overlay is shown/hidden.
local function setOpen(open: boolean)
	gui.Enabled = true

	if open then
		overlay.Visible = true
		overlay.BackgroundTransparency = 1
		window.Position = UDim2.fromScale(0.5, 0.53)

		TweenService:Create(overlay, TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.28,
		}):Play()
		TweenService:Create(window, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(0.5, 0.5),
		}):Play()
	else
		TweenService:Create(overlay, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
		}):Play()

		local tween = TweenService:Create(window, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(0.5, 0.53),
		})

		tween.Completed:Once(function()
			-- Never disable ShopGui: doing so would also hide the launcher.
			gui.Enabled = true
			overlay.Visible = false
	end)
		tween:Play()
	end
end

-- The shop must start closed. This also makes the behaviour deterministic
-- when the GUI was reinstalled through the Command Bar.
gui.Enabled = true
overlay.Visible = false

launcher.Activated:Connect(function()
	setOpen(not overlay.Visible)
end)

closeButton.Activated:Connect(function()
	setOpen(false)
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Escape and overlay.Visible then
		setOpen(false)
	end
end)

-- ShopClient historically disables ShopGui after its own close animation.
-- Keep the ScreenGui alive so the separate launcher can always reopen it.
gui:GetPropertyChangedSignal("Enabled"):Connect(function()
	if not gui.Enabled then
		gui.Enabled = true
		overlay.Visible = false
	end
end)
