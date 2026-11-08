--[=[
 * Module:InfoboxSEO
 *
 * @desc Đặt siêu dữ liệu SEO (WikiSEO #seo + SHORTDESC) từ tham số của các hộp thông tin InfoboxNeue
 * @author [[Thành viên:Pisces]] (https://songngu.xyz)
 * @site https://lophocmatngu.wiki/Module:InfoboxSEO
 * @license CC BY-SA 4.0
 ]=]

local p = {}

local FILE_NS = { ['file'] = true, ['tập tin'] = true, ['image'] = true, ['hình'] = true }
local EXTS = { 'jpg', 'jpeg', 'png', 'gif', 'webp', 'svg' }

--- Bỏ liên kết wiki, giữ phần chữ hiển thị: [[A|B]] → B, [[A]] → A
function p.plain( s )
	if not s then return nil end
	s = s:gsub( '%[%[[^%]|]*|([^%]]*)%]%]', '%1' ):gsub( '%[%[([^%]]*)%]%]', '%1' )
	s = mw.text.trim( s )
	return s ~= '' and s or nil
end

--- Lấy tên tập tin đầu tiên từ tham số image ("Tập tin:A.jpg:Nhãn, B.png:Nhãn" → "A.jpg")
function p.firstImage( image )
	if not image then return nil end
	local first = mw.text.trim( mw.text.split( image, ',', true )[ 1 ] )
	local prefix, rest = mw.ustring.match( first, '^([^:]+):(.*)$' )
	if prefix and FILE_NS[ mw.ustring.lower( mw.text.trim( prefix ) ) ] then
		first = mw.text.trim( rest )
	end
	-- Cắt tại đuôi tập tin sớm nhất để bỏ phần ":Nhãn" (tên tập tin có thể chứa dấu :)
	local lower, stop = mw.ustring.lower( first ), nil
	for _, ext in ipairs( EXTS ) do
		local _, e = lower:find( '.' .. ext, 1, true )
		if e and ( not stop or e < stop ) then stop = e end
	end
	return stop and first:sub( 1, stop ) or first
end

--- Đặt SEO cho trang hiện tại; trả về chuỗi rỗng (chỉ ghi thuộc tính trang)
-- @param frame   frame hiện tại
-- @param args    tham số hộp thông tin (dùng image, description)
-- @param cfg     { imageAlt = string, keywords = { string... }, shortdesc = string }
function p.setSEO( frame, args, cfg )
	cfg = cfg or {}
	local page = mw.title.getCurrentTitle().text
	local kw = { page, mw.site.siteName, 'wiki', 'lớp học mật ngữ', 'mật ngữ', 'lớp học' }
	for i = 1, table.maxn( cfg.keywords or {} ) do
		local v = p.plain( cfg.keywords[ i ] )
		if v then table.insert( kw, v ) end
	end

	-- Không có description thì để Description2/TextExtracts tự sinh từ đoạn mở đầu
	local seo = {
		'',
		locale = 'vi_VN',
		keywords = table.concat( kw, ', ' ),
		description = p.plain( args.description ),
		image = p.firstImage( args.image ),
		image_alt = cfg.imageAlt
	}
	local out = frame:callParserFunction( '#seo', seo )
	if cfg.shortdesc then
		out = out .. frame:callParserFunction( 'SHORTDESC', { cfg.shortdesc } )
	end
	return out
end

return p
