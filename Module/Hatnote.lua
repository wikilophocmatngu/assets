--------------------------------------------------------------------------------
--                              Module:Hatnote                                --
--                                                                            --
-- This module produces hatnote links and links to related articles. It       --
-- implements the {{hatnote}} and {{format link}} meta-templates and includes --
-- helper functions for other Lua hatnote modules.                            --
--------------------------------------------------------------------------------

local libraryUtil = require('libraryUtil')
local checkType = libraryUtil.checkType
local mArguments -- lazily initialise [[Module:Arguments]]
local yesno -- lazily initialise [[Module:Yesno]]

local p = {}

--------------------------------------------------------------------------------
-- Helper functions
--------------------------------------------------------------------------------

local function getArgs(frame)
    -- Fetches the arguments from the parent frame. Whitespace is trimmed and
    -- blanks are removed.
    mArguments = require('Module:Arguments')
    return mArguments.getArgs(frame, {parentOnly = true})
end

local function removeInitialColon(s)
    -- Removes the initial colon from a string, if present.
    return s:match('^:?(.*)')
end

function p.defaultClasses(inline)
    -- Provides the default hatnote classes as a space-separated string; useful
    -- for hatnote-manipulation modules like [[Module:Hatnote group]].
    return
    (inline == 1 and 'hatnote-inline' or 'hatnote') .. ' ' ..
            'navigation-not-searchable'
end

function p.disambiguate(page, disambiguator)
    -- Formats a page title with a disambiguation parenthetical,
    -- i.e. "Example" → "Example (disambiguation)".
    checkType('disambiguate', 1, page, 'string')
    checkType('disambiguate', 2, disambiguator, 'string', true)
    disambiguator = disambiguator or 'disambiguation'
    return mw.ustring.format('%s (%s)', page, disambiguator)
end

function p.findNamespaceId(link, removeColon)
    -- Finds the namespace id (namespace number) of a link or a pagename. This
    -- function will not work if the link is enclosed in double brackets. Colons
    -- are trimmed from the start of the link by default. To skip colon
    -- trimming, set the removeColon parameter to false.
    checkType('findNamespaceId', 1, link, 'string')
    checkType('findNamespaceId', 2, removeColon, 'boolean', true)
    if removeColon ~= false then
        link = removeInitialColon(link)
    end
    local namespace = link:match('^(.-):')
    if namespace then
        local nsTable = mw.site.namespaces[namespace]
        if nsTable then
            return nsTable.id
        end
    end
    return 0
end

function p.makeWikitextError(msg, helpLink, addTrackingCategory, title)
    -- Formats an error message to be returned to wikitext. If
    -- addTrackingCategory is not false after being returned from
    -- [[Module:Yesno]], and if we are not on a talk page, a tracking category
    -- is added.
    checkType('makeWikitextError', 1, msg, 'string')
    checkType('makeWikitextError', 2, helpLink, 'string', true)
    yesno = require('Module:Yesno')
    title = title or mw.title.getCurrentTitle()
    -- Make the help link text.
    local helpText
    if helpLink then
        helpText = ' ([[' .. helpLink .. '|help]])'
    else
        helpText = ''
    end
    -- Make the category text.
    local category
    if not title.isTalkPage -- Don't categorise talk pages
            and title.namespace ~= 2 -- Don't categorise userspace
            and yesno(addTrackingCategory) ~= false -- Allow opting out
    then
        category = 'Hatnote templates with errors'
        category = mw.ustring.format(
                '[[%s:%s]]',
                mw.site.namespaces[14].name,
                category
        )
    else
        category = ''
    end
    return mw.ustring.format(
            '<strong class="error">Error: %s%s.</strong>%s',
            msg,
            helpText,
            category
    )
end

local curNs = mw.title.getCurrentTitle().namespace
p.missingTargetCat =
--Default missing target category, exported for use in related modules
((curNs ==  0) or (curNs == 14)) and
        'Articles with hatnote templates targeting a nonexistent page' or nil

function p.quote(title)
    --Wraps titles in quotation marks. If the title starts/ends with a quotation
    --mark, kerns that side as with {{-'}}
    local quotationMarks = {
        ["'"]=true, ['"']=true, ['“']=true, ["‘"]=true, ['”']=true, ["’"]=true
    }
    local quoteLeft, quoteRight = -- Test if start/end are quotation marks
    quotationMarks[string.sub(title,  1,  1)],
    quotationMarks[string.sub(title, -1, -1)]
    if quoteLeft or quoteRight then
        title = mw.html.create("span"):wikitext(title)
    end
    if quoteLeft  then title:css("padding-left",  "0.15em") end
    if quoteRight then title:css("padding-right", "0.15em") end
    return '"' .. tostring(title) .. '"'
end

--------------------------------------------------------------------------------
-- Hatnote
--
-- Produces standard hatnote text. Implements the {{hatnote}} template.
--------------------------------------------------------------------------------

local function decorateHatnote(hatnote, options)
    local function getIcon(filename)
        local html = ''
        if type(filename) == 'string' then
            local icon = mw.html.create('span')
            icon
                    :addClass('hatnote-icon')
                    :addClass('metadata')
                    :wikitext('[[File:' .. filename .. '|14px|link=]]')
                    :done()
            html = tostring(icon)
        end
        return html
    end

    local container = mw.html.create('div')
    container
            :addClass('hatnote-container')
            :wikitext(getIcon(options.icon))
            :wikitext(tostring(hatnote))
            :done()
    return container
end

function p.hatnote(frame)
    local args = getArgs(frame)
    local s = args[1]
    if not s then
        return p.makeWikitextError(
                'no text specified',
                'Template:Hatnote#Errors',
                args.category
        )
    end
    return p._hatnote(s, {
        extraclasses = args.extraclasses,
        selfref = args.selfref
    })
end

function p._hatnote(s, options)
    checkType('_hatnote', 1, s, 'string')
    checkType('_hatnote', 2, options, 'table', true)
    options = options or {}
    local inline = options.inline
    local hatnote = mw.html.create(inline == 1 and 'span' or 'div')
    local extraclasses
    if type(options.extraclasses) == 'string' then
        extraclasses = options.extraclasses
    end

    hatnote
            :attr('role', 'note')
            :addClass(p.defaultClasses(inline))
            :addClass(extraclasses)
            :addClass(options.selfref and 'selfref' or nil)
            :wikitext(s)

    -- Decorate WP hatnote to SCW standard
    hatnote = decorateHatnote(hatnote, options)

    return mw.getCurrentFrame():extensionTag{
        name = 'templatestyles', args = { src = 'Module:Hatnote/styles.css' }
    } .. tostring(hatnote)
end

--------------------------------------------------------------------------------
-- Các bản mẫu dẫn hướng: {{Main}}, {{See also}}, {{Further}}, {{For}}
--
-- Trước đây các bản mẫu này gọi tới những hàm chưa tồn tại trong mô đun nên
-- hiển thị lỗi Lua. Phần dưới đây bổ sung đủ bốn hàm, dùng [[Module:Format link]]
-- để định dạng liên kết (hỗ trợ "Trang#Mục" → "Trang § Mục").
--------------------------------------------------------------------------------

-- Gom các tham số vị trí liên tiếp (1, 2, 3, ...) thành danh sách liên kết
local function collectPages(args, from)
    local pages = {}
    local i = from or 1
    while args[i] do
        pages[#pages + 1] = args[i]
        i = i + 1
    end
    return pages
end

-- Định dạng danh sách trang thành "[[A]], [[B]] và [[C]]"
local function pageList(pages, catMissing)
    local links = require('Module:Format link').formatPages(
        { categorizeMissing = catMissing }, pages
    )
    return mw.text.listToText(links, ', ', ' và ')
end

-- Khung dùng chung: "<tiền tố> <danh sách>", có thể đổi nhãn bằng |label=
local function listHatnote(frame, prefix, template, defaultToCurrent)
    local args = getArgs(frame)
    local pages = collectPages(args)
    if #pages == 0 then
        if not defaultToCurrent then
            return p.makeWikitextError(
                'không có trang nào được chỉ định',
                template .. '#Lỗi',
                args.category
            )
        end
        pages = { mw.title.getCurrentTitle().text }
    end
    return p._hatnote(
        (args.label or prefix) .. ' ' .. pageList(pages, p.missingTargetCat),
        { extraclasses = args.extraclasses, selfref = args.selfref }
    )
end

-- {{Main|Trang 1|Trang 2|...}} → "Bài chính: ..."
function p.main(frame)
    return listHatnote(frame, 'Bài chính:', 'Bản mẫu:Main', true)
end

-- {{See also|Trang 1|Trang 2|...}} → "Xem thêm: ..."
function p.seeAlso(frame)
    return listHatnote(frame, 'Xem thêm:', 'Bản mẫu:See also')
end

-- {{Further|Trang 1|Trang 2|...}} → "Thông tin thêm: ..."
function p.further(frame)
    return listHatnote(frame, 'Thông tin thêm:', 'Bản mẫu:Further')
end

-- {{For|chủ đề|Trang 1|Trang 2|...}} → "Đối với chủ đề, xem ..."
-- Thiếu trang thì trỏ tới trang định hướng "<Tên trang> (định hướng)".
function p.For(frame)
    local args = getArgs(frame)
    local use = args[1] or 'các nghĩa khác'
    local pages = collectPages(args, 2)
    if #pages == 0 then
        pages = { p.disambiguate(mw.title.getCurrentTitle().text, 'định hướng') }
    end
    return p._hatnote(
        mw.ustring.format('Đối với %s, xem %s.', use, pageList(pages, p.missingTargetCat)),
        { extraclasses = args.extraclasses, selfref = args.selfref }
    )
end

return p
