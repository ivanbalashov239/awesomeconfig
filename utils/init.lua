--local beautiful = require("beautiful")
--local wibox = require("wibox")
local lain = require("lain")
local wrequire     = require("lain.helpers").wrequire
local setmetatable = setmetatable
local utils = { _NAME = "utils" }
local utf8 = require("lua-utf8")

function utils.to_n(str,n,dots,onlycut,symbol)
	local str = tostring(str)
	local symbol = symbol or " "
	local l = utf8.len(str)
	local n = n or l
	local result = str
	if l > n then
		result = utf8.sub(str,1,n)
		if dots == true then
			dots = "…"
		elseif dots == nil then
			dots = ""
		end
		result = result..dots
	elseif l == n then
		result = str
	elseif not onlycut then
		local d = (n-l)/2%1
		local dif1 = (n-l)/2+d
		local dif2 = (n-l)/2-d
		result = string.rep(symbol,dif1)..str..string.rep(symbol,dif2)
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
function utils.pread(cmd)
		local process, err = io.popen(cmd)
		local output = nil
		if process then
			output = process:read("*all")
			process:close()
		end
		return output
end
function utils.get_days_in_month(month, year)
	local days_in_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }   
	local d = days_in_month[month]

	-- check for leap year
	if (month == 2) then
		if (math.fmod(year,4) == 0) then
			if (math.fmod(year,100) == 0)then                
				if (math.fmod(year,400) == 0) then                    
					d = 29
				end
			else                
				d = 29
			end
		end
	end

	return d  
end

local function worker(args)
end

return setmetatable(utils, {__index = wrequire, __call = function(_,...) return worker(...) end})
