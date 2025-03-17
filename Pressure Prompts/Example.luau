local PromptModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/PugserTime/Pressure-Mods/refs/heads/main/Pressure%20Prompts/Source.luau"))()

local ConfigPrompt = {
	HighlightObject = Part,      -- the object that will be highlighted
	ProxyPrompt = ProximityPrompt,       -- the actual ProximityPrompt
	DisplayName = "Interact",              -- The text that will display
	Interaction = function(player)
		print("Interacted By: "..player)
	end,
	PromptShownFunction = function(promptInstance)
		print("Prompt shown!")
	end,
	PromptHideFunction = function(promptInstance)
		print("Prompt hidden!")
	end
}

PromptModule.CreatePrompt(ConfigPrompt)
