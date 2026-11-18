--[=[
 * Module:InfoboxBucket
 *
 * @desc Làm sạch tham số hộp thông tin và ghi vào Bucket (Extension:Bucket)
 * @author [[Thành viên:Pisces]] (https://songngu.xyz)
 * @site https://lophocmatngu.wiki/Module:InfoboxBucket
 * @license CC BY-SA 4.0
 ]=]

local p = {}

local function nonEmpty( s )
	s = s and mw.text.trim( s )
	return s ~= '' and s or nil
end

--- Chữ thuần, bỏ liên kết wiki: [[A|B]] → B
p.text = require( 'Module:InfoboxSEO' ).plain

--- Tên trang đích (kiểu PAGE): "[[A|B]]" → "A", chữ thường giữ nguyên
function p.page( s )
	if not s then return nil end
	return nonEmpty( s:match( '%[%[([^%]|]+)' ) or s )
end

--- Số nguyên đầu tiên trong chuỗi (kiểu INTEGER): "300 trang" → 300
function p.int( s )
	return s and tonumber( s:match( '%d+' ) )
end

--- Tách danh sách (kiểu repeated) theo dòng, dấu * và dấu phẩy, rồi áp hàm làm sạch
function p.list( s, clean )
	if not s then return nil end
	local out = {}
	for item in mw.text.gsplit( s, '[\n,]' ) do
		local v = clean( ( item:gsub( '^%s*%*+', '' ) ) )
		if v then table.insert( out, v ) end
	end
	return #out > 0 and out or nil
end

--- Ghi một dòng vào bucket; chỉ chạy ở không gian chính để trang tài liệu bản mẫu không ghi rác
-- @return chuỗi rỗng, hoặc thể loại theo dõi nếu Bucket báo lỗi (không làm hỏng hộp thông tin)
function p.put( name, data )
	if not mw.ext.bucket or mw.title.getCurrentTitle().namespace ~= 0 then
		return ''
	end
	local ok = pcall( function () mw.ext.bucket( name ).put( data ) end )
	return ok and '' or '[[Thể loại:Trang có lỗi Bucket]]'
end

return p
