print("hello from lua")
local fs = ixp.new(WMII_ADDRESS)

while true do
	print("events:")
	local data, success = fs:read("/event")
	print(data)
end
