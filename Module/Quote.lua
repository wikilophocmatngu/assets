--[=[
 * Module:Quote
 *
 * @desc Mô đun hiển thị trích dẫn cho [[Bản mẫu:Quote]]: {{Quote|câu nói|người nói|nguồn}} hoặc quote=/speaker=/source=
 * @author [[Thành viên:Pisces]] (https://songngu.xyz)
 * @site https://lophocmatngu.wiki/Module:Quote
 * @license CC BY-SA 4.0
 ]=]

local p = {}

function p._quote( args )
	local quote = args.quote or args[ 1 ]
	local speaker = args.speaker or args[ 2 ]
	local source = args.source or args[ 3 ]
	if not quote then
		return require( 'Module:Error' ).error { message = 'Lỗi: chưa nhập câu trích dẫn (quote).' }
	end

	local root = mw.html.create( 'blockquote' ):addClass( 'lhmn-quote' )
	root:tag( 'p' ):wikitext( quote )

	-- Dòng ghi nguồn: "— Người nói, Nguồn"
	if speaker or source then
		local cite = '— ' .. ( speaker or '' )
		if source then
			cite = cite .. ( speaker and ', ' or '' ) .. source
		end
		root:tag( 'cite' ):addClass( 'lhmn-quote-cite' ):wikitext( cite )
	end

	return mw.getCurrentFrame():extensionTag {
		name = 'templatestyles', args = { src = 'Module:Quote/styles.css' }
	} .. tostring( root )
end

-- Điểm vào cho bản mẫu: {{#invoke:Quote|quote}}
function p.quote( frame )
	return p._quote( require( 'Module:Arguments' ).getArgs( frame, { parentOnly = true } ) )
end

return p
