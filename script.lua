print("hello from lua")
local fs = ixp.new(WMII_ADDRESS)

local last_tag = nil
local focuscolors = '#cccccc #333333 #333333'
local normcolors = '#cccccc #222222 #222222'


fs:write("/event", "Start wmiirc")


fs:write("/ctl", [[
bar on top
border 1
colmode default
focuscolors #cccccc #333333 #333333
font xft:dejavu sans mono:pixelsize=12:antialias=true
fontpad 0 0 0 0
grabmod Mod1
incmode ignore
normcolors #cccccc #222222 #222222
]])


local keybindings = {
	["Mod1-e"] = function() fs:write("/ctl", "view mail") end,
	["Mod1-w"] = function() fs:write("/ctl", "view www") end,
	["Mod1-1"] = function() fs:write("/ctl", "view 1") end,
	["Mod1-2"] = function() fs:write("/ctl", "view 2") end,
	["Mod1-3"] = function() fs:write("/ctl", "view 3") end,
	["Mod1-4"] = function() fs:write("/ctl", "view 4") end,
	["Mod1-5"] = function() fs:write("/ctl", "view 5") end,
	["Mod1-6"] = function() fs:write("/ctl", "view 6") end,
	["Mod1-7"] = function() fs:write("/ctl", "view 7") end,
	["Mod1-8"] = function() fs:write("/ctl", "view 8") end,
	["Mod1-9"] = function() fs:write("/ctl", "view 9") end,

	["Mod1-q"] = function() if last_tag then fs:write("/ctl", "view " .. last_tag) end end,

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

	["Mod1-t"] = function() spawn("./tag-menu") end,
	["Mod1-Shift-t"] = function() spawn("./retag-menu") end,

	["Mod1-x"] = function() spawn("urxvt") end,
}

local keys = {}
for k, v in pairs(keybindings) do table.insert(keys, k) end
fs:write("/keys", table.concat(keys, "\n"))


local events = {}

function events.Key(key)
	local fn = keybindings[key]
	if fn then fn() else print("unexpected key " .. key) end
end

function events.CreateTag(tag)
	fs:create("/lbar/tag:" .. tag, normcolors .. " " .. tag)
end

function events.DestroyTag(tag)
	fs:remove("/lbar/tag:" .. tag)
end

function events.FocusTag(tag)
	fs:write("/lbar/tag:" .. tag, focuscolors .. " " .. tag)
end

function events.UnfocusTag(tag)
	fs:write("/lbar/tag:" .. tag, normcolors .. " " .. tag)
	last_tag = tag
end

function events.CreateColumn(col)
end

function events.DestroyColumn(col)
end

function events.ColumnFocus(col)
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

function events.Start(name)
   error("another wmiirc took over, shutting down")
end

for stat in fs:idir("/lbar") do
	fs:remove("/lbar/" .. stat.name)
end

for stat in fs:idir("/tag") do
	if stat.name ~= "sel" then
		fs:create("/lbar/tag:" .. stat.name, stat.name)
	end
end

for event in fs:iread("/event") do
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
