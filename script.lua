print("hello from lua")
local fs = ixp.new(WMII_ADDRESS)

local last_tag = nil
local focuscolors = "#dcdccc #5b605e #4f4f4f"
local normcolors = "#dcdccc #3f3f3f #434443"
local mod = "Mod4"


fs:write("/event", "Start wmiirc")


fs:write("/ctl", [[
bar on top
border 1
colmode default
font xft:dejavu sans mono:pixelsize=12:antialias=true
fontpad 0 0 0 0
grabmod Mod1
incmode ignore
]])

fs:write("/ctl", "normcolors " .. normcolors)
fs:write("/ctl", "focuscolors " .. focuscolors)

local keybindings = {
	[mod.."-e"] = function() fs:write("/ctl", "view mail") end,
	[mod.."-w"] = function() fs:write("/ctl", "view www") end,
	[mod.."-n"] = function() fs:write("/ctl", "view notes") end,
	[mod.."-1"] = function() fs:write("/ctl", "view 1") end,
	[mod.."-2"] = function() fs:write("/ctl", "view 2") end,
	[mod.."-3"] = function() fs:write("/ctl", "view 3") end,
	[mod.."-4"] = function() fs:write("/ctl", "view 4") end,
	[mod.."-5"] = function() fs:write("/ctl", "view 5") end,
	[mod.."-6"] = function() fs:write("/ctl", "view 6") end,
	[mod.."-7"] = function() fs:write("/ctl", "view 7") end,
	[mod.."-8"] = function() fs:write("/ctl", "view 8") end,
	[mod.."-9"] = function() fs:write("/ctl", "view 9") end,

	[mod.."-q"] = function() if last_tag then fs:write("/ctl", "view " .. last_tag) end end,

	[mod.."-j"] = function() fs:write("/tag/sel/ctl", "select down") end,
	[mod.."-k"] = function() fs:write("/tag/sel/ctl", "select up") end,
	[mod.."-l"] = function() fs:write("/tag/sel/ctl", "select right") end,
	[mod.."-h"] = function() fs:write("/tag/sel/ctl", "select left") end,
	[mod.."-space"] = function() fs:write("/tag/sel/ctl", "select toggle") end,

	[mod.."-Shift-j"] = function() fs:write("/tag/sel/ctl", "send sel down") end,
	[mod.."-Shift-k"] = function() fs:write("/tag/sel/ctl", "send sel up") end,
	[mod.."-Shift-l"] = function() fs:write("/tag/sel/ctl", "send sel right") end,
	[mod.."-Shift-h"] = function() fs:write("/tag/sel/ctl", "send sel left") end,
	[mod.."-Shift-space"] = function() fs:write("/tag/sel/ctl", "send sel toggle") end,

	[mod.."-d"] = function() fs:write("/tag/sel/ctl", "colmode sel default-max") end,
	[mod.."-s"] = function() fs:write("/tag/sel/ctl", "colmode sel stack-max") end,
	[mod.."-m"] = function() fs:write("/tag/sel/ctl", "colmode sel stack+max") end,

	[mod.."-Shift-c"] = function() fs:write("/client/sel/ctl", "kill") end,
	[mod.."-f"] = function() fs:write("/client/sel/ctl", "Fullscreen toggle") end,

	[mod.."-t"] = function() action("tag-menu") end,
	[mod.."-Shift-t"] = function() action("retag-menu") end,
	[mod.."-p"] = function() action("run-menu") end,

	[mod.."-x"] = function() spawn("urxvtc") end,
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
	fs:create("/lbar/" .. tag, "colors " .. normcolors .. "\nlabel " .. tag)
end

function events.DestroyTag(tag)
	fs:remove("/lbar/" .. tag)
end

function events.FocusTag(tag)
	fs:write("/lbar/" .. tag, "colors " .. focuscolors .. "\nlabel" .. tag)
end

function events.UnfocusTag(tag)
	fs:write("/lbar/" .. tag, "colors " .. normcolors .. "\nlabel" .. tag)
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

function events.DestroyClient(client)
end

function events.ClientFocus(client)
end

function events.LeftBarMouseDown(button, item)
end

function events.LeftBarClick(button, item)
	if button == "1" then
		fs:write("/ctl", "view " .. item)
	end
end

function events.Start(name)
   error("another wmiirc took over, shutting down")
end

function events.Timer()
	fs:write("/rbar/time", "label " .. os.date("%H:%M"))
end

for stat in fs:idir("/lbar") do
	fs:remove("/lbar/" .. stat.name)
end

for stat in fs:idir("/rbar") do
	fs:remove("/rbar/" .. stat.name)
end

for stat in fs:idir("/tag") do
	if stat.name ~= "sel" then
		fs:create("/lbar/" .. stat.name, "label " .. stat.name)
	end
end

fs:create("/rbar/time", "label " .. os.date("%H:%M"))

for event in fs:iread("/event") do
	print("event:", event)
	local e = nil
	local args = {}
	for word in event:gmatch('[^ ]+') do
		if e then
			table.insert(args, word)
		else
			e = word
		end
	end
	local handler = events[e]
	if handler then
		handler(unpack(args))
	else
		print("unexpected event " .. e)
	end
end
