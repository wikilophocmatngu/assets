local p = {}

local metatable = {}
local methodtable = {}

metatable.__index = methodtable

metatable.__tostring = function( self )
	return tostring( self:renderInfobox() )
end


function p.main()
	local libraryUtil = require( 'libraryUtil' )
	local instance = require( 'Module:InfoboxNeue' )
	local args = require( 'Module:Arguments' ).getArgs( frame )

	local sections = {
		{ content = {}, col = args[ 'col' ] or 2 }
	}

	local sectionMap = { default = 1 }

	local currentSection

	if args[ 'image' ] then
		instance:renderImage( args[ 'image' ] )
	end

	if args[ 'indicator' ] then
		instance:renderIndicator( {
			data = args[ 'indicator' ],
			desc = args[ 'indicatorDesc' ],
			class = args[ 'indicatorClass' ]
		} )
	end

	if args[ 'title' ] then
		instance:renderHeader( {
			title = args[ 'title' ],
			subtitle = args[ 'subtitle' ],
		} )
	end

	for i = 1, 50, 1 do
		if args[ 'section' .. i ] then
			currentSection = args[ 'section' .. i ]

			table.insert( sections, {
				title = currentSection,
				subtitle = args[ 'section-subtitle' .. i ],
				col = args[ 'section-col' .. i ] or args[ 'col' ] or 2,
				content = {}
			} )

			sectionMap[ currentSection ] = #sections
		end

		if args[ 'label' .. i ] and args[ 'content' .. i ] then
			table.insert( sections[ sectionMap[ ( currentSection or 'default' ) ] ].content, instance:renderItem( args[ 'label' .. i ], args[ 'content' .. i ] ) )
		end
	end

	for _, section in ipairs( sections ) do
		instance:renderSection( {
			title = section.title,
			subtitle = section.subtitle,
			col = section.col,
			content = section.content,
		} )
	end
end

return p
