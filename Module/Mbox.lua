local libraryUtil = require( 'libraryUtil' )
local checkType = libraryUtil.checkType
local mArguments -- lazily initialise [[Module:Arguments]]
local mError     -- lazily initialise [[Module:Error]]

local p = {}

--- Helper function to throw error
--
-- @param msg string - Error message
--
-- @return string - Formatted error message in wikitext
local function makeWikitextError( msg )
	mError = require( 'Module:Error' )
	return mError.error {
		message = 'Error: ' .. msg .. '.'
	}
end

function p.mbox( frame )
	mArguments = require( 'Module:Arguments' )
	local args = mArguments.getArgs( frame )
	local title = args[ 1 ] or args[ 'title' ]
	local text = args[ 2 ] or args[ 'text' ]
	-- Chỉ cần ít nhất một trong hai: tiêu đề hoặc nội dung
	if not title and not text then
		return makeWikitextError(
			'no title or text specified'
		)
	end
	if not title then
		title, text = text, nil
	end
	return p._mbox( title, text, {
		extraclasses = args.extraclasses,
		icon = args.icon
	} )
end

function p._mbox( title, text, options )
	checkType( '_mbox', 1, title, 'string' )
	checkType( '_mbox', 2, text, 'string', true )
	checkType( '_mbox', 3, options, 'table', true )

	options = options or {}
	local mbox = mw.html.create( 'div' )
	local extraclasses
	if type( options.extraclasses ) == 'string' then
		extraclasses = options.extraclasses
	end

	mbox
		:attr( 'role', 'presentation' )
		:addClass( 'mbox' )
		:addClass( extraclasses )

	local mboxTitle = mbox:tag( 'div' ):addClass( 'mbox-title' )

	if options.icon and type( options.icon ) == 'string' then
		mboxTitle:tag( 'div' )
			:addClass( 'mbox-icon metadata' )
			:wikitext( '[[File:' .. options.icon .. '|14px|link=]]' )
			:done()
			:tag( 'div' )
			:wikitext( title )
	else
		mboxTitle:wikitext( title )
	end

	-- Không có nội dung thì không tạo khối .mbox-text (tránh popup rỗng)
	if text then
		mbox:tag( 'div' )
			:addClass( 'mbox-text' )
			:wikitext( text )
	end

	return mw.getCurrentFrame():extensionTag {
		name = 'templatestyles', args = { src = 'Module:Mbox/styles.css' }
	} .. tostring( mbox )
end

return p
