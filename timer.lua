print("starting timer.lua")
local fs = ixp.new(WMII_ADDRESS)

function timer()
	fs:write("/event", "Timer")
end
