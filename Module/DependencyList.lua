require("strict");

local p = {}
local libraryUtil = require( 'libraryUtil' )
local arr = require( 'Module:Array' )
local yn = require( 'Module:Yesno' )
local param = require( 'Module:Paramtest' )
local dpl = require( 'Module:DPLlua' )
local userError = require("Module:User error")
local mHatnote = require('Module:Hatnote')
local mHatlist = require('Module:Hatnote list')
local moduleIsUsed = false
local COLLAPSE_LIST_LENGTH_THRESHOLD = 1
local MAX_DYNAMIC_REQUIRE_LIST_LENGTH = 30
local dynamicRequireListQueryCache = {}

local builtins = {
	--[[
	["libraryUtil"] = {
		link = "mw:Special:MyLanguage/Extension:Scribunto/Lua reference manual#libraryUtil",
		categories = {},
	}
	]]
	["strict"] = {
		link = "mw:Special:MyLanguage/Extension:Scribunto/Lua reference manual#strict",
		categories = { "Strict mode modules" },
	},
};

--- Used in case 'require( varName )' is found. Attempts to find a string value stored in 'varName'.
---@param content string    The content of the module to search in
---@param varName string
---@return string
local function substVarValue( content, varName )
    local res = content:match( varName .. '%s*=%s*(%b""%s-%.*)' ) or content:match( varName .. "%s*=%s*(%b''%s-%.*)" ) or ''
    if res:find( '^(["\'])[Mm]odule:[%S]+%1' ) and not res:find( '%.%.' ) and not res:find( '%%%a' ) then
        return mw.text.trim( res )
    else
        return ''
    end
end

---@param capture string
---@param content string    The content of the module to search in
---@return string
local function extractModuleName( capture, content )
    capture = capture:gsub( '^%(%s*(.-)%s*%)$', '%1' )

    if capture:find( '^(["\']).-%1$' ) then -- Check if it is already a pure string
        return capture
    elseif capture:find( '^[%a_][%w_]*$' ) then -- Check if if is a single variable
        return substVarValue( content, capture )
    end

    return capture
end

---@param str string
---@return string
local function formatPageName( str )
    local name = mw.text.trim(str)
        :gsub( '^([\'\"])(.-)%1$', function(_, x) return x end ) -- Only remove quotes at start and end of string if both are the same type
        :gsub( '_', ' ' )
        :gsub( '^.', string.upper )
        :gsub( ':.', string.upper )

    return name
end

---@param str string
---@return string
local function formatModuleName( str, allowBuiltins )
	if allowBuiltins then
		local name = mw.text.trim(str)
			-- Only remove quotes at start and end of string if both are the same type
			:gsub([[^(['"])(.-)%1$]], function(_, x) return x end);

		local builtin = builtins[name];
		if builtin then
			return builtin.link .. "|" .. name, builtin;
		end
	end

    local module = formatPageName( str )

    if not string.find( module, '^[Mm]odule:' ) then
        module = 'Module:' .. module
    end

    return module
end

local function dualGmatch( str, pat1, pat2 )
    local f1 = string.gmatch( str, pat1 )
    local f2 = string.gmatch( str, pat2 )
    return function()
        return f1() or f2()
    end
end

--- Used in case a construct like 'require( "Module:wowee/" .. isTheBest )' is found.
--- Will return a list of pages which satisfy this pattern where 'isTheBest' can take any value.
---@param query string
---@return string[]     Sequence of strings
local function getDynamicRequireList( query )
	local isDynamic = true;

    if query:find( '%.%.' ) then
        query = mw.text.split( query, '..', true )
        query = arr.map( query, function(x) return mw.text.trim(x) end )
        query = arr.map( query, function(x) return (x:match('^[\'\"](.-)[\'\"]$') or '%') end )
        query = table.concat( query )
    else
        local _; _, query = query:match( '(["\'])(.-)%1' )

        if query == nil then
			return {}, isDynamic
        end
        
        local replacements;
        query, replacements = query:gsub( '%%%a', '%%' )
		if replacements == 0 then
			isDynamic = false;
		end
    end
    query = query:gsub( '^[Mm]odule:', '' )
    
    if query:find( '^[Dd]ata/' ) then
        return { 'Module:' .. query }, isDynamic;   -- This format will later be used by formatDynamicQueryLink()
    end

    if dynamicRequireListQueryCache[ query ] then
        return dynamicRequireListQueryCache[ query ], isDynamic;
    end

    local list = dpl.ask{
        namespace = 'Module',
        titlematch = query,
        nottitlematch = '%/doc|'..query..'/%',
        distinct = 'strict',
        ignorecase = true,
        ordermethod = 'title',
        count = MAX_DYNAMIC_REQUIRE_LIST_LENGTH + 1,
        skipthispage = 'no',
        allowcachedresults = true,
        cacheperiod = 604800 -- One week
    }

    if #list > MAX_DYNAMIC_REQUIRE_LIST_LENGTH then
        list = { 'Module:' .. query }
    end

    dynamicRequireListQueryCache[ query ] = list

    return list, isDynamic;
end

--- Returns a list of modules loaded and required by module 'moduleName'.
---@param moduleName string
---@param searchForUsedTemplates boolean
---@return string[], string[], string[], string[]
local function getRequireList( moduleName, searchForUsedTemplates )
    local content = mw.title.new( moduleName ):getContent()
    local requireList = arr{}
    local loadDataList = arr{}
    local usedTemplateList = arr{}
    local dynamicRequirelist = arr{}
    local dynamicLoadDataList = arr{}
    local extraCategories = arr{}

    assert( content ~= nil, string.format( '%s does not exist', moduleName ) )

    content = content:gsub( '%-%-%[(=-)%[.-%]%1%]', '' ):gsub( '%-%-[^\n]*', '' ) -- Strip comments

    for match in dualGmatch( content, 'require%s*(%b())', 'require%s*((["\'])%s*[Mm]odule:.-%2)' ) do
        match = mw.text.trim( match )
        match = extractModuleName( match, content )

        if match:find( '%.%.' ) or match:find( '%%%a' ) then
            for _, x in ipairs( getDynamicRequireList( match ) ) do
                table.insert( dynamicRequirelist, x )
            end
        elseif match ~= '' then
        	local builtin;
            match, builtin = formatModuleName( match, true )
            table.insert( requireList, match )
            
			if builtin then
				local builtinCategories = builtin.categories;
				if type(builtinCategories) == "table" then
					for _, x in ipairs(builtinCategories) do
						table.insert(extraCategories, x);
					end
				end
			end
        end
    end

    for match in dualGmatch( content, 'mw%.loadData%s*(%b())', 'mw%.loadData%s*((["\'])%s*[Mm]odule:.-%2)' ) do
        match = mw.text.trim( match )
        match = extractModuleName( match, content )

        if match:find( '%.%.' ) or match:find( '%%%a' ) then
            for _, x in ipairs( getDynamicRequireList( match ) ) do
                table.insert( dynamicLoadDataList, x )
            end
        elseif match ~= '' then
            match = formatModuleName( match, true )
            table.insert( loadDataList, match )
        end
    end
    
    for match in dualGmatch( content, 'mw%.loadJsonData%s*(%b())', 'mw%.loadJsonData%s*((["\'])%s*[Mm]odule:.-%2)' ) do
        match = mw.text.trim( match )
        match = extractModuleName( match, content )

        if match:find( '%.%.' ) or match:find( '%%%a' ) then
            for _, x in ipairs( getDynamicRequireList( match ) ) do
                table.insert( dynamicLoadDataList, x )
            end
        elseif match ~= '' then
            match = formatModuleName( match, true )
            table.insert( loadDataList, match )
        end
    end

    for func, match in string.gmatch( content, 'pcall%s*%(([^,]+),([^%),]+)' ) do
        func = mw.text.trim( func )
        match = mw.text.trim( match )

		local dynList, isDynamic;
        if func == 'require' then
			dynList, isDynamic = getDynamicRequireList(match);
			if (isDynamic == false and #dynList == 1) then
				table.insert(requireList, dynList[1]);
			else for _, x in ipairs(dynList) do
                table.insert( dynamicRequirelist, x )
			end end
        elseif func == 'mw.loadData' then
			dynList, isDynamic = getDynamicRequireList(match);
			if (isDynamic == false and #dynList == 1) then
				table.insert(loadDataList, dynList[1]);
			else for _, x in ipairs(dynList) do
                table.insert( dynamicLoadDataList, x )
			end end
        end
    end

    if searchForUsedTemplates then
        for preprocess in string.gmatch( content, ':preprocess%s*(%b())' ) do
            local function recursiveGMatch( str, pat )
                local list = {}
                local i = 0
                repeat
                    for match in string.gmatch( list[i] or str, pat ) do
                        table.insert( list, match )
                    end
                    i =  i + 1
                until i > #list or i > 100

                i = 0
                return function()
                    i = i + 1
                    return list[i]
                end
            end

            for template in recursiveGMatch( preprocess, '{(%b{})}' ) do
                local name = string.match( template, '{(.-)[|{}]' )
                if name ~= '' then
                    if name:find( ':' ) then
                        local ns = name:match( '^(.-):' )
                        if arr.contains( {'', 'template', 'user'}, ns:lower() ) then
                            table.insert( usedTemplateList, name )
                        elseif ns == ns:upper() then
                            table.insert( usedTemplateList, ns ) -- Probably a magic word
                        end
                    else
                        if name:match( '^%u+$' ) or name == '!' then
                            table.insert( usedTemplateList, name ) -- Probably a magic word
                        else
                            table.insert( usedTemplateList, 'Template:'..name )
                        end
                    end
                end
            end
        end
    end

    requireList = requireList .. dynamicRequirelist:reject( loadDataList )
    requireList = requireList:unique()
    loadDataList = loadDataList .. dynamicLoadDataList:reject( requireList )
    loadDataList = loadDataList:unique()
    usedTemplateList = usedTemplateList:unique()
    extraCategories = extraCategories:unique()
    table.sort( requireList )
    table.sort( loadDataList )
    table.sort( usedTemplateList )
    table.sort( extraCategories )

    return requireList, loadDataList, usedTemplateList, extraCategories
end

--- Returns a list with module and function names used in all '{{#Invoke:moduleName|funcName}}' found on page 'templateName'.
---@param templateName string
---@return table<string, string>[]
local function getInvokeCallList( templateName )
    local content = mw.title.new( templateName ):getContent()
    local invokeList = {}

    assert( content ~= nil, string.format( '%s does not exist', templateName ) )

    for moduleName, funcName in string.gmatch( content, '{{[{|safeubt:}]-#[Ii]nvoke:([^|]+)|([^}|]+)[^}]*}}' ) do
        moduleName = formatModuleName( moduleName )
        funcName = mw.text.trim( funcName )
        if string.find( funcName, '^{{{' ) then
        	funcName = funcName ..  '}}}'
        end
        table.insert( invokeList, {moduleName=moduleName, funcName=funcName} )
    end

    invokeList = arr.unique( invokeList, function(x) return x.moduleName..x.funcName end )
    table.sort( invokeList, function(x, y) return x.moduleName..x.funcName < y.moduleName..y.funcName end )

    return invokeList
end

---@param pageName string
---@param addCategories boolean
---@return string
local function messageBoxUnused( pageName, addCategories )
	local mbox = require( 'Module:Mbox' )._mbox
	local category = addCategories and '[[Category:Unused modules]]' or ''
	return mbox(
		'This module is unused.',
		string.format( 'This module is neither invoked by a template nor required/loaded by another module. If this is in error, make sure to add <code>{{[[Template:Documentation|Documentation]]}}</code>/<code>{{[[Template:No documentation|No&nbsp;documentation]]}}</code> to the calling template\'s or parent\'s module documentation.', 
			pageName 
		),
		{ icon = 'WikimediaUI-Alert.svg' }
	) .. category
end

local function collapseList( list, id, listType )
    local text = string.format( '%d %s', #list, listType )
    local button = '<span>' .. text .. ':</span>&nbsp;'
    local content = mHatlist.andList( list, false )

    return { tostring( button ) .. tostring( content ) }
end

--- Creates a link to [[Special:Search]] showing all pages found by getDynamicRequireList() in case it found more than MAX_DYNAMIC_REQUIRE_LIST_LENGTH pages.
---@param query string      @This will be in a format like 'Module:Wowee/%' or 'Module:Wowee/%/data'
---@return string
local function formatDynamicQueryLink( query )
    local prefix = query:match( '^([^/]+)' )
    local linkText = query:gsub( '%%', '&lt; ... &gt;' )

    query = query:gsub( '^Module:',  '' )

    query = query:gsub( '([^/]+)/?', function ( match )
        if match == '%' then
            return '\\/[^\\/]+'
        else
            return '\\/"' .. match .. '"'
        end
    end )

    query = query:gsub( '^\\/', '' )

    query = string.format(
        'intitle:/%s%s/i -intitle:/%s\\/""/i -intitle:doc prefix:"%s"',
        query,
        query:find( '"$' ) and '' or '""',
        query,
        prefix
    )

    return string.format( '<span class="plainlinks">[%s %s]</span>', tostring( mw.uri.fullUrl( 'Special:Search', { search = query } ) ), linkText )
end

---@param templateName string
---@param addCategories boolean
---@param invokeList table<string, string>[]    @This is the list returned by getInvokeCallList()
---@return string
local function formatInvokeCallList( templateName, addCategories, invokeList )
    local category = addCategories and '[[Category:Lua-based templates]]' or ''
    local res = {}

    for _, item in ipairs( invokeList ) do
    	local msg = string.format(
    		"'''%s''' invokes function '''%s''' in [[%s]] using [[Star Citizen:Lua|Lua]].",
    		templateName,
    		item.funcName,
    		item.moduleName
    	)
        table.insert( res, mHatnote._hatnote( msg, { icon='WikimediaUI-Code.svg' } ) )
    end

    if #invokeList > 0 then
        table.insert( res, category )
    end

    return table.concat( res )
end

---@param moduleName string
---@param addCategories boolean
---@param whatLinksHere string    @A list generated by a dpl of pages in the Template namespace which link to moduleName.
---@return string
local function formatInvokedByList( moduleName, addCategories, whatLinksHere )
    local function lcfirst( str )
		return string.gsub( str, '^[Mm]odule:.', string.lower )
	end

    local templateData = arr.map( whatLinksHere, function(x) return {templateName=x, invokeList=getInvokeCallList(x)} end )
    templateData = arr.filter( templateData, function(x)
        return arr.any( x.invokeList, function(y)
            return lcfirst(y.moduleName) == lcfirst(moduleName)
        end )
    end )

    local invokedByList = {}

    for _, template in ipairs( templateData ) do
        for _, invoke in ipairs( template.invokeList ) do
            table.insert( invokedByList, string.format( "function '''%s''' is invoked by [[%s]]", invoke.funcName, template.templateName ) )
        end
    end

    table.sort( invokedByList)

    local res = {}

    if #invokedByList > COLLAPSE_LIST_LENGTH_THRESHOLD then
    	local msg = string.format(
    		"'''%s''' is invoked by %s.",
    		moduleName,
    		collapseList( invokedByList, 'invokedBy', 'templates' )[1]
    	)
        table.insert( res, mHatnote._hatnote( msg, { icon='WikimediaUI-Code.svg' } ) )
    else
	    for _, item in ipairs( invokedByList ) do
	    	local msg = string.format(
	    		"'''%s's''' %s.",
	    		moduleName,
	    		item
	    	)
        	table.insert( res, mHatnote._hatnote( msg, { icon='WikimediaUI-Code.svg' } ) )
	    end
    end

    if #templateData > 0 then
        moduleIsUsed = true
        table.insert( res, (addCategories and '[[Category:Template invoked modules]]' or '') )
    end

    return table.concat( res )
end

---@param moduleName string
---@param addCategories boolean
---@param whatLinksHere string      @A list generated by a dpl of pages in the Module namespace which link to moduleName.
---@return string
local function formatRequiredByList( moduleName, addCategories, whatLinksHere )
    local childModuleData = arr.map( whatLinksHere, function ( title )
        local requireList, loadDataList = getRequireList( title )
        return {name=title, requireList=requireList, loadDataList=loadDataList}
    end )

    local requiredByList = arr.map( childModuleData, function ( item )
        if arr.any( item.requireList, function(x) return x:lower()==moduleName:lower() end ) then
            if item.name:find( '%%' ) then
                return formatDynamicQueryLink( item.name )
            else
                return '[[' .. item.name .. ']]'
            end
        end
    end )

    local loadedByList = arr.map( childModuleData, function ( item )
        if arr.any( item.loadDataList, function(x) return x:lower()==moduleName:lower() end ) then
            if item.name:find( '%%' ) then
                return formatDynamicQueryLink( item.name )
            else
                return '[[' .. item.name .. ']]'
            end
        end
    end )

    if #requiredByList > 0 or #loadedByList > 0 then
        moduleIsUsed  = true
    end

    if #requiredByList > COLLAPSE_LIST_LENGTH_THRESHOLD then
        requiredByList = collapseList( requiredByList, 'requiredBy', 'modules' )
    end

    if #loadedByList > COLLAPSE_LIST_LENGTH_THRESHOLD then
        loadedByList = collapseList( loadedByList, 'loadedBy', 'modules' )
    end

    local res = {}

    for _, requiredByModuleName in ipairs( requiredByList ) do
    	local msg = string.format(
    		"'''%s''' is required by %s.",
    		moduleName,
    		requiredByModuleName
    	)
        table.insert( res, mHatnote._hatnote( msg, { icon='WikimediaUI-Code.svg' } ) )
    end

    if #requiredByList > 0 then
        table.insert( res, (addCategories and '[[Category:Modules required by modules]]' or '') )
    end

    for _, loadedByModuleName in ipairs( loadedByList ) do
    	local msg = string.format(
    		"'''%s''' is loaded by %s.",
    		moduleName,
    		requiredByModuleName
    	)
        table.insert( res, mHatnote._hatnote( msg, { icon='WikimediaUI-Code.svg' } ) )
    end

    if #loadedByList > 0 then
        table.insert( res, (addCategories and '[[Category:Module data]]' or '') )
    end

    return table.concat( res )
end

local function formatRequireList( currentPageName, addCategories, requireList )
    local res = {}

    if #requireList > COLLAPSE_LIST_LENGTH_THRESHOLD then
        requireList = collapseList( requireList, 'require', 'modules' )
    end

    for _, requiredModuleName in ipairs( requireList ) do
    	local msg = string.format(
    		"'''%s''' requires %s.",
    		currentPageName,
    		requiredModuleName
    	)
        table.insert( res, mHatnote._hatnote( msg, { icon='WikimediaUI-Code.svg' } ) )
    end

    if #requireList > 0 then
        table.insert( res, (addCategories and '[[Category:Modules requiring modules]]' or '') )
    end

    return table.concat( res )
end

local function formatLoadDataList( currentPageName, addCategories, loadDataList )
    local res = {}

    if #loadDataList > COLLAPSE_LIST_LENGTH_THRESHOLD then
        loadDataList = collapseList( loadDataList, 'loadData', 'modules' )
    end

    for _, loadedModuleName in ipairs( loadDataList ) do
    	local msg = string.format(
    		"'''%s''' loads data from %s.",
    		currentPageName,
    		loadedModuleName
    	)
        table.insert( res, mHatnote._hatnote( msg, { icon='WikimediaUI-Code.svg' } ) )
    end

    if #loadDataList > 0 then
        table.insert( res, (addCategories and '[[Category:Modules using data]]' or '') )
    end

    return table.concat( res )
end

local function formatUsedTemplatesList( currentPageName, addCategories, usedTemplateList )
    local res = {}

    if #usedTemplateList > COLLAPSE_LIST_LENGTH_THRESHOLD then
        usedTemplateList = collapseList( usedTemplateList, 'usedTemplates', 'templates' )
    end

    for _, templateName in ipairs( usedTemplateList ) do
    	local msg = string.format(
    		"'''%s''' transcludes  [[%s]] using <samp>frame:preprocess()</samp>.",
    		currentPageName,
    		templateName
    	)
        table.insert( res, mHatnote._hatnote( msg, { icon='WikimediaUI-Code.svg' } ) )
    end

    return table.concat( res )
end

function p.main( frame )
    local args = frame:getParent().args
    return p._main( args[1], args.category, args.isUsed )
end

---@param currentPageName string|nil
---@param addCategories boolean|string|nil
---@return string
function p._main( currentPageName, addCategories, isUsed )
    libraryUtil.checkType( 'Module:RequireList._main', 1, currentPageName, 'string', true )
    libraryUtil.checkTypeMulti( 'Module:RequireList._main', 2, addCategories, {'boolean', 'string', 'nil'} )
    libraryUtil.checkTypeMulti( 'Module:RequireList._main', 3, isUsed, {'boolean', 'string', 'nil'} )

    local title = mw.title.getCurrentTitle()

    -- Leave early if not in module or template namespace
    if param.is_empty( currentPageName ) and
        ( not arr.contains( {'Module', 'Template'}, title.nsText ) ) then
        return ''
    end

    currentPageName = param.default_to( currentPageName, title.fullText )
    currentPageName = string.gsub( currentPageName, '/[Dd]oc$', '' )
    currentPageName = formatPageName( currentPageName )
    addCategories = yn( param.default_to( addCategories, title.subpageText~='doc' ) )
    moduleIsUsed = yn( param.default_to( isUsed, false ) )

    if title.text:lower():find( 'sandbox' ) then
    	moduleIsUsed = true -- Don't show sandbox modules as unused
    end

    if currentPageName:find( '^Template:' ) then
        local ok, invokeList = pcall( getInvokeCallList, currentPageName )
		if ok then
        	return formatInvokeCallList( currentPageName, addCategories, invokeList )
        else
			return userError(invokeList)
		end
    end

    local whatTemplatesLinkHere, whatModulesLinkHere = dpl.ask( {
        namespace = 'Template',
        linksto = currentPageName,
        distinct = 'strict',
        ignorecase = true,
        ordermethod = 'title',
        allowcachedresults = true,
        cacheperiod = 604800 -- One week
    }, {
        namespace = 'Module',
        linksto = currentPageName,
        nottitlematch = '%/doc%|' .. currentPageName:gsub( 'Module:', '' ),
        distinct = 'strict',
        ignorecase = true,
        ordermethod = 'title',
        allowcachedresults = true,
        cacheperiod = 604800 -- One week
    } )

    local requireList, loadDataList, usedTemplateList, extraCategories;
    do
    	local ok;
	    ok, requireList, loadDataList, usedTemplateList, extraCategories = pcall(getRequireList, currentPageName, true);
	    if not ok then
	    	return userError(requireList);
	    end
    end

    requireList = arr.map( requireList, function ( moduleName )
        if moduleName:find( '%%' ) then
            return formatDynamicQueryLink( moduleName )
        else
            return '[[' .. moduleName .. ']]'
        end
    end )

    loadDataList = arr.map( loadDataList, function ( moduleName )
        if moduleName:find( '%%' ) then
            return formatDynamicQueryLink( moduleName )
        else
            return '[[' .. moduleName .. ']]'
        end
    end )

    usedTemplateList = arr.map( usedTemplateList, function( templateName )
        if string.find( templateName, ':' ) then -- Real templates are prefixed by a namespace, magic words are not
            return '[['..templateName..']]'
        else
            return "'''&#123;&#123;"..templateName.."&#125;&#125;'''" -- Magic words don't have a page so make them bold instead
        end
    end )

    local res = {}

    table.insert( res, formatInvokedByList( currentPageName, addCategories, whatTemplatesLinkHere ) )
    table.insert( res, formatRequireList( currentPageName, addCategories, requireList ) )
    table.insert( res, formatLoadDataList( currentPageName, addCategories, loadDataList ) )
    table.insert( res, formatUsedTemplatesList( currentPageName, addCategories, usedTemplateList ) )
    table.insert( res, formatRequiredByList( currentPageName, addCategories, whatModulesLinkHere ) )

	if addCategories then
		extraCategories = arr.map(extraCategories, function(categoryName)
			return "[[Category:" .. categoryName .. "]]";
		end);
		
		table.insert(res, table.concat(extraCategories));
	end

    if not moduleIsUsed then
        table.insert( res, 1, messageBoxUnused( currentPageName:gsub( 'Module:', '' ), addCategories ) )
    end

    return table.concat( res )
end

return p
-- </nowiki>
