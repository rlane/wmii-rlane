print("hello from lua")
local fs = ixp.new(WMII_ADDRESS)

local keys = [[
Mod1-a
Mod1-b
Mod1-c
Mod1-d
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

fs:write("/keys", keys)
fs:write("/ctl", ctl)
local event_iter = fs:iread("/event")

for event in event_iter do
	print("event:", event)
	local start, finish, e = event:find('^(%w+)')

	if e == 'Key' then
		local key = event:sub(finish+2)
		if key == 'Mod1-a' then
		else
			print("unexpected key " .. key)
		end
	else
		print("unexpected event " .. e)
	end
end
