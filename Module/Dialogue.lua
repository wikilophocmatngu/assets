--[=[
 * Module:Dialogue
 *
 * @desc Mô đun hiển thị hội thoại cho [[Bản mẫu:Dialogue]]: {{Dialogue|tắt=Tên đầy đủ|Nhân vật|Lời thoại|…|moodN=…|cite=…}}; nhân vật "action" là dòng hành động
 * @author [[Thành viên:Pisces]] (https://songngu.xyz)
 * @site https://lophocmatngu.wiki/Module:Dialogue
 * @license CC BY-SA 4.0
 ]=]

local p = {}

function p._main( args )
	local out = {}
	local line = 0
	local i = 1
	-- Tham số vị trí đi theo cặp: nhân vật, lời thoại
	while args[ i ] do
		line = line + 1
		local who = args[ i ]
		local speech = args[ i + 1 ] or ''
		local mood = args[ 'mood' .. line ]
		local row = mw.html.create( 'div' )
		if mw.ustring.lower( who ) == 'action' then
			-- Dòng hành động: in nghiêng, đặt trong ngoặc vuông
			row:addClass( 'lhmn-dialogue-action' ):tag( 'i' ):wikitext( '[' .. speech .. ']' )
		else
			-- Tên viết tắt (khai báo dạng tắt=Tên đầy đủ) được thay bằng tên đầy đủ
			row:addClass( 'lhmn-dialogue-line' )
				:tag( 'b' ):wikitext( ( args[ who ] or who ) .. ':' ):done()
				:wikitext( ' ' )
			if mood then
				row:tag( 'i' ):wikitext( '(' .. mood .. ') ' )
			end
			row:wikitext( speech )
		end
		out[ #out + 1 ] = tostring( row )
		i = i + 2
	end
	if args.cite then
		out[ #out + 1 ] = tostring( mw.html.create( 'cite' ):addClass( 'lhmn-quote-cite' ):wikitext( '— ' .. args.cite ) )
	end
	-- Dùng chung bảng kiểu dòng ghi nguồn với Module:Quote
	return mw.getCurrentFrame():extensionTag {
		name = 'templatestyles', args = { src = 'Module:Quote/styles.css' }
	} .. table.concat( out )
end

-- Điểm vào cho bản mẫu: {{#invoke:Dialogue|main}} (bản mẫu tự bọc <blockquote>)
function p.main( frame )
	return p._main( require( 'Module:Arguments' ).getArgs( frame, { parentOnly = true } ) )
end

return p
