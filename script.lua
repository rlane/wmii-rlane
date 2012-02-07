print("hello from lua")
local fs = ixp.new(WMII_ADDRESS)

local ctl = [[
bar on top
border 1
colmode default
focuscolors #cccccc #333333 #333333
font xft:dejavu sans mono:pixelsize=12:antialias=true
fontpad 0 0 0 0
grabmod Mod1
incmode ignore
normcolors #cccccc #222222 #222222
]]

local keybindings = {
	["Mod1-a"] = function() fs:write("/ctl", "view a") end,
	["Mod1-b"] = function() fs:write("/ctl", "view b") end,
	["Mod1-x"] = function() spawn("urxvt") end,
}

local events = {}

function events.Key(key)
	local fn = keybindings[key]
	if fn then fn() else print("unexpected key " .. key) end
end

function events.CreateTag(tag)
	fs:create("/lbar/tag:" .. tag, tag)
end

function events.DestroyTag(tag)
	fs:remove("/lbar/tag:" .. tag)
end

local keys = {}
for k, v in pairs(keybindings) do table.insert(keys, k) end

fs:write("/keys", table.concat(keys, "\n"))
fs:write("/ctl", ctl)
local event_iter = fs:iread("/event")

for event in event_iter do
	print("event:", event)
	local start, finish, e = event:find('^(%w+)')
	local rest = event:sub(finish+2)
	local handler = events[e]
	if handler then
		handler(rest)
	else
		print("unexpected event " .. e)
	end
end
