-- Define a virtual cache to store the custom modules
local CustomModules = {}

-- Load your decompiled / modified Toolbar script (Script 1) into the cache
CustomModules["ToolsModule"] = (function()
	local v0 = {};
	local l_TweenService_0 = game:GetService("TweenService");

	-- Ensure UI variables wait/resolve safely
	local mainGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main")
	v0.UI = mainGui:WaitForChild("BotFrame"):WaitForChild("ToolBar");
	v0.FollowUI = mainGui:WaitForChild("ToolbarFollow");
	v0.AuxUIs = mainGui:WaitForChild("Health"):WaitForChild("AuxItems");
	v0.UIWheel = mainGui:WaitForChild("InventoryWheel"):WaitForChild("Wheel");
	v0.UISounds = v0.UI.Parent.Parent:WaitForChild("UISounds");
	v0.UIWheelSize = v0.UIWheel.Size;
	v0.OpenTween = nil;
	v0.CloseTween = l_TweenService_0:Create(v0.UIWheel, TweenInfo.new(0.25), {
		Size = UDim2.new(0, 0, 0, 0)
	});
	v0.Main = nil;
	v0.List = {};
	v0.Classes = {};
	v0.AuxClasses = {};
	local v2 = {};
	local v3 = {};
	v0.CanEquip = true;
	v0.CurrentSelected = nil;
	v0.AlwaysFirsts = 0;
	v0.DropHeld = false;
	local v4 = true;
	v0.DisableWheel = false;

	v0.PopUp = function(v5, v6, v7)
		task.spawn(function()
			task.wait(math.random(0, 2) / 10);
			local v8 = script.PopUp:Clone();
			local v9 = UDim2.new(0, 70, 0, 50);
			v8.Image = v6;
			local l_ViewportSize_0 = game.Workspace.CurrentCamera.ViewportSize;
			v8.Parent = v0.Main.UI;
			v8.Position = UDim2.new(0, v5.X + math.random(-l_ViewportSize_0.X, l_ViewportSize_0.X) / 80, 0, v5.Y + math.random(-l_ViewportSize_0.Y * 2, l_ViewportSize_0.Y) / 80);
			local v11 = 0.2 + math.random(1, 2) / 10;
			game.TweenService:Create(v8, TweenInfo.new(v11), {
				Size = v9
			}):Play();
			task.wait(v11 + 0.3);
			local v12 = 0.4 + math.random(1, 5) / 40;
			local _ = v7.AbsolutePosition;
			game.TweenService:Create(v8, TweenInfo.new(v12), {
				Position = UDim2.new(0.03, 0, 0.8, 0), 
				Size = UDim2.new(0, 40, 0, 40)
			}):Play();
			game.Debris:AddItem(v8, v12 - 0.1);
			task.wait(v12 - 0.1);
		end);
	end;

	local function v17(v14)
		local v15 = 1;
		if v14 then
			v15 = 0.5;
		end;
		local v16 = l_TweenService_0:Create(v0.UIWheel.Parent, TweenInfo.new(0.25), {
			Transparency = v15
		});
		v0.UI.Visible = not v14;
		v0.UIWheel.Visible = v14;
		if not v0.Main.UseKeypad.InKeypad then
			game.UserInputService.MouseIconEnabled = v14;
		end;
		v16:Play();
	end;

	local function v21(v18, v19)
		v19 = v19 or 0;
		local v20 = v18:Clone();
		v20.Name = v20.Name .. "Cloned";
		v20.Parent = v18.Parent;
		v20.PlaybackSpeed = (v20:GetAttribute("BasePlaybackSpeed") or 1) + v19;
		v20.Ended:Once(function()
			v20:Destroy();
		end);
		v20:Play();
	end;

	v0.UnSelect = function(v22)
		if not v0.Classes[v0.CurrentSelected] then
			if v0.CurrentSelected ~= nil then
				warn("Class for " .. v0.CurrentSelected .. " does not exist.");
			end;
			return;
		else
			l_TweenService_0:Create(v0.CurrentSelected, TweenInfo.new(0.2), {
				Size = UDim2.new(0.8, 0, 0.8, 0)
			}):Play();
			if v0.CurrentSelected:FindFirstChild("frame") then
				v0.CurrentSelected.ItemName.Visible = false;
			end;
			if v22 then
				v0.CurrentSelected = nil;
				return;
			else
				v0.Unequip();
				return;
			end;
		end;
	end;

	v0.Unequip = function()
		if not v0.Classes[v0.CurrentSelected] then
			return;
		else
			v0.Classes[v0.CurrentSelected]:Unequip();
			v0.SetUpKeys({}, {});
			v0.CurrentSelected = nil;
			v0.Main.Character:SetAttribute("ToolName", "nil");
			v0.Main.Device.UI.Mobile.BaseControls.Use.Visible = false;
			v0.Main.Device.UI.PC.BaseControls.DropItem.Visible = false;
			v0.Main.Device.UI.PC.BaseControls.ChargeItem.Visible = false;
			v0.Main.Device.UI.Mobile.BaseControls.Batteries.Visible = false;
			v0.Main.Device.UI.Controller.BaseControls.ChargeItem.Visible = false;
			v0.Main.Device.UI.Controller.BaseControls.DropItem.Visible = false;
			v0.Main.Device.UI.PC.BaseControls.OpenWheel.Visible = false;
			v0.Main.Device.UI.Controller.BaseControls.OpenWheel.Visible = false;
			return;
		end;
	end;

	game.ReplicatedStorage.Events.ResetToolStatus.OnClientEvent:Connect(function()
		if v0.CurrentSelected then
			v0.UnSelect();
		end;
	end);

	local function v25(v23, v24)
		if not v0.CanEquip then
			return;
		elseif v0.Main.ToolOffhanding.OffhandedItem and v0.Main.ToolOffhanding.OffhandedItem == v0.Classes[v23] then
			return;
		else
			if v0.CurrentSelected then
				if v0.CurrentSelected == v23 then
					v0.UnSelect(v24);
					return;
				else
					v0.UnSelect(v24);
				end;
			end;
			v0.Main.Character:SetAttribute("ToolName", v23.Name);
			v0.CurrentSelected = v23;
			if typeof(v0.CurrentSelected) == "table" then

			end;
			l_TweenService_0:Create(v0.CurrentSelected, TweenInfo.new(0.2), {
				Size = UDim2.new(1, 0, 1, 0)
			}):Play();
			if v24 then
				return;
			else
				v0.Equip(v23);
				return;
			end;
		end;
	end;

	v0.Equip = function(v26, v27)
		if not v27 then
			game.ReplicatedStorage.Events.Equip:FireServer(v26.Name);
			v0.Classes[v26]:Equip();
		end;
		if v0.Classes[v26].CanUseOnMobile then
			v0.Main.Device.UI.Mobile.BaseControls.Use.Visible = true;
		end;
		if not v0.Classes[v26].NotDroppable then
			v0.Main.Device.UI.PC.BaseControls.DropItem.Visible = true;
			v0.Main.Device.UI.Controller.BaseControls.DropItem.Visible = true;
			if v4 then
				v4 = false;
				if v0.Main.Device.CurrentControls == "Mobile" then
					v0.Main.SubTitles.new("Press and hold an item's icon to drag it. Drag it in the middle to drop it.", 6):Show();
				end;
			end;
		end;
		if v0.Main.ToolsModule.ChargableItems[v26.Name] and v0.Main.Player.PlayerFolder.Batteries.Value > 0 then
			v0.Main.Device.UI.PC.BaseControls.ChargeItem.Visible = true;
			v0.Main.Device.UI.Mobile.BaseControls.Batteries.Visible = true;
			v0.Main.Device.UI.Controller.BaseControls.ChargeItem.Visible = true;
		end;
		if v0.Main.Device.UI.Mobile.BaseControls.Batteries.Visible then
			v0.Main.Device.UI.Mobile.BaseControls.BindKey1.Position = UDim2.new(0.481, 0, -1.413, 0);
		else
			v0.Main.Device.UI.Mobile.BaseControls.BindKey1.Position = UDim2.new(0.481, 0, -0.627, 0);
		end;
		v26.ItemName.Visible = true;
		if not v0.Main.IsGhost then
			v0.Main.Device.UI.PC.BaseControls.OpenWheel.Visible = true;
			v0.Main.Device.UI.Controller.BaseControls.OpenWheel.Visible = true;
		end;
	end;

	v0.Select = function(...)
		v25(...);
	end;

	local function v43()
		v0.List = {};
		for _, v40 in pairs(v0.UI:GetChildren()) do
			if v40:IsA("ImageButton") then
				table.insert(v0.List, v40);
			end;
		end;
		table.sort(v0.List, function(v41, v42)
			return v41.LayoutOrder < v42.LayoutOrder;
		end);
	end;

	local function v53(v49)
		local v50 = nil;
		for _, v52 in pairs(v0.UIWheel:GetChildren()) do
			if v52.Name == tostring(v49.LayoutOrder) then
				return v52;
			end;
		end;
		return v50;
	end;

	local function v61(v54, v55)
		local v56 = nil;
		for v57 = v54 or 1, v55 or 10 do
			local v58 = nil;
			for _, v60 in pairs(v0.List) do
				if v60.LayoutOrder == v57 then
					v58 = v60;
					break;
				end;
			end;
			if not v58 then
				return v57;
			end;
		end;
		return v56;
	end;

	local function v62(v63, v64, v65)
		local l_FirstChild_0 = v0.UIWheel:FindFirstChild(v63.LayoutOrder - v0.AlwaysFirsts);
		if l_FirstChild_0 then
			l_FirstChild_0.Icon.Image = "";
			l_FirstChild_0.Stack.Visible = false;
			l_FirstChild_0.Bar.Visible = false;
		end;
		if v64 == 10 then
			v63.Number.TextLabel.Text = 0;
		else
			v63.Number.TextLabel.Text = v64;
		end;
		if v65 then
			local v67 = nil;
			for _, v69 in pairs(v0.List) do
				if v69.LayoutOrder == v64 then
					v67 = v69;
					break;
				end;
			end;
			local l_v67_0 = v67;
			if l_v67_0 then
				v62(l_v67_0, v63.LayoutOrder);
			end;
		end;
		v63.LayoutOrder = v64;
		local l_FirstChild_1 = v0.UIWheel:FindFirstChild(v64 - v0.AlwaysFirsts);
		if l_FirstChild_1 then
			l_FirstChild_1.Icon.Image = v63.ImageLabel.Image;
			if v63.Stack.Visible then
				l_FirstChild_1.Stack.Visible = true;
				l_FirstChild_1.Stack.Text = v63.Stack.Text;
			end;
			if v63.Bar.Visible then
				l_FirstChild_1.Bar.Visible = true;
				l_FirstChild_1.Bar.Frame.Size = v63.Bar.Frame.Size;
			end;
		end;
	end;

	local function v81(v72)
		local v73 = {};
		for _, v75 in pairs(v0.List) do
			if v75:IsA("ImageButton") and v72 < v75.LayoutOrder then
				table.insert(v73, v75);
			end;
		end;
		table.sort(v73, function(v76, v77)
			return v76.LayoutOrder < v77.LayoutOrder;
		end);
		for _, v79 in pairs(v73) do
			local v80 = v61(v72);
			if v79.LayoutOrder >= v80 then
				v62(v79, v80);
			end;
		end;
	end;

	local function v89(v86)
		l_TweenService_0:Create(v86, TweenInfo.new(0.2), {
			Size = UDim2.new(1.2, 0, 1.2, 0)
		}):Play();
		for _, v88 in pairs(v0.List) do
			if v88 ~= v86 then
				v88.frame.ImageColor3 = Color3.fromRGB(140, 150, 153);
				v88.ImageLabel.ImageColor3 = Color3.fromRGB(140, 140, 140);
			end;
		end;
	end;

	local function v92()
		for _, v91 in pairs(v0.List) do
			v91.frame.ImageColor3 = Color3.fromRGB(59, 122, 181);
			v91.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255);
		end;
	end;

	v0.CreateUI = function(v93)
		local v94 = script.temp:Clone();
		v94.Name = v93.Name;
		local v95 = nil;
		v95 = if v93.Name:match("Ghost") then game.ReplicatedStorage.EquipableItems.GhostTool else game.ReplicatedStorage.EquipableItems:FindFirstChild(v93.Name);
		if not v95 then
			print("ERROR: Couldn't pickup the item ---", v93.Name);
		end;
		local v96 = v95:GetAttribute("MaxStack") or v95:GetAttribute("Uses");
		local l_v95_Attribute_0 = v95:GetAttribute("MaxCapacity");
		local l_v95_Attribute_1 = v95:GetAttribute("AutoSelect");
		local l_v95_Attribute_2 = v95:GetAttribute("Auxillary");
		local l_v95_Attribute_3 = v95:GetAttribute("AlwaysLast");
		local l_v95_Attribute_4 = v95:GetAttribute("AlwaysFirst");
		local l_v95_Attribute_5 = v95:GetAttribute("Admin");
		local l_v95_Attribute_6 = v95:GetAttribute("BigItem");
		local l_v95_Attribute_7 = v95:GetAttribute("UpdateName");
		if v96 then
			v94.Stack.Visible = true;
			v94.Stack.Text = "x" .. v93.Value;
			v93.Changed:Connect(function()
				v94.Stack.Text = "x" .. v93.Value;
				local v105 = v53(v94);
				if v105 then
					v105.Stack.Text = "x" .. v93.Value;
				end;
			end);
		elseif l_v95_Attribute_0 then
			v94.Bar.Visible = true;
			v94.Bar.Frame.Size = UDim2.new(v93.Value / l_v95_Attribute_0, 0, 1, 0);
			local v106 = v95:GetAttribute("DecreaseSpeed") or 0.6;
			local l_Value_0 = v93.Value;
			local l_v106_0 = v106;
			do
				local l_l_Value_0_0 = l_Value_0;
				v93.Changed:Connect(function()
					if l_l_Value_0_0 > v93.Value then
						l_TweenService_0:Create(v94.Bar.Frame, TweenInfo.new(0.6, Enum.EasingStyle.Linear), {
							Size = UDim2.new(v93.Value / l_v95_Attribute_0, 0, 1, 0)
						}):Play();
					else
						l_TweenService_0:Create(v94.Bar.Frame, TweenInfo.new(l_v106_0, Enum.EasingStyle.Linear), {
							Size = UDim2.new(v93.Value / l_v95_Attribute_0, 0, 1, 0)
						}):Play();
					end;
					local v110 = v53(v94);
					if v110 then
						if l_l_Value_0_0 > v93.Value then
							l_TweenService_0:Create(v110.Bar.Frame, TweenInfo.new(0.6, Enum.EasingStyle.Linear), {
								Size = UDim2.new(v93.Value / l_v95_Attribute_0, 0, 1, 0)
							}):Play();
						else
							l_TweenService_0:Create(v110.Bar.Frame, TweenInfo.new(l_v106_0, Enum.EasingStyle.Linear), {
								Size = UDim2.new(v93.Value / l_v95_Attribute_0, 0, 1, 0)
							}):Play();
						end;
					end;
					l_l_Value_0_0 = v93.Value;
				end);
			end;
		end;
		if l_v95_Attribute_2 then
			v94.frame.ImageColor3 = Color3.fromRGB(181, 46, 36);
			v94.Number.UIStroke.Color = Color3.fromRGB(227, 11, 11);
			v94:SetAttribute("Auxillary", true);
		end;
		if l_v95_Attribute_5 then
			v94.frame.ImageColor3 = Color3.fromRGB(218, 145, 0);
			v94.Number.UIStroke.Color = Color3.fromRGB(255, 170, 0);
			v94:SetAttribute("Admin", true);
		end;
		if l_v95_Attribute_3 then
			v94:SetAttribute("AlwaysLast", true);
		elseif l_v95_Attribute_4 then
			local l_v0_0 = v0;
			l_v0_0.AlwaysFirsts = l_v0_0.AlwaysFirsts + 1;
			v94:SetAttribute("AlwaysFirst", true);
		end;
		if l_v95_Attribute_6 then
			v94:SetAttribute("BigItem", true);
			v89(v94);
		end;
		local v112 = nil;
		v112 = if v93:GetAttribute("SkinName") and game.ReplicatedStorage.Icons.SkinIcons:FindFirstChild(v93.Name) and game.ReplicatedStorage.Icons.SkinIcons:FindFirstChild(v93.Name):FindFirstChild(v93:GetAttribute("SkinName")) then game.ReplicatedStorage.Icons.SkinIcons[v93.Name]:FindFirstChild(v93:GetAttribute("SkinName")) else game.ReplicatedStorage.Icons:FindFirstChild(v93.Name);
		if v93:GetAttribute("Icon") then
			v112 = game.ReplicatedStorage.Icons:FindFirstChild(v93:GetAttribute("Icon"));
		end;
		if v112:GetAttribute("RealName") then
			v94.ItemName.Text = v112:GetAttribute("RealName");
		end;
		if l_v95_Attribute_7 then
			v93.Changed:Connect(function()
				v94.ItemName.Text = tostring(v93.Value) .. " / " .. v93:GetAttribute("MaxAmmo");
			end);
			v93:GetAttributeChangedSignal("MaxAmmo"):Connect(function()
				v94.ItemName.Text = tostring(v93.Value) .. " / " .. v93:GetAttribute("MaxAmmo");
			end);
		end;
		v94.ImageLabel.Image = v112.Image;
		v94.Parent = v0.UI;
		v94.Activated:Connect(function()
			v25(v94);
		end);
		if v93:GetAttribute("SkinName") then
			v0.Classes[v94] = v0.Main.ToolsModule.new({
				v93.Name, 
				v93:GetAttribute("SkinName")
			}, {
				Humanoid = v0.Main.Humanoid, 
				Frame = v0.Main.SubTitles
			});
		else
			v0.Classes[v94] = v0.Main.ToolsModule.new(v93.Name, {
				Humanoid = v0.Main.Humanoid, 
				Frame = v0.Main.SubTitles
			});
		end;
		if v93.Name == "NormalKeyCard" or v93.Name == "InnerKeyCard" or v93.Name == "RidgeKeyCard" or v93.Name == "PasswordPaper" then
			if v93:GetAttribute("Icon") then
				local l_Image_0 = game.ReplicatedStorage.Icons:FindFirstChild(v93:GetAttribute("Icon")).Image;
				v0.AuxUIs[v93.Name].Icon.Image = l_Image_0;
			end;
			local l_Image_1 = v0.AuxUIs[v93.Name].Icon.Image;
			local v115, _ = game.Workspace.CurrentCamera:WorldToScreenPoint(game.Workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -1).Position);
			v0.PopUp(v115, l_Image_1, v0.AuxUIs[v93.Name]);
			v0.AuxUIs[v93.Name].Visible = true;
			v0.AuxClasses[v93.Name] = v0.Classes[v94];
			v94.Parent = nil;
			return;
		else
			v94.TouchLongPress:Connect(function(v117, v118)
				if v0.Main.IsGhost then
					return;
				else
					local v119 = v117[1];
					if v118 == Enum.UserInputState.Begin and v119 and not v0.DropHeld then
						v0.DropHeld = v94;
						local v120 = v94:Clone();
						v120.Parent = v0.FollowUI;
						v120.Position = UDim2.new(0, 0, 0, 0);
						v0.FollowUI.Visible = true;
						v94.Visible = false;
						local _ = v0.FollowUI.AbsoluteSize;
						return;
					else
						if v118 == Enum.UserInputState.End and v0.DropHeld then
							v62(v0.DropHeld, v94.LayoutOrder, true);
							v43();
						end;
						return;
					end;
				end;
			end);
			if l_v95_Attribute_4 then
				for _, v123 in pairs(v0.List) do
					v62(v123, v123.LayoutOrder + 1);
				end;
				v43();
				v62(v94, (v61()));
				v81(1);
			else
				v43();
				v62(v94, (v61()));
			end;
			local v124 = v53(v94);
			if v124 then
				if v96 then
					v124.Stack.Visible = true;
					v124.Stack.Text = "x" .. v93.Value;
				end;
				if l_v95_Attribute_0 then
					v124.Bar.Visible = true;
					v124.Bar.Frame.Size = UDim2.new(v93.Value / l_v95_Attribute_0, 0, 1, 0);
				end;
			end;
			if l_v95_Attribute_1 then
				v25(v94);
			end;
			if #v0.List == 5 then
				if v0.Main.Device.CurrentControls == "Mobile" then
					v0.UI.UISizeConstraint.MinSize = Vector2.new(50, 50);
					return;
				end;
			elseif #v0.List > 5 and v0.Main.Device.CurrentControls == "Mobile" then
				v0.UI.UISizeConstraint.MinSize = Vector2.new(40, 40);
			end;
			return;
		end;
	end;

	game.UserInputService.TouchLongPress:Connect(function(v125, v126, _)
		if v125[1] and v126 == Enum.UserInputState.Begin then
			v0.FollowUI.Position = UDim2.new(0, v125[1].X, 0, v125[1].Y + 36 + v0.FollowUI.AbsoluteSize.Y);
		end;
	end);

	game.UserInputService.TouchMoved:Connect(function(v128, _)
		if v0.DropHeld then
			local _ = v0.FollowUI.AbsoluteSize;
			v0.FollowUI.Position = UDim2.new(0, v128.Position.X, 0, v128.Position.Y + 36 + v0.FollowUI.AbsoluteSize.Y);
		end;
	end);

	game.UserInputService.TouchEnded:Connect(function(v131, _)
		if v0.DropHeld then
			if v131.Position.Y < v0.UI.Parent.AbsolutePosition.Y - v0.UI.Parent.AbsoluteSize.Y or v131.Position.Y < game.Players.LocalPlayer.PlayerGui.Main.AbsoluteSize.Y / 2 then
				if v0.Classes[v0.DropHeld].NotDroppable then
					return;
				else
					print("I drop");
					game.ReplicatedStorage.Events.DropItem:FireServer(v0.DropHeld.Name);
				end;
			end;
			v0.DropHeld.Visible = true;
			v0.FollowUI.Visible = false;
			local l_ImageButton_0 = v0.FollowUI:FindFirstChildOfClass("ImageButton");
			if l_ImageButton_0 then
				l_ImageButton_0:Destroy();
			end;
			task.wait(0.1);
			v0.DropHeld = nil;
		end;
	end);

	local function v140(v134)
		local v135 = nil;
		for v136, v137 in pairs(v0.List) do
			if v137.Name == v134.Name then
				table.remove(v0.List, v136);
				if v0.CurrentSelected == v137 then
					v0.UnSelect();
				end;
				if v137:GetAttribute("AlwaysFirst") then
					local l_v0_1 = v0;
					l_v0_1.AlwaysFirsts = l_v0_1.AlwaysFirsts - 1;
				else
					local l_FirstChild_2 = v0.UIWheel:FindFirstChild(v137.LayoutOrder - v0.AlwaysFirsts);
					if l_FirstChild_2 then
						l_FirstChild_2.Icon.Image = "";
						l_FirstChild_2.Bar.Visible = false;
						l_FirstChild_2.Stack.Visible = false;
					end;
				end;
				v135 = v137.LayoutOrder;
				if v137:GetAttribute("BigItem") then
					v92();
				end;
				v137:Destroy();
				break;
			end;
		end;
		if v134.Name == "NormalKeyCard" or v134.Name == "InnerKeyCard" or v134.Name == "RidgeKeyCard" or v134.Name == "PasswordPaper" then
			v0.AuxUIs[v134.Name].Visible = false;
			v0.AuxClasses[v134.Name] = nil;
			v43();
		else
			v43();
			if v0.Main.Data.GameSettings.AutoSortInv.Value then
				v81(v135);
			end;
		end;
		if #v0.List <= 4 then
			v0.UI.UISizeConstraint.MinSize = Vector2.new(70, 70);
			return;
		else
			if #v0.List <= 5 then
				v0.UI.UISizeConstraint.MinSize = Vector2.new(50, 50);
			end;
			return;
		end;
	end;

	local v141 = {
		[Enum.KeyCode.One] = 1, 
		[Enum.KeyCode.Two] = 2, 
		[Enum.KeyCode.Three] = 3, 
		[Enum.KeyCode.Four] = 4, 
		[Enum.KeyCode.Five] = 5, 
		[Enum.KeyCode.Six] = 6, 
		[Enum.KeyCode.Seven] = 7, 
		[Enum.KeyCode.Eight] = 8, 
		[Enum.KeyCode.Nine] = 9, 
		[Enum.KeyCode.Zero] = 0
	};
	v0.WheelOpen = false;

	v0.SetUpKeys = function(v142, v143)
		v2 = v142;
		for v144, _ in pairs(v3) do
			v0.Main.Device.UI.Mobile.BaseControls[v144].Visible = false;
			v0.Main.Device.UI.PC.BaseControls[v144].Visible = false;
			v0.Main.Device.UI.Controller.BaseControls[v144].Visible = false;
		end;
		v3 = v143;
		for v146, _ in pairs(v3) do
			v0.Main.Device.UI.Mobile.BaseControls[v146].Visible = true;
			v0.Main.Device.UI.PC.BaseControls[v146].Visible = true;
			v0.Main.Device.UI.Controller.BaseControls[v146].Visible = true;
		end;
	end;

	v0.init = function(v148)
		v0.Main = v148;
		v0.UIWheelSize = v0.UIWheel.Size;
		v0.OpenTween = l_TweenService_0:Create(v0.UIWheel, TweenInfo.new(0.25), {
			Size = v0.UIWheelSize
		});
		v0.UIWheel.Parent.Visible = true;
		v0.UIWheel.Visible = false;
		task.spawn(function()
			repeat
				task.wait();
			until v148.PlayerFolder;
			local l_Inventory_0 = v148.PlayerFolder:WaitForChild("Inventory");
			for _, v151 in pairs(l_Inventory_0:GetChildren()) do
				v0.CreateUI(v151);
			end;
			l_Inventory_0.ChildAdded:Connect(v0.CreateUI);
			l_Inventory_0.ChildRemoved:Connect(v140);
		end);
		game:GetService("UserInputService").InputBegan:Connect(function(v152, v153)
			if v153 then
				return;
			else
				local v154 = nil;
				if v152.KeyCode == Enum.KeyCode.ButtonR1 then
					if #v0.List == 0 then
						return;
					else
						v154 = (if not v0.CurrentSelected then v0.List[1] else v0.List[table.find(v0.List, v0.CurrentSelected) + 1]) or v0.List[1];
					end;
				end;
				if v152.KeyCode == Enum.KeyCode.ButtonL1 then
					if #v0.List == 0 then
						return;
					else
						v154 = (if not v0.CurrentSelected then v0.List[#v0.List - 1] else v0.List[table.find(v0.List, v0.CurrentSelected) - 1]) or v0.List[#v0.List];
					end;
				end;
				local v155 = v154 or v141[v152.KeyCode];
				if v155 then
					if type(v155) ~= "number" then
						v25(v155);
						return;
					else
						local v156 = nil;
						if v155 == 0 then
							local v157 = nil;
							for _, v159 in pairs(v0.List) do
								if v159.LayoutOrder == 10 then
									v157 = v159;
									break;
								end;
							end;
							v156 = v157;
						else
							local v160 = nil;
							for _, v162 in pairs(v0.List) do
								if v162.LayoutOrder == v155 then
									v160 = v162;
									break;
								end;
							end;
							v156 = v160;
						end;
						if v156 then
							v25(v156);
						end;
						return;
					end;
				elseif v152.UserInputType == Enum.UserInputType.MouseButton1 then
					if v148.Device.CurrentControls ~= "PC" then
						return;
					else
						if v0.CurrentSelected then
							v0.Classes[v0.CurrentSelected]:Activate();
						end;
						return;
					end;
				else
					if v152.KeyCode == Enum.KeyCode.ButtonR2 then
						if v148.Device.CurrentControls ~= "Controller" then
							return;
						elseif v0.CurrentSelected then
							v0.Classes[v0.CurrentSelected]:Activate();
						end;
					end;
					local v163 = v2[v152.UserInputType] or v2[v152.KeyCode];
					if v163 and v0.CurrentSelected then
						v0.Classes[v0.CurrentSelected]:Activate(v163);
					end;
					if v152.KeyCode == Enum.KeyCode.G or v152.KeyCode == Enum.KeyCode.ButtonB then
						if v0.CurrentSelected then
							if v0.Classes[v0.CurrentSelected].NotDroppable then
								return;
							else
								print("I drop");
								game.ReplicatedStorage.Events.DropItem:FireServer(v0.CurrentSelected.Name);
								return;
							end;
						end;
					elseif v152.KeyCode == Enum.KeyCode.R or v152.KeyCode == Enum.KeyCode.ButtonY then
						if v0.CurrentSelected then
							v0.Main.ToolsModule.Charge();
							return;
						end;
					elseif v152.KeyCode == Enum.KeyCode.Q or v152.KeyCode == Enum.KeyCode.ButtonR3 then
						if v0.DisableWheel and not v0.WheelOpen then
							return;
						elseif v0.Main.IsGhost then
							return;
						else
							v17(not v0.WheelOpen);
							v0.WheelOpen = not v0.WheelOpen;
						end;
					end;
					return;
				end;
			end;
		end);
		game:GetService("UserInputService").InputChanged:Connect(function(v164, v165)
			if v165 or v164.UserInputType ~= Enum.UserInputType.MouseWheel then
				return;
			else
				local v166 = v164.Position.Z * -1;
				if #v0.List == 0 then
					return;
				else
					local v167 = nil;
					v167 = if v166 > 0 then (if not v0.CurrentSelected then v0.List[1] else v0.List[table.find(v0.List, v0.CurrentSelected) + v166]) or v0.List[1] else (if not v0.CurrentSelected then v0.List[#v0.List - 1] else v0.List[table.find(v0.List, v0.CurrentSelected) + v166]) or v0.List[#v0.List];
					if type(v167) ~= "number" then
						v25(v167);
						return;
					else
						local v168 = nil;
						if v167 == 0 then
							local v169 = nil;
							for _, v171 in pairs(v0.List) do
								if v171.LayoutOrder == 10 then
									v169 = v171;
									break;
								end;
							end;
							v168 = v169;
						else
							local l_v167_0 = v167;
							local v173 = nil;
							for _, v175 in pairs(v0.List) do
								if v175.LayoutOrder == l_v167_0 then
									v173 = v175;
									break;
								end;
							end;
							v168 = v173;
						end;
						if v168 then
							v25(v168);
						end;
						return;
					end;
				end;
			end;
		end);
		for v176, v177 in pairs((v0.UIWheel:GetChildren())) do
			if v177:IsA("TextButton") or tonumber(v177.Name) then
				v177.MouseEnter:Connect(function()
					v21(v0.UISounds.Hover, (v176 - 1) * 0.05);
				end);
				v177.MouseButton1Down:Connect(function()
					v21(v0.UISounds.Click, (v176 - 1) * 0.05);
					v0.UIWheel.Drag.Icon.Image = v177.Icon.Image;
					v0.SelectedWheelOption = tonumber(v177.Name) + v0.AlwaysFirsts;
				end);
				v177.MouseButton1Up:Connect(function()
					if not v0.WheelOpen then
						return;
					elseif not v0.SelectedWheelOption then
						return;
					elseif v0.UIWheel.Drag.Icon.Image == "" then
						return;
					else
						local l_SelectedWheelOption_0 = v0.SelectedWheelOption;
						local v179 = nil;
						for _, v181 in pairs(v0.List) do
							if v181.LayoutOrder == l_SelectedWheelOption_0 then
								v179 = v181;
								break;
							end;
						end;
						if v179 then
							local l_v62_0 = v62;
							v179 = v0.SelectedWheelOption;
							local v183 = nil;
							for _, v185 in pairs(v0.List) do
								if v185.LayoutOrder == v179 then
									v183 = v185;
									break;
								end;
							end;
							l_v62_0(v183, tonumber(v177.Name) + v0.AlwaysFirsts, true);
							v43();
						end;
						v21(v0.UISounds.Close, (v176 - 1) * 0.05);
						v0.UIWheel.Drag.Icon.Image = "";
						v0.SelectedWheelOption = nil;
						return;
					end;
				end);
			end;
		end;
		game.UserInputService.InputEnded:Connect(function(v186)
			if v186.UserInputType == Enum.UserInputType.MouseButton1 then
				v0.UIWheel.Drag.Icon.Image = "";
			end;
		end);
		v0.UIWheel.YBattery.MouseEnter:Connect(function()
			v0.UISounds.Hover:Play();
		end);
		v0.UIWheel.YBattery.MouseButton1Down:Connect(function()
			v0.UISounds.Click:Play();
			print("I drop")
		end);
		v0.UIWheel.YBattery.MouseButton1Up:Connect(function()
			if v0.WheelOpen then
				v0.UIWheel.Drag.Icon.Image = "";
				v0.SelectedWheelOption = nil;
			end;
		end);
		game.UserInputService.InputEnded:Connect(function(v187, v188)
			if v188 then
				return;
			elseif not v0.WheelOpen then
				return;
			else
				if v187.UserInputType == Enum.UserInputType.MouseButton1 then
					v0.UIWheel.Drag.Icon.Image = "";
					v0.SelectedWheelOption = nil;
				end;
				return;
			end;
		end);
		game["Run Service"].RenderStepped:Connect(function(_)
			local l_MouseLocation_0 = game.UserInputService:GetMouseLocation();
			local l_AbsoluteSize_2 = v0.UIWheel.Drag.AbsoluteSize;
			v0.UIWheel.Drag.Position = UDim2.new(0, l_MouseLocation_0.X - v0.UIWheel.AbsolutePosition.X - l_AbsoluteSize_2.X / 2, 0, l_MouseLocation_0.Y - v0.UIWheel.AbsolutePosition.Y - l_AbsoluteSize_2.Y / 2);
		end);
		v0.Main.Device.UI.Mobile.BaseControls.Batteries.Activated:Connect(function()
			if v0.CurrentSelected then
				v0.Main.ToolsModule.Charge();
			end;
		end);
		v148.Device.UI.Mobile.BaseControls.Use.Activated:Connect(function()
			if v0.CurrentSelected then
				v0.Classes[v0.CurrentSelected]:Activate();
			end;
		end);
		v148.Device.UI.Mobile.BaseControls.BindKey1.Activated:Connect(function()
			if v0.CurrentSelected then
				local l_BindKey1_0 = v3.BindKey1;
				if not l_BindKey1_0 then
					return;
				else
					v0.Classes[v0.CurrentSelected]:Activate(l_BindKey1_0);
				end;
			end;
		end);
		v148.Device.UI.Mobile.BaseControls.BindKey2.Activated:Connect(function()
			if v0.CurrentSelected then
				local l_BindKey2_0 = v3.BindKey2;
				if not l_BindKey2_0 then
					return;
				else
					v0.Classes[v0.CurrentSelected]:Activate(l_BindKey2_0);
				end;
			end;
		end);
		game.ReplicatedStorage.Events.SwapItem.OnClientEvent:Connect(function(v194)
			local l_FirstChild_3 = v0.UI:FindFirstChild(v194.Name);
			if l_FirstChild_3 then
				game.TweenService:Create(l_FirstChild_3.swap, TweenInfo.new(0.2), {
					ImageTransparency = 0
				}):Play();
				game.TweenService:Create(l_FirstChild_3.swap, TweenInfo.new(0.4), {
					Rotation = l_FirstChild_3.swap.Rotation + 90
				}):Play();
				if v0.CurrentSelected == l_FirstChild_3 then
					v25(l_FirstChild_3, true);
					task.wait(0.1);
					v25(l_FirstChild_3, true);
				else
					task.wait(0.1);
				end;
				task.wait(0.3);
				if l_FirstChild_3:FindFirstChild("swap") then
					game.TweenService:Create(l_FirstChild_3.swap, TweenInfo.new(0.4), {
						ImageTransparency = 1, 
						Rotation = l_FirstChild_3.swap.Rotation + 90
					}):Play();
				end;
			end;
		end);
	end;
	return v0;
end)()

-- Hook the global require function so it detours automatically
local rawRequire = require
local requireDetour = function(target)
	if typeof(target) == "Instance" and target:IsA("ModuleScript") then
		if CustomModules[target.Name] then
			return CustomModules[target.Name]
		end
	end
	return rawRequire(target)
end

-- Attempt standard hook function configuration, fallback to environment global detour if hookfunction is absent.
if hookfunction then
	pcall(function()
		hookfunction(require, requireDetour)
	end)
else
	getgenv().require = requireDetour
end
