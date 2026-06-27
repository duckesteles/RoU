if getgenv().AntiKickExecuted then
    return
end
getgenv().AntiKickExecuted = true

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

type KickFunction = (Player, string?) -> ()
type GenericFunction = (...any) -> ...any

local k1: string = string.char(75, 105, 99, 107)
local k2: string = string.char(107, 105, 99, 107)

local function kickDetected(reason: unknown): ()
    local safeReason: string = typeof(reason) == "string" and (reason :: string) or "Unknown"
    warn(string.format("Kick attempted and blocked. Reason: %s", safeReason))
end

local oldKick: KickFunction
oldKick = hookfunction(LocalPlayer.Kick, newcclosure(function(self: Player, ...: any): ()
    if not checkcaller() then
        if typeof(self) == "Instance" and self == LocalPlayer then
            local args: {any} = {...}
            kickDetected(args[1])
            return
        end
    end
    return oldKick(self, ...)
end))

local dummyKick: KickFunction
dummyKick = newcclosure(function(playerSelf: Player, ...: any): ()
    if not checkcaller() then
        if typeof(playerSelf) == "Instance" and playerSelf == LocalPlayer then
            local args: {any} = {...}
            kickDetected(args[1])
            return
        end
    end
    return oldKick(playerSelf, ...)
end)

local oldNamecall: GenericFunction
oldNamecall = hookmetamethod(game, string.char(95, 95, 110, 97, 109, 101, 99, 97, 108, 108), newcclosure(function(self: any, ...: any): any
    if not checkcaller() then
        local method: string = getnamecallmethod()
        if typeof(self) == "Instance" and self == LocalPlayer and (method == k1 or method == k2) then
            local args: {any} = {...}
            kickDetected(args[1])
            return nil
        end
    end
    return oldNamecall(self, ...)
end))

local oldIndex: GenericFunction
oldIndex = hookmetamethod(game, string.char(95, 95, 105, 110, 100, 101, 120), newcclosure(function(self: any, key: any): any
    if not checkcaller() then
        if typeof(self) == "Instance" and self == LocalPlayer and (key == k1 or key == k2) then
            return dummyKick
        end
    end
    return oldIndex(self, key)
end))

pcall(function(): ()
    local renv = getrenv()
    if renv and renv.debug and renv.debug.info then
        local oldDebugInfo: GenericFunction
        oldDebugInfo = hookfunction(renv.debug.info, newcclosure(function(...: any): any
            local levelOrFunc, info = ...
            if dummyKick and levelOrFunc == dummyKick then
                return coroutine.yield(coroutine.running())
            end
            return oldDebugInfo(...)
        end))
    end
end)

local function showNotification(): ()
    local success: boolean, notiflib: any = pcall(function(): any
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/slixxywixxy/notiflib/refs/heads/main/main"))()
    end)

    if success and typeof(notiflib) == "table" then
        pcall(notiflib.Notify, notiflib, {
            Title = "Anti Kick",
            Description = "Active. By tosubmit",
            Duration = 5
        })
    else
        pcall(function(): ()
            StarterGui:SetCore("SendNotification", {
                Title = "Anti Kick",
                Text = "Active. By tosubmit",
                Duration = 5
            })
        end)
    end
end

showNotification()
