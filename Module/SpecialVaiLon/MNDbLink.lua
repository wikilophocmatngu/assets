local p = {}
local cursed = mw.ext.SpeciallyCursed

function p.main(frame)
	local subpage = mw.dumpObject(frame:getParent().args[1])
	local testParameter = mw.dumpObject(cursed.request.getText('test'))

	local output = '<p><marquee>The world is your oyster!</marquee></p>'
	output = output .. '<p>Subpage: ' .. cursed.escapeHtml(subpage) .. '</p>'
	output = output .. '<p>?test: ' .. cursed.escapeHtml(testParameter) .. '</p>'
	return output
end

return p
