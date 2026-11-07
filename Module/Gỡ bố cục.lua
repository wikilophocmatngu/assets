--[=[
 * Module:Gỡ bố cục
 *
 * @desc Mô đun tạm để gỡ các bản mẫu bố cục toàn trang của PageForms ({{Nhân vật}}, {{Ấn phẩm}},
 *       {{Chương truyện}}) thành wikitext thường. Dùng qua {{subst:#invoke:Gỡ bố cục|<hàm>|...}};
 *       xóa mô đun sau khi bot chuyển đổi xong.
 * @author [[Thành viên:Pisces]] (https://songngu.xyz)
 * @site https://lophocmatngu.wiki/Module:Gỡ bố cục
 * @license CC BY-SA 4.0
 ]=]

local getArgs = require( 'Module:Arguments' ).getArgs

local p = {}

--- Khi subst, {{!}} trong tham số vẫn còn ở dạng chữ, cần đổi lại thành |
local function unpipe( s )
	return ( s:gsub( '{{%s*!%s*}}', '|' ) )
end

--- Gói danh sách ảnh vào thẻ <gallery> (giữ nguyên nếu đã có sẵn thẻ)
local function gallery( s )
	if not s then return nil end
	s = mw.text.trim( unpipe( s ) )
	if s == '' then return nil end
	if s:find( '<gallery', 1, true ) then
		-- Một số bài quên đóng thẻ
		if not s:find( '</gallery>', 1, true ) then s = s .. '\n</gallery>' end
		return s
	end
	return '<gallery mode="nolines">\n' .. s .. '\n</gallery>'
end

--- Đổi <gallery> trong tham số image thành danh sách "Tập tin:Nhãn, ..." của InfoboxNeue
local function galleryToList( s )
	if not s or not s:find( '<gallery', 1, true ) then return s end
	local items = {}
	for line in unpipe( s ):gmatch( '[^\n]+' ) do
		line = mw.text.trim( line )
		if line ~= '' and not line:find( '^</?gallery' ) then
			local file, label = line:match( '^([^|]-)%s*|%s*(.-)$' )
			table.insert( items, file and ( file .. ':' .. label ) or line )
		end
	end
	return table.concat( items, ', ' )
end

--- Dựng lời gọi hộp thông tin, giữ cả các trường trống để người sửa dễ điền
local function infobox( name, args, keys, defaults )
	local out = { '{{' .. name }
	for _, k in ipairs( keys ) do
		table.insert( out, '|' .. k .. '=' .. ( args[ k ] or ( defaults and defaults[ k ] ) or '' ) )
	end
	table.insert( out, '}}' )
	return table.concat( out, '\n' )
end

--- Giữ các tham số không tên (trước đây bị ẩn) trong chú thích để không mất nội dung
local function hidden( args )
	local out = {}
	for i, v in ipairs( args ) do
		table.insert( out, '<!-- Nội dung ẩn từ bố cục cũ (' .. i .. '): ' .. v:gsub( '%-%-', '- -' ) .. ' -->' )
	end
	return table.concat( out, '\n' )
end

local function seo( t )
	local out = { '{{#seo:' }
	for _, kv in ipairs( t ) do
		table.insert( out, ' |' .. kv[ 1 ] .. ' = ' .. kv[ 2 ] )
	end
	table.insert( out, '}}' )
	return table.concat( out, '\n' )
end

--- Nối các khối, bỏ khối rỗng
local function join( blocks )
	local out = {}
	-- table.maxn thay cho ipairs vì danh sách có lỗ nil
	for i = 1, table.maxn( blocks ) do
		local b = blocks[ i ]
		if b and b ~= '' then table.insert( out, b ) end
	end
	return table.concat( out, '\n' )
end

--- Khi subst trả wikitext thô; khi nhúng bình thường thì dựng trang luôn
local function finish( frame, text )
	if mw.isSubsting() then return text end
	return frame:preprocess( text )
end

local function kw( ... )
	local out = {}
	for i = 1, select( '#', ... ) do
		local v = select( i, ... )
		if v and v ~= '' then table.insert( out, v ) end
	end
	return table.concat( out, ', ' )
end

function p.nhanVat( frame )
	local a = getArgs( frame )
	local page = mw.title.getCurrentTitle().text
	local aff = a.affiliation
	local imgs = gallery( a.gallery )
	return finish( frame, join( {
		a.templates,
		infobox( 'Hộp thông tin nhân vật', a,
			{ 'image', 'gender', 'affiliation', 'occupation', 'first_appearance', 'first_appearance_year' },
			{ image = page .. '.png' } ),
		a.content or 'Không có thông tin.',
		imgs and ( '\n==Hình ảnh==\n' .. imgs ),
		aff and ( '{{' .. aff .. '}}' ) or '{{Điều hướng nhân vật}}',
		hidden( a ),
		'[[Thể loại:Nhân vật]]',
		a.gender and ( '[[Thể loại:Nhân vật ' .. a.gender .. ']]' ),
		aff and ( '[[Thể loại:' .. aff .. ']]' ),
		seo( {
			{ 'image', a.image or '' },
			{ 'image_alt', 'Hình ảnh của nhân vật {{PAGENAME}} trong Lớp Học Mật Ngữ.' },
			{ 'description', a.description or '' },
			{ 'locale', 'vi_VN' },
			{ 'keywords', kw( '{{PAGENAME}}, {{SITENAME}}, wiki, lớp học mật ngữ, nhân vật, thú cưng, nhân vật phụ, mật ngữ, lớp học',
				a.gender, a.nickname, aff, a.occupation, a.first_appearance ) }
		} ),
		'{{SHORTDESC:Một ' .. ( aff and ( 'thành viên của ' .. aff .. '.' ) or 'nhân vật trong Lớp Học Mật Ngữ.' ) .. '}}',
		a.wikibase and ( '{{MNDb|' .. a.wikibase .. '}} {{#unlinkedwikibase: id=Q' .. a.wikibase .. '}}' )
	} ) )
end

function p.anPham( frame )
	local a = getArgs( frame )
	local imgs = gallery( a.gallery )
	return finish( frame, join( {
		seo( {
			{ 'image', a.image or '' },
			{ 'image_alt', 'Hình ảnh của ấn phẩm {{PAGENAME}} trong Lớp Học Mật Ngữ.' },
			{ 'description', a.description or '' },
			{ 'locale', 'vi_VN' },
			{ 'keywords', kw( '{{PAGENAME}}, {{SITENAME}}, wiki, lớp học mật ngữ, tác phẩm, ấn phẩm, truyện tranh, mật ngữ, lớp học',
				a.type, a.previous, a.next ) }
		} ),
		'{{SHORTDESC:Chỉ là một trang về một cuốn ' .. ( a.version == 'Mini' and 'Phiên bản Mini' or ( a.type or '' ) ) .. '.}}',
		infobox( 'Hộp thông tin ấn phẩm', a,
			{ 'image', 'series', 'publisher', 'release_date', 'pages', 'previous', 'next' } ),
		a.description,
		a.cover and ( '\n==Thiết kế bìa==\n' .. a.cover ),
		'\n==Mục lục==\n' .. ( a.contents or '' ),
		'\n==Quà tặng kèm==\n' .. ( a.gifts or '' ),
		a.background and ( '\n==Thông tin cơ sở==\n' .. a.background ),
		imgs and ( '\n==Thư viện hình ảnh==\n' .. imgs ),
		hidden( a ),
		'<mw-navigation title="Tác phẩm" />',
		'[[Thể loại:Ấn phẩm]]',
		a.type and ( '[[Thể loại:' .. a.type .. ']]' ),
		a.version and ( '[[Thể loại:Phiên bản ' .. a.version .. ']]' )
	} ) )
end

function p.chuongTruyen( frame )
	local a = getArgs( frame )
	local imgs = gallery( a.gallery )
	a.image = galleryToList( a.image )
	return finish( frame, join( {
		seo( {
			{ 'title', '{{PAGENAME}}' },
			{ 'image', a.image or '' },
			{ 'image_alt', '(Các) hình ảnh của chương {{PAGENAME}} trong Lớp Học Mật Ngữ.' },
			{ 'description', a.description or '' },
			{ 'locale', 'vi_VN' },
			{ 'keywords', kw( '{{PAGENAME}}, {{SITENAME}}, wiki, lớp học mật ngữ, chương truyện, chương, truyện, truyện tranh, mật ngữ, lớp học',
				a.type, a.main, a.publications ) }
		} ),
		'{{SHORTDESC:Một chương ' .. ( a.type == 'Ngoại truyện' and 'ngoại ' or '' ) .. 'truyện '
			.. ( a.ttn and mw.ustring.lower( a.ttn ) ~= 'không' and 'phát hành trên báo Thiên Thần Nhỏ.' or 'trong Lớp Học Mật Ngữ.' ) .. '}}',
		infobox( 'Hộp thông tin chương truyện', a,
			{ 'image', 'release_date', 'publications', 'ttn', 'parts', 'pages', 'main' } ),
		a.description,
		'\n== Cốt truyện ==\n' .. ( a.plot or '' ),
		'\n== Thông tin cơ sở ==\n' .. ( a.background or '' ),
		imgs and ( '\n== Thư viện hình ảnh ==\n' .. imgs ),
		hidden( a ),
		a.type == 'Ngoại truyện' and '[[Thể loại:Ngoại truyện]]'
	} ) )
end

return p
