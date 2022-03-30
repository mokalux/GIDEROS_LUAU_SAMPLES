require "json"

function saveData(filepath, value)
	local contents = json.encode(value)
	local file = io.open(filepath, "w") -- create file
	file:write(contents) -- save json string in file
	io.close(file)
end

function getData(filepath)
	local value
	local file = io.open(filepath, "r")
	local result
	if file then
		local contents = file:read("*a") -- read contents
--		value = json.decode(contents) -- decode json
		result, value = pcall(json.decode, contents)
		io.close(file)
	end
	if result then return value
	else return nil
	end
end

--[[
--try to read information
local someData = getData("someData")

-- if no information, create it
if not someData then
	someData = {"some text", 42}
	saveData("someData.txt", someData)
	print("Creating someData")
else
	print("Read someData", someData[1], someData[2])
end
]]
