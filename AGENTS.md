# AI Agent Instructions for Wiki Lớp Học Mật Ngữ Assets Repository

## Project Context
This repository contains the custom Stylesheets (CSS), JavaScript (JS), and Scribunto Modules (Lua) used for **Wiki Lớp Học Mật Ngữ** (lophocmatngu.wiki). The wiki operates on the MediaWiki engine.

## Synchronization Workflow
- **Tool:** Bidirectional synchronization between this repository and the live wiki is handled via **Pywikibot**.
- **File Mapping:** Directory structures and file names must directly map to their corresponding MediaWiki page titles (e.g., `Module/Example.lua` corresponds to `Module:Example`, and `MediaWiki/Citizen.css` corresponds to `MediaWiki:Citizen.css`).
- **Agent Rule:** Ensure all generated code is immediately compatible with MediaWiki's text-based storage. Avoid local-only configurations, build steps, or file references that cannot be parsed and uploaded directly to the wiki via Pywikibot.

## Primary Skin: Citizen
The wiki utilizes the **Citizen** MediaWiki skin.
- **Documentation:** [Citizen Skin Documentation](https://starcitizentools.github.io/mediawiki-skins-Citizen/)
- **Characteristics:** Citizen is a modern, responsive, mobile-first skin with built-in dark and light theme support.
- **Agent Rule:** All CSS, JavaScript, and HTML structures generated must be fully compatible with the Citizen skin's DOM architecture. 
- **Theming:** Always prioritize utilizing Citizen's native CSS variables (e.g., for background colors, text colors, borders, and spacing) to ensure seamless transitions between dark and light modes. Avoid hardcoding hex colors for general UI elements.

## Technologies & Languages
1. **Lua (Scribunto):** Used for backend template logic and data processing. 
   - Modules must follow MediaWiki Scribunto conventions.
   - Always return a table at the end of the module.
2. **JavaScript (ES6+):** Delivered and executed via MediaWiki's ResourceLoader (`mw.loader`). 
   - Wrap all scripts in standard MediaWiki closures.
   - Use `mw.hook` (e.g., `wikipage.content`) to ensure scripts initialize correctly after Citizen's dynamic page loads or collapsable section interactions.
3. **CSS:** Used for custom styling and overriding default skin behaviors.
   - **Documentation First:** Prioritize all CSS operations based strictly on the provided Citizen skin documentation. If a user's styling request is unclear or lacks explicit documentation coverage, **stop and ask the user for further explanation** before proceeding.
   - **No Native LESS:** MediaWiki does NOT natively support LESS compilation directly within CSS namespaces (e.g., pages like `MediaWiki:Common.css`). You must generate pure, valid CSS unless a specific local compiling step is explicitly provided in the prompt.

## Coding Guidelines
- **Strict Output:** When generating code snippets or structural files, provide the exact, functional code structure. Do not include arbitrary placeholder data unless explicitly requested.
- **Performance:** Ensure all scripts and styles are optimized for fast loading.
- **Responsiveness:** Any custom UI components must be fully responsive, utilizing CSS Flexbox or Grid, adhering to Citizen's mobile-first breakpoints.
- **Namespace Targeting:** Use appropriate MediaWiki body classes (e.g., `.ns-0`, `.page-Specific_Page`) when styling or scripting to avoid unintended global side effects.

## Comments & Documentation
- **Language:** All in-code comments and explanations must be written in **Vietnamese** (**Tiếng Việt**).
- **Doc Blocks:** Every CSS and JavaScript file or major code block must include a standard CSSDoc/JSDoc formatted header.
- **Required Fields:** The documentation block must include the following information:
  - The exact page name containing the code (e.g., `MediaWiki:Common.js` or `MediaWiki:Citizen.css`).
  - A `@desc` tag containing a brief description of the code's functionality (mô tả).
  - An default `@author` tag set to `[[Thành viên:Pisces]] (https://songngu.xyz)`.
  - An `@site` tag featuring the full URL: `https://lophocmatngu.wiki/` followed immediately by the page name.
  - A default `@license` tag set to `CC BY-SA 4.0`.
- **Example Format:**
  ```css
  /**
   * MediaWiki:Common.css
   *
   * @desc     Bảng kiểu toàn cục cho toàn bộ Wiki Lớp Học Mật Ngữ
   * @author   [[Thành viên:Pisces]] (https://songngu.xyz)
   * @site     https://lophocmatngu.wiki/MediaWiki:Common.css
   * @license  CC BY-SA 4.0
   */
  ```
  ```javascript
  /**
   * MediaWiki:Common.js
   *
   * @desc     Mã định dạng và xử lý chức năng chung cho toàn bộ Wiki Lớp Học Mật Ngữ
   * @author   [[Thành viên:Pisces]] (https://songngu.xyz)
   * @site     https://lophocmatngu.wiki/MediaWiki:Common.js
   * @license  CC BY-SA 4.0
   */
  ```