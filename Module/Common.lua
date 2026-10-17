local libraryUtil = require('libraryUtil')
local checkType = libraryUtil.checkType
local checkTypeMulti = libraryUtil.checkTypeMulti

local p = {}


--- Escape pattern for regex

--- @param s string string to escape
--- @return string
local function escapePattern(s)
	return s:gsub("%W", "%%%1")
end


--- Check if table contains value, return key if match
---
--- @param t table - Table to search
--- @param val any - Value to match
--- @return number|nil
function p.tableContains(t, val)
	checkType('Module:Common.tableContains', 1, t, 'table')
	for k, v in pairs(t) do
		if v == val then
			return k
		end
	end
end


--- Check if table contains key, return value if match
---
--- @param t table - Table to search
--- @param key string|number - Key to match
--- @return number|nil
function p.tableContainsKey(t, key)
	checkType('Module:Common.tableContainsKey', 1, t, 'table')
	checkTypeMulti('Module:Common.tableContainsKey', 2, key, {'string', 'number'})
	for k, v in pairs(t) do
		if k == key then
			return v
		end
	end
end


--- Split string by delimiter and return the table of string parts
---
--- @param str string String to split
--- @param delimiter string Delimiter used to split the string, default to %s
--- @return table
function p.splitStringIntoTable( str, delimiter )
        if delimiter == nil then
                delimiter = "%s"
        end
        local t = {}
        local pattern = '[^' .. escapePattern( delimiter ) .. ']+'
        for s in string.gmatch( str, pattern ) do
                table.insert( t, s )
        end
        return t
end


--- Returns a table containing the numbers of the arguments that exist
--- for the specified prefix. For example, if the prefix was 'data', and
--- 'data1', 'data2', and 'data5' exist, it would return {1, 2, 5}.
---
--- @param prefix string Prefix of the argument name
--- @param args table Table of arguments
--- @return table Table of argument numbers
function p.getArgNums(prefix, args)
	local nums = {}
	for k, v in pairs(args) do
		local num = tostring(k):match('^' .. prefix .. '([1-9]%d*)$')
		if num then table.insert(nums, tonumber(num)) end
	end
	table.sort(nums)
	return nums
end

return p
