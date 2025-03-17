local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PromptModule = {}

local Templates = ReplicatedStorage.Interactions.Base
local HighLightTemplate = Templates:FindFirstChild("Highlight")
local PressingBillboardTemplate = Templates:FindFirstChild("PressBillboard")

function PromptModule.CreatePrompt(config)
	assert(config.HighlightObject, "Config must include HighlightObject")
	assert(config.ProxyPrompt, "Config must include ProxyPrompt")

	local prompt = {}
	prompt.HighlightObject = config.HighlightObject
	prompt.ProxyPrompt = config.ProxyPrompt
	prompt.Model = config.Model or nil
	prompt.DisplayName = config.DisplayName or nil
	prompt.Interaction = config.Interaction
	prompt.PromptShownFunction = config.PromptShownFunction
	prompt.PromptHideFunction = config.PromptHideFunction
	prompt.CanInteract = true
	prompt.Tween = nil
	prompt.CopiesConnection = nil

	local highlightParticle = HighLightTemplate and HighLightTemplate:Clone()
	local pressingBillboard = PressingBillboardTemplate and PressingBillboardTemplate:Clone()

	if pressingBillboard then
		pressingBillboard.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end

	prompt.HighlightParticle = highlightParticle
	prompt.PressingBillboard = pressingBillboard

	function prompt:CreateHighlight()
		if self.HighlightObject and self.PressingBillboard and self.HighlightParticle then
			if self.Model then
				local price = self.Model:GetAttribute("Price")
				if price then
					self.PressingBillboard.Button.Shop.Price.Text = "$ " .. tostring(price)
					self.PressingBillboard.Button.Shop.Visible = true
				else
					self.PressingBillboard.Button.Shop.Visible = false
				end

				local maxStack = self.Model:GetAttribute("MaxStack")
				local copies = self.Model:GetAttribute("Copies")
				if maxStack and copies then
					self.PressingBillboard.Button.Remaining.Copies.Text = "x" .. tostring(copies)
					self.PressingBillboard.Button.Remaining.Visible = true
					self.CopiesConnection = self.Model:GetAttributeChangedSignal("Copies"):Connect(function()
						self.PressingBillboard.Button.Remaining.Copies.Text = "x" .. tostring(self.Model:GetAttribute("Copies"))
					end)
				else
					self.PressingBillboard.Button.Remaining.Visible = false
				end
			end

			if self.DisplayName then
				self.PressingBillboard.Button.Top.TextLabel.Text = self.DisplayName
				self.PressingBillboard.Button.Top.TextLabel.Visible = true
			else
				self.PressingBillboard.Button.Top.TextLabel.Visible = false
			end

			local textLabel = self.PressingBillboard.Button.Top.TextLabel
			textLabel.MaxVisibleGraphemes = 0
			local tween = TweenService:Create(textLabel, TweenInfo.new(0.2), {MaxVisibleGraphemes = #textLabel.Text})
			tween:Play()

			self.PressingBillboard.Button.Top.Interact.IconInner.UIGradient.Offset = Vector2.new(0, 0.4)

			self.PressingBillboard.Adornee = self.HighlightObject
			self.HighlightParticle.Adornee = self.HighlightObject
			self.HighlightParticle.Enabled = true
			self.PressingBillboard.Enabled = true
		end
	end

	function prompt:RemoveHighlight()
		if self.HighlightParticle and self.HighlightParticle.Adornee == self.HighlightObject then
			if self.Tween then
				self.Tween:Cancel()
			end
			if self.CopiesConnection then
				self.CopiesConnection:Disconnect()
				self.CopiesConnection = nil
			end
			self.HighlightParticle.Enabled = false
			self.HighlightParticle.Adornee = nil
			self.PressingBillboard.Enabled = false
			self.PressingBillboard.Adornee = nil
		end
	end

	prompt.ProxyPrompt.PromptShown:Connect(function()
		if prompt.PromptShownFunction then
			prompt.PromptShownFunction(prompt)
		end
		prompt:CreateHighlight()
	end)

	prompt.ProxyPrompt.PromptHidden:Connect(function()
		prompt:RemoveHighlight()
		if prompt.PromptHideFunction then
			prompt.PromptHideFunction(prompt)
		end
	end)

	prompt.ProxyPrompt.Triggered:Connect(function(player)
		prompt:RemoveHighlight()
		if prompt.Interaction then
			prompt.Interaction(player)
		else
			print("Prompt triggered by " .. player.Name)
		end
	end)

	return prompt
end

return PromptModule
