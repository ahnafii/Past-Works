--!strict

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("ShopGui") :: ScreenGui
local overlay = gui:WaitForChild("Overlay") :: Frame
local window = overlay:WaitForChild("Window") :: Frame
local closeButton = window:WaitForChild("Header"):WaitForChild("Close") :: TextButton

-- This script only controls prebuilt GUI instances. The hierarchy itself is installed
-- by ShopSystem/CommandBar/CreateShopGUI.lua from Roblox Studio's Command Bar.
local launcher = gui:FindFirstChild("ShopToggle") :: TextButton?

local function setOpen(open: boolean)
	if open then
		gui.Enabled = true
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
		}
		tween.Completed:Once(function()
			gui.Enabled = false
		end)
		tween:Play()
	end
end

if launcher then
	launcher.Activated:Connect(function()
		setOpen(not gui.Enabled)
	end)
end

closeButton.Activated:Connect(function()
	setOpen(false)
end)

-- Preserve the familiar keyboard escape shortcut without requiring a second GUI hierarchy.
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Escape and gui.Enabled then
		setOpen(false)
	end
end)
