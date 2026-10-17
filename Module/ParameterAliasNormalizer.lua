--[[
    @title Mô đun:ParameterAliasNormalizer
    @author Plantaest (Wikipedia tiếng Việt)
    @credit https://vi.wikipedia.org/wiki/Thành_viên:Plantaest
    @description Chuẩn hóa tên tham số, thay thế chuỗi đại diện và xử lý đối số cho các bản mẫu.
--]]

local ModuleObj = {}
local getArgs = require("Module:Arguments").getArgs

--[[ 
   Hàm dùng để chuẩn bị dữ liệu
--]]
function ModuleObj.main(frame)
   local moduleArgs = getArgs(frame, {frameOnly = true})
   local callerArgs = getArgs(frame, {parentOnly = true})
   return ModuleObj._main(frame, moduleArgs, callerArgs)
end

--[[ 
   Chuẩn hóa tên của tham số về tên gốc
--]]
function ModuleObj._main(frame, moduleArgs, callerArgs)
    -- Replace dấu dollar thành số nếu có
    replaceDollar(moduleArgs)
    
    -- Lowercase hóa key của bảng callerArgs
    callerArgs = lowerKey(callerArgs)

    -- Hàm kiểm tra chuỗi có rỗng không
	local function isEmpty(s)
	  return s == nil or mw.text.trim(s) == ''
    end

    -- Lấy tên bản mẫu gốc
	local templateName = moduleArgs.__template
    moduleArgs.__template = nil;

    -- Lấy giá trị của đối số ánh xạ gán cho đối số gốc
	for baseParam, aliasesStr in pairs(moduleArgs) do
		for alias in mw.text.gsplit(aliasesStr, '\\', true) do
			alias = mw.ustring.lower(mw.text.trim(alias))
			if callerArgs[alias] ~= nil then
	            local value = callerArgs[alias]
	            if isEmpty(value) == false then
	                callerArgs[baseParam] = value
	            end
            	callerArgs[alias] = nil
            end
		end
    end
    
    -- Tạo bản mẫu với bảng đối số callerArgs
	local content = frame:expandTemplate{ title = templateName, args = callerArgs }
	return content
end

--[[
    Hàm lowercase hóa key của các pair trong một table
--]]
function lowerKey(table)
    local lowercased = {}
    for key, value in pairs(table) do
        lowercased[mw.ustring.lower(key)] = value
    end
    return lowercased
end

--[[
	Hàm thay dấu dollar thành số
	Ví dụ: "combatant${1,3} = bên $" sẽ sinh ra 3 đối số:
	"combatant1 = bên 1", "combatant2 = bên 2", "combatant3 = bên 3"
--]]
function replaceDollar(table)
	local temp = {}
	
	-- Tìm các key có pattern phù hợp, sinh các cặp key-value tương ứng
	-- và xóa cặp key-value ban đầu
	for key, value in pairs(table) do
		if (mw.ustring.match(key, "${(%d+,%d+)}")) then
			local points = mw.text.split(mw.ustring.match(key, "${(%d+,%d+)}"), ",", true)
			for i = points[1], points[2], 1 do
				local k = mw.ustring.gsub(key, "(${%d+,%d+})", i)
				local v = mw.ustring.gsub(value, "%$", i)
				temp[k] = v
			end
			table[key] = nil
		end
	end
	
	for key, value in pairs(temp) do
		table[key] = value
	end
end

return ModuleObj
