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
	["Mod1-space"] = function() fs:write("/tag/sel/ctl", "select toggle") end,

	["Mod1-Shift-j"] = function() fs:write("/tag/sel/ctl", "send sel down") end,
	["Mod1-Shift-k"] = function() fs:write("/tag/sel/ctl", "send sel up") end,
	["Mod1-Shift-l"] = function() fs:write("/tag/sel/ctl", "send sel right") end,
	["Mod1-Shift-h"] = function() fs:write("/tag/sel/ctl", "send sel left") end,
	["Mod1-Shift-space"] = function() fs:write("/tag/sel/ctl", "send sel toggle") end,

	["Mod1-d"] = function() fs:write("/tag/sel/ctl", "colmode sel default-max") end,
	["Mod1-s"] = function() fs:write("/tag/sel/ctl", "colmode sel stack-max") end,
	["Mod1-m"] = function() fs:write("/tag/sel/ctl", "colmode sel stack+max") end,

	["Mod1-Shift-c"] = function() fs:write("/client/sel/ctl", "kill") end,
	["Mod1-f"] = function() fs:write("/client/sel/ctl", "Fullscreen toggle") end,

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

function events.CreateColumn(col)
end

function events.DestroyColumn(col)
end

function events.ColumnFocus(col)
end

function events.FocusTag(tag)
end

function events.UnfocusTag(tag)
end

function events.DestroyArea(area)
end

function events.AreaFocus(area)
end

function events.CreateClient(client)
end

function events.ClientFocus(client)
end

function events.LeftBarMouseDown(args)
end

function events.LeftBarClick(args)
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
