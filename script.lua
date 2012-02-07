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

	["Mod1-j"] = function() fs:write("/tag/sel/ctl", "select down") end,
	["Mod1-k"] = function() fs:write("/tag/sel/ctl", "select up") end,
	["Mod1-l"] = function() fs:write("/tag/sel/ctl", "select right") end,
	["Mod1-h"] = function() fs:write("/tag/sel/ctl", "select left") end,

	["Mod1-Shift-j"] = function() fs:write("/tag/sel/ctl", "send sel down") end,
	["Mod1-Shift-k"] = function() fs:write("/tag/sel/ctl", "send sel up") end,
	["Mod1-Shift-l"] = function() fs:write("/tag/sel/ctl", "send sel right") end,
	["Mod1-Shift-h"] = function() fs:write("/tag/sel/ctl", "send sel left") end,

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

function events.CreateColumn()
end

function events.DestroyColumn()
end

function events.FocusTag()
end

function events.UnfocusTag()
end

function events.AreaFocus()
end

function events.CreateClient()
end

function events.ClientFocus()
end

function events.LeftBarMouseDown()
end

function events.LeftBarClick()
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
