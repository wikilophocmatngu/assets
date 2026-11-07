--[=[
 * Module:Navbox
 *
 * @desc Mô đun dựng hộp điều hướng cho [[Bản mẫu:Hộp điều hướng]], tham số tiếng Anh: title, image, state, above, below, groupN, listN, evenodd, bodyclass; {{Hộp điều hướng|child|…}} cho hộp con
 * @author [[Thành viên:Pisces]] (https://songngu.xyz)
 * @site https://lophocmatngu.wiki/Module:Navbox
 * @license CC BY-SA 4.0
 ]=]

local p = {}

-- Dựng một hộp điều hướng. Hộp con ({{Hộp điều hướng|child|…}}) không có
-- tiêu đề riêng và không thu gọn, chỉ là bảng lồng trong ô danh sách.
function p._navbox( args )
	local child = args[ 1 ] == 'child' or args[ 1 ] == 'subgroup'
	local title = args.title
	local image = args.image
	local above = args.above
	local below = args.below
	local state = args.state or ''

	local root = mw.html.create( 'table' )
		:attr( 'role', 'navigation' )
		:addClass( 'navbox' )
		:addClass( child and 'navbox-subgroup' or 'wikitable mw-collapsible' )
		:addClass( ( not child and state:find( 'collapsed' ) ) and 'mw-collapsed' or nil )
		:addClass( args.bodyclass )

	if title and not child then
		root:tag( 'tr' ):tag( 'th' )
			:addClass( 'navbox-title' )
			:attr( 'colspan', image and 3 or 2 )
			:attr( 'scope', 'col' )
			:wikitext( title )
	end

	-- Hàng phụ phía trên/dưới (above/below) trải hết chiều ngang
	local function wide( text, class )
		if text then
			root:tag( 'tr' ):tag( 'td' )
				:addClass( class )
				:attr( 'colspan', image and 3 or 2 )
				:wikitext( '\n' .. text .. '\n' )
		end
	end

	wide( above, 'navbox-above' )

	-- Thu thập số thứ tự các danh sách hiện có (không cần liên tiếp)
	local nums = {}
	for k in pairs( args ) do
		local n = type( k ) == 'string' and k:match( '^list(%d+)$' )
		if n then nums[ #nums + 1 ] = tonumber( n ) end
	end
	table.sort( nums )

	-- Hàng xen kẽ chẵn/lẻ; evenodd=swap đảo thứ tự cho hộp con
	local swap = args.evenodd == 'swap'
	for i, n in ipairs( nums ) do
		local list = args[ 'list' .. n ]
		if list then
			local group = args[ 'group' .. n ]
			local odd = ( i % 2 == 1 ) ~= swap
			local tr = root:tag( 'tr' )
			if group then
				tr:tag( 'th' ):addClass( 'navbox-group' ):attr( 'scope', 'row' ):wikitext( group )
			end
			tr:tag( 'td' )
				:addClass( 'navbox-list' )
				:addClass( odd and 'navbox-odd' or 'navbox-even' )
				-- Ô chứa hộp con: bỏ đệm để hộp con nằm khít, thẳng hàng với hộp cha
				:addClass( list:find( 'navbox-subgroup', 1, true ) and 'navbox-list--subgroup' or nil )
				:attr( 'colspan', group and 1 or 2 )
				:wikitext( '\n' .. list .. '\n' )
			if image and i == 1 then
				tr:tag( 'td' ):addClass( 'navbox-image' ):attr( 'rowspan', #nums ):wikitext( image )
			end
		end
	end

	wide( below, 'navbox-below' )

	-- Hộp con dùng chung TemplateStyles đã nạp ở hộp cha
	if child then
		return tostring( root )
	end
	return mw.getCurrentFrame():extensionTag {
		name = 'templatestyles', args = { src = 'Module:Navbox/styles.css' }
	} .. tostring( root )
end

-- Điểm vào cho bản mẫu: {{#gọi:Navbox|main}}
function p.main( frame )
	local args = require( 'Module:Arguments' ).getArgs( frame, { parentOnly = true } )
	return p._navbox( args )
end

return p
