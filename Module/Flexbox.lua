local mArguments --initialize lazily
local getArgNums = require('Module:Common').getArgNums
local p = {}


--Implements {{flexbox}} from the frame
function p.flexbox(frame)
	mArguments = require('Module:Arguments')
	return p._flexbox(mArguments.getArgs(frame), frame)
end

function p._flexbox(args, frame)
	if not args then
		return 'Missing arguments'
	end

	local html = mw.html.create('div'):addClass('template-flexbox')
	local columns = args['columns']
	local rows = args['rows']
	local gap = args['gap'] or '0.5rem'
	local direction

	if columns then
		direction = 'row'
	elseif rows then
		direction = 'column'
	end

	html:css('--template-flexbox-columns', columns or rows )
	html:css('--template-flexbox-direction', direction )
	html:css('--template-flexbox-gap', gap )

	for i, _ in ipairs(getArgNums('content', args)) do
		local num = tostring(i)
		local content = args['content' .. num]
		if not content then return end

		local item = mw.html.create('div'):addClass('template-flexbox-item')
		local span = args['span' .. num] or '1'
		item:css('--template-flexbox-item-span', span)
		item:wikitext(content)
		html:node(item)
	end

	return frame:extensionTag {
		name = 'templatestyles', args = { src = 'Module:Flexbox/styles.css' }
	} .. tostring(html)
end

return p
