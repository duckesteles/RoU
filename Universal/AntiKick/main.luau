--[[
	AntiKick
	Author: duckesteles
	https://github.com/duckesteles/RoU
]]

if getgenv().AntiKick_Active then
	return getgenv().AntiKick_Restore
end
getgenv().AntiKick_Active = true

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local hookmetamethod = hookmetamethod
local getnamecallmethod = getnamecallmethod
local checkcaller = checkcaller
local newcclosure = (newcclosure or function(f) return f end)
local getcallingscript = rawget(getfenv(), "getcallingscript")

local function notify(title, text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = 5,
		})
	end)
end

local function describeCaller()
	if typeof(getcallingscript) ~= "function" then
		return "unknown"
	end
	local ok, script = pcall(getcallingscript)
	if ok and typeof(script) == "Instance" then
		local ok2, name = pcall(function() return script:GetFullName() end)
		if ok2 then return name end
	end
	return "unknown"
end

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	if not checkcaller() and self == LocalPlayer then
		local method = getnamecallmethod()
		if method == "Kick" then
			warn(string.format("[AntiKick] Blocked kick from: %s | Reason: %s",
				describeCaller(), tostring((...))))
			return task.wait(math.huge)
		end
	end
	return OldNamecall(self, ...)
end))

getgenv().AntiKick_Restore = function()
	pcall(function()
		hookmetamethod(game, "__namecall", OldNamecall)
	end)
	getgenv().AntiKick_Active = false
	getgenv().AntiKick_Restore = nil
end

notify("Anti Kick", "Protection active")

return getgenv().AntiKick_Restore
