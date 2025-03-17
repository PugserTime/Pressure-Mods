-- Wait for the PlayerGui to load
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Main")
local Client = Main:WaitForChild("Client")
local MainClient = Client:WaitForChild("MainClient")
local SubtitleModule = require(MainClient:WaitForChild("SubTitles"))
local LocalEntitiesModule = require(MainClient:WaitForChild("LocalEntities"))
local BaldiModule = require(PlayerGui.Main.Client.MainClient.Baldi)
local SpecialLocalEffects = require(PlayerGui.Main.Client.MainClient.SpecialLocalEffects)

---------------------------------------------------------
-- Patch Function: Force IsEvilMode to true in PathFindToPlayer
---------------------------------------------------------
local patched = false
local function patchEvilModePandemonium()
	if patched then return end
	patched = true

	if type(getgc) == "function" then
		local function printTable(t, indent, seen)
			indent = indent or ""
			seen = seen or {}
			if seen[t] then
				print(indent .. tostring(t) .. " (already printed)")
				return
			end
			seen[t] = true
			for key, value in pairs(t) do
				if type(value) == "table" then
					print(indent .. tostring(key) .. ": (table)")
					printTable(value, indent .. "  ", seen)
				else
					print(indent .. tostring(key) .. ": " .. tostring(value))
				end
			end
		end

		local function patchPathFindToPlayer(targetTable)
			local originalFunc = targetTable.PathFindToPlayer
			if type(originalFunc) == "function" then
				targetTable.PathFindToPlayer = function(self, ...)
					if self.IsEvilMode ~= true then
						self.IsEvilMode = true
						print("[Patch] IsEvilMode forced to true for the following table:")
						printTable(self)
					end
					return originalFunc(self, ...)
				end
				print("[Patch] Successfully patched PathFindToPlayer in table:")
				printTable(targetTable)
			end
		end

		local success, pandemoniumModule = pcall(function()
			return require(game:GetService("Players").LocalPlayer.PlayerGui.Main.Client.MainClient.LocalEntities.Pandemonium)
		end)
		if success and pandemoniumModule then
			patchPathFindToPlayer(pandemoniumModule)
		end
	else
		print("Your executor is not supported for pandemonium, pandemonium will not have the evilmode variant")
	end
end

local function PandemoniumStop() -- I don't even know if this works :)
	task.spawn(function()
		while true do
			if table.find(BaldiModule.Main.LocalEntities.ActiveEntities, "Pandemonium") then
				BaldiModule.Frozen = true
			else
				BaldiModule.Frozen = false
			end
			task.wait(1)  -- Check every second (adjust as needed)
		end
	end)
end

---------------------------------------------------------
-- End Patch Function
---------------------------------------------------------

-- Function to send subtitles
local function SendSubtitle(message, duration)
	duration = duration or 3
	SubtitleModule.new(message, duration):Show()
end

local roomsFolder = workspace:FindFirstChild("Rooms")
if not roomsFolder or not roomsFolder:FindFirstChild("Start") then
	SendSubtitle("❌ Evil Button Mode failed: 'Start' room missing.", 5)
	return
end

local function CrystalSpawn()
	CollectionService:GetInstanceAddedSignal("HasCrystal"):Connect(function(instance)
		if instance == Player then
			local crystalRoom = workspace.Rooms:FindFirstChild("CrystalRoom")
			local RidgeBaldiSpawner = crystalRoom and crystalRoom:FindFirstChild("BaldiSpawner") or workspace.Rooms:FindFirstChild("Start"):FindFirstChild("BaldiSpawner")
			if RidgeBaldiSpawner then
				BaldiModule.new("GrabCrystal", RidgeBaldiSpawner)
			else
				warn("No BaldiSpawner found in CrystalRoom or Start room.")
			end
		end
	end)
end

local function applyEvilRidgeNeonEffect(meshPart)
	SpecialLocalEffects.Effects.EvilRidgeNeon(meshPart)
end

local function processLight(meshPart)
	if not meshPart:IsA("MeshPart") then
		return
	end
	task.delay(0.2, function()
		local lightObject = meshPart:FindFirstChild("Light")
		if lightObject and (lightObject:IsA("SpotLight") or lightObject:IsA("PointLight")) then
			if not meshPart:GetAttribute("ActiveLoop") then
				meshPart:SetAttribute("ActiveLoop", true)
				meshPart.Material = Enum.Material.Glass
				lightObject.Color = Color3.fromRGB(138, 162, 177)
				meshPart:SetAttribute("OriginalColor", lightObject.Color)

				local function handleLightEffect()
					if lightObject.Enabled then
						applyEvilRidgeNeonEffect(meshPart)
					end
				end

				lightObject:GetPropertyChangedSignal("Enabled"):Connect(function()
					if lightObject.Enabled then
						local intervalTime = math.random(3, 6) / 10
						task.wait(intervalTime)
						handleLightEffect()
					end
				end)

				task.spawn(function()
					while true do
						local intervalTime = math.random(120, 135) / 10
						task.wait(intervalTime)
						if lightObject.Enabled then
							applyEvilRidgeNeonEffect(meshPart)
						end
					end
				end)
			end
		end
	end)
end

local function processRoom(room)
	if room:GetAttribute("RoomFamily") == "Ridge" or room.Name == "Start" then
		return
	end

	local lightsFolder = room:FindFirstChild("Lights")
	if lightsFolder then
		task.delay(0.2, function()
			for _, child in ipairs(lightsFolder:GetChildren()) do
				processLight(child)
			end
		end)
		lightsFolder.ChildAdded:Connect(function(child)
			task.delay(0.2, function()
				processLight(child)
			end)
		end)
	else
		warn("Room " .. room.Name .. " does not have a Lights folder!")
	end
end

local function DisableLightsInStartRoom()
	local startRoom = workspace.Rooms:FindFirstChild("Start")
	if startRoom then
		local lightsFolder = startRoom:FindFirstChild("Lights")
		if lightsFolder then
			for _, descendant in ipairs(lightsFolder:GetDescendants()) do
				if descendant:IsA("PointLight") or descendant:IsA("SpotLight") then
					if descendant.Enabled then
						descendant.Enabled = false
						descendant.Parent.Material = Enum.Material.Glass
					end
				end
			end

			local glassBreakSounds = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("GlassBreak"):GetChildren()
			for _, light in ipairs(lightsFolder:GetChildren()) do
				if light:IsA("MeshPart") then
					local lightObject = light:FindFirstChild("Light")
					if lightObject and (lightObject:IsA("SpotLight") or lightObject:IsA("PointLight")) then
						task.delay(math.random(0.5, 0.8), function()
							local randomSound = glassBreakSounds[math.random(1, #glassBreakSounds)]
							local glassSound = randomSound:Clone()
							glassSound.Parent = light
							glassSound:Play()
							glassSound.Ended:Connect(function()
								glassSound:Destroy()
							end)
						end)
					end
				end
			end
		end
	end
end

local EvilButtonModelSpawner = Instance.new("Model")
EvilButtonModelSpawner.Name = "EvilButton"
EvilButtonModelSpawner.WorldPivot = CFrame.new(-111.8711166381836, 1332.088623046875, -292.73516845703125, 0, 0, -0.9999998807907104, 0, 1, 0, 1, 0, 0)

local BaldiSpawner = Instance.new("Part")
BaldiSpawner.Name = "BaldiSpawner"
BaldiSpawner.CFrame = CFrame.new(-111.8711166381836, 1332.0885009765625, -292.73516845703125, 0, 0, -0.9999996423721313, 0, 1, 0, 1, 0, 0)
BaldiSpawner.BottomSurface = Enum.SurfaceType.Smooth
BaldiSpawner.Transparency = 1
BaldiSpawner.TopSurface = Enum.SurfaceType.Smooth
BaldiSpawner.Color = Color3.fromRGB(107, 106, 108)
BaldiSpawner.Material = Enum.Material.Metal
BaldiSpawner.Size = Vector3.new(1.9814643859863281, 3.1814422607421875, 2)
BaldiSpawner.Anchored = true
BaldiSpawner.Parent = EvilButtonModelSpawner

local EvilButtonBottom = Instance.new("Part")
EvilButtonBottom.Name = "EvilButtonBottom"
EvilButtonBottom.CFrame = CFrame.new(-80.12100219726562, 1330.433349609375, -309.260009765625, 0, 0, -1, 0, 1, 0, 1, 0, 0)
EvilButtonBottom.BottomSurface = Enum.SurfaceType.Smooth
EvilButtonBottom.TopSurface = Enum.SurfaceType.Smooth
EvilButtonBottom.Color = Color3.fromRGB(107, 106, 108)
EvilButtonBottom.Material = Enum.Material.Metal
EvilButtonBottom.Size = Vector3.new(1.9814643859863281, 3.1814422607421875, 2)
EvilButtonBottom.Anchored = true

local EvilButton = Instance.new("Part")
EvilButton.Name = "EvilButton"
EvilButton.CFrame = CFrame.new(-80.16297912597656, 1332.1798095703125, -309.3112487792969, 0, -1, 0, 1, 0, 0, 0, 0, 1)
EvilButton.BottomSurface = Enum.SurfaceType.Smooth
EvilButton.TopSurface = Enum.SurfaceType.Smooth
EvilButton.Color = Color3.fromRGB(255, 0, 0)
EvilButton.Material = Enum.Material.SmoothPlastic
EvilButton.Size = Vector3.new(0.31137847900390625, 1.5839531421661377, 1.5839531421661377)
EvilButton.Anchored = true
EvilButton.Shape = Enum.PartType.Cylinder
--EvilButton:SetAttribute("InteractionType", "EvilButton")
--EvilButton:SetAttribute("ClientUse", true)

local button = Instance.new("Sound")
button.Name = "button"
button.EmitterSize = 25
button.RollOffMaxDistance = 50
button.Volume = 0.75
button.MinDistance = 25
button.MaxDistance = 50
button.RollOffMinDistance = 25
button.SoundId = "rbxassetid://12221967"
button.Parent = EvilButton

local ProximityPrompt = Instance.new("ProximityPrompt")
ProximityPrompt.UIOffset = Vector2.new(0, 0.800000011920929)
ProximityPrompt.MaxActivationDistance = 7
ProximityPrompt.ActionText = "Press Button"
 ProximityPrompt.Style = Enum.ProximityPromptStyle.Custom
ProximityPrompt.Parent = EvilButton

local BillboardGui = Instance.new("BillboardGui")
BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
BillboardGui.Active = true
BillboardGui.LightInfluence = 1
BillboardGui.AlwaysOnTop = true
BillboardGui.Size = UDim2.new(15, 0, 5, 0)
BillboardGui.MaxDistance = 22
BillboardGui.StudsOffset = Vector3.new(0, 2, 0)
BillboardGui.Parent = EvilButton

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(1, 0, 1, 0)
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BackgroundTransparency = 1
Frame.BorderSizePixel = 0
Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Frame.Parent = BillboardGui

local mid = Instance.new("TextLabel")
mid.Name = "mid"
mid.Visible = false
mid.AnchorPoint = Vector2.new(0.5, 0.5)
mid.Size = UDim2.new(0.575, 0, 0.1, 0)
mid.BorderColor3 = Color3.fromRGB(0, 0, 0)
mid.BackgroundTransparency = 1
mid.Position = UDim2.new(0.5, 0, 0.7, 0)
mid.BorderSizePixel = 0
mid.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mid.FontSize = Enum.FontSize.Size14
mid.TextStrokeTransparency = 0
mid.TextSize = 14
mid.TextColor3 = Color3.fromRGB(255, 255, 255)
mid.Text = "VOTED TO PLAY:"
mid.TextWrapped = true
mid.TextWrap = true
mid.Font = Enum.Font.Michroma
mid.TextScaled = true
mid.Parent = Frame

local skipped = Instance.new("TextLabel")
skipped.Name = "skipped"
skipped.Visible = false
skipped.AnchorPoint = Vector2.new(0.5, 0.5)
skipped.Size = UDim2.new(0.575, 0, 0.1, 0)
skipped.BorderColor3 = Color3.fromRGB(0, 0, 0)
skipped.BackgroundTransparency = 1
skipped.Position = UDim2.new(0.5, 0, 0.8, 0)
skipped.BorderSizePixel = 0
skipped.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
skipped.FontSize = Enum.FontSize.Size14
skipped.TextStrokeTransparency = 0
skipped.TextSize = 14
skipped.TextColor3 = Color3.fromRGB(255, 255, 255)
skipped.Text = "3/4"
skipped.TextWrapped = true
skipped.TextWrap = true
skipped.Font = Enum.Font.Michroma
skipped.TextScaled = true
skipped.Parent = Frame

EvilButton.Parent = workspace.Rooms.Start.Interactables

EvilButtonBottom.Parent = workspace.Rooms.Start

EvilButtonModelSpawner.Parent = workspace.Rooms:WaitForChild("Start")

local function StartloopBaldi()
	task.spawn(function()
		while true do
			local zonePointer = BaldiModule.Main.Zones.RoomPointer
			if zonePointer and zonePointer.Value then
				if zonePointer.Value.Name == "SearchlightsEncounter" then
					BaldiModule.new("Encounter")
					break
				elseif zonePointer.Value.Name == "SearchlightsStart" then
					zonePointer.Value.Name = "BaldiStart"
					break
				end
			end
			task.wait(0.1)
		end
	end)
end


local function onProximityPromptTriggered(player)
	ProximityPrompt:Destroy()

	patchEvilModePandemonium()
	BaldiModule.Distance = 8 -- Nerfed version cuz he is too fast normally
	BaldiModule.SchoolhouseDistance = 9 -- Nerfed version cuz he is too fast normally
	CrystalSpawn()
	StartloopBaldi()
	SendSubtitle("<font color=\"rgb(210, 0, 0)\">" .. player.Name .. "</font> <font color=\"rgb(210, 0, 0)\">has pressed the evil button...</font>", 6)
	DisableLightsInStartRoom()
	PandemoniumStop()
	button:Play()
	workspace.PowerOut:Play()
	task.delay(5, function()
		BaldiModule.new("FirstSpawn", BaldiSpawner)
	end)

	CollectionService:AddTag(player, "EnragedShark")
	game.ReplicatedStorage.Events.PermanentEyefestation:FireServer(false)

	local ridgeIntro = workspace:FindFirstChild("RidgeIntro")
	ridgeIntro.SoundId = workspace.SchoolhouseIntro.SoundId
	print("Set RidgeIntro to SchoolhouseIntro")

	local ridgeLoop = ridgeIntro:FindFirstChild("RidgeLoop")
	ridgeLoop.SoundId = workspace.SchoolhouseIntro.SchoolhouseLoop.SoundId
	print("Set RidgeIntro to SchoolhouseLoop")

	local ridgeFadeout = ridgeLoop:FindFirstChild("RidgeFadeout")
	ridgeFadeout.SoundId = workspace.SchoolhouseIntro.SchoolhouseLoop.SoundId
	print("Set RidgeIntro to SchoolhouseEnd")

	for _, room in ipairs(workspace.Rooms:GetChildren()) do
		processRoom(room)
	end
	workspace.Rooms.ChildAdded:Connect(function(newRoom)
		local lightsFolder = newRoom:FindFirstChild("Lights") or newRoom:WaitForChild("Lights", 5)
		if lightsFolder then
			processRoom(newRoom)
			print("Processed new room: " .. newRoom.Name)
		else
			warn("New room " .. newRoom.Name .. " does not have a Lights folder!")
		end
	end)
end

local PromptModule

local function loadModuleWithLoadstring()
	local success, moduleCode = pcall(function()
		return game:HttpGet("https://pastebin.com/raw/pTyJXLpz")
	end)
	if success and moduleCode then
		local loadFunc, loadError = loadstring(moduleCode)
		if loadFunc then
			local execSuccess, result = pcall(loadFunc)
			if execSuccess then
				return result
			else
				warn("Error executing loaded module: " .. tostring(result))
			end
		else
			warn("Error loading module code: " .. tostring(loadError))
		end
	else
		warn("HttpGet failed: " .. tostring(moduleCode))
	end
	return nil
end

if type(loadstring) == "function" then
	PromptModule = loadModuleWithLoadstring()
end

if not PromptModule then
	local success, result = pcall(function()
		return require(script:WaitForChild("ProxyModule"))
	end)
	if success then
		PromptModule = result
	else
		warn("Require failed: " .. tostring(result))
		ProximityPrompt.Style = Enum.ProximityPromptStyle.Default
	end
end

local ConfigPrompt = {
	HighlightObject = EvilButton,      -- the object to highlight (same as your EvilButton)
	ProxyPrompt = ProximityPrompt,       -- the ProximityPrompt instance
	DisplayName = "Press Button",              -- (optional) text to display on the UI
	Interaction = function(player)
		onProximityPromptTriggered(player)
	end,
	PromptShownFunction = function(promptInstance)
		print("Prompt shown!")
	end,
	PromptHideFunction = function(promptInstance)
		print("Prompt hidden!")
	end
}

PromptModule.CreatePrompt(ConfigPrompt)

SendSubtitle("Loaded Evil Button Mode Successfully ✅", 5)
