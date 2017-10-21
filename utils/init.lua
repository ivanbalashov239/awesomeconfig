--local beautiful = require("beautiful")
--local wibox = require("wibox")
local lain = require("lain")
local wrequire     = require("lain.helpers").wrequire
local setmetatable = setmetatable
local utils = { _NAME = "utils" }
local utf8 = require("lua-utf8")

function utils.to_n(str,n)
	local str = tostring(str)
	local l = utf8.len(str)
	local n = n or l
	local result = ""
	if l > n then
		result = utf8.sub(str,1,n)
	elseif l == n then
		result = str
	else
		local d = (n-l)/2%1
		local dif1 = (n-l)/2+d
		local dif2 = (n-l)/2-d
		result = string.rep(" ",dif1)..str..string.rep(" ",dif2)
	end
	return result
end
function utils.split(s, delimiter)
	result = {};
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match);
	end
	return result;
end

local function worker(args)
end

return setmetatable(utils, {__index = wrequire, __call = function(_,...) return worker(...) end})
