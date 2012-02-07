print("hello from lua")
local fs = ixp.new(WMII_ADDRESS)

local keys = [[
Mod1-a
Mod1-b
Mod1-x
]]

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

fs:write("/keys", keys)
fs:write("/ctl", ctl)
local event_iter = fs:iread("/event")

for event in event_iter do
	print("event:", event)
	local start, finish, e = event:find('^(%w+)')
	local rest = event:sub(finish+2)

	if e == 'Key' then
		local key = rest
		local fn = keybindings[key]
		if fn then fn() else print("unexpected key " .. key) end
	elseif e == 'CreateTag' then
		local tag = rest
		fs:create("/lbar/tag:" .. tag, tag)
	elseif e == 'DestroyTag' then
		local tag = rest
		fs:remove("/lbar/tag:" .. tag)
	else
		print("unexpected event " .. e)
	end
end
