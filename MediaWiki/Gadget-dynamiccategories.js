/**
 * MediaWiki:Gadget-dynamiccategories.js
 *
 * @desc     Trang thể loại có ba kiểu xem (mặc định, danh sách kèm hình, lưới hình) kèm nút chọn và phân trang.
 *           Bản dễ đọc của Dynamic Categories trên dev.miraheze.org (bản gadget store), giữ nguyên hành vi upstream.
 *           Tác giả gốc: Canadabonk (https://meta.miraheze.org/wiki/User:Canadabonk)
 *           Mã nguồn gốc: https://github.com/lihaohong6/MirahezeDevScripts/tree/master/gadgets/DynamicCategories
 *           (https://dev.miraheze.org/wiki/Dynamic_Categories)
 * @author   [[Thành viên:Pisces]] (https://songngu.xyz)
 * @site     https://lophocmatngu.wiki/MediaWiki:Gadget-dynamiccategories.js
 * @license  CC BY-SA 4.0
 *
 * Kiểu dáng ở MediaWiki:Gadget-dynamiccategories.css.
 * Cấu hình thêm (tùy chọn): window.dynamicCategoriesConfig, hoặc thẻ #dynamic-categories-config
 * với data-gallery-cat-style / data-catlist-alphabets / data-thumb-size trên trang thể loại.
 * Từ khóa trong nội dung trang: __CLASSICCAT__, __DYNAMICCAT__, __GALLERYCAT__.
 */
$( function () {
	if ( mw.config.get( 'wgNamespaceNumber' ) !== 14 ) {
		return;
	}

	const defaults = {
		defaultCategoryView: 'dynamic',
		galleryCatStyle: 'compacter',
		catlistAlphabets: false,
		thumbSize: 200,
		labels: {
			classic: 'Mặc định',
			dynamic: 'Danh sách kèm hình',
			gallery: 'Hình ảnh',
			prev: 'Trang trước',
			next: 'Trang sau'
		}
	};
	const userConfig = window.dynamicCategoriesConfig || {};
	const pageConfig = ( function () {
		const $el = $( '#dynamic-categories-config' );
		if ( $el.length === 0 ) {
			return {};
		}
		const data = $el[ 0 ].dataset;
		const out = {};
		for ( const key of [ 'galleryCatStyle', 'catlistAlphabets', 'thumbSize' ] ) {
			if ( data[ key ] ) {
				out[ key ] = data[ key ];
			}
		}
		return out;
	}() );
	const config = Object.assign( {}, defaults, userConfig, pageConfig, {
		labels: Object.assign( {}, defaults.labels, userConfig.labels, pageConfig.labels )
	} );
	const labels = config.labels;
	const $pages = $( '#mw-pages' );

	// Bản cũ lưu 'Classic' / 'Dynamic' / 'Gallery'; bản mới dùng chữ thường, không đổi thì danh sách bị ẩn hết
	localStorage.categoryView = ( localStorage.categoryView || config.defaultCategoryView ).toLowerCase();
	$pages.attr( 'class', 'catview-' + localStorage.categoryView );

	// Từ khóa trong nội dung trang ép kiểu xem cho riêng trang đó
	( function () {
		const $content = $( '.mw-parser-output' );
		const html = $content.html();
		const words = [
			[ '__CLASSICCAT__', 'catview-classic' ],
			[ '__DYNAMICCAT__', 'catview-dynamic' ],
			[ '__GALLERYCAT__', 'catview-gallery' ]
		];
		for ( const [ word, cls ] of words ) {
			const i = html.indexOf( word );
			if ( i > -1 ) {
				$content.html( html.slice( 0, i ) + html.slice( i + word.length ) );
				$pages.attr( 'class', cls );
				break;
			}
		}
	}() );

	// Biểu tượng: Font Awesome Free 6.6.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2024 Fonticons, Inc.
	const iconEmpty = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512"><path d="M384 336l-192 0c-8.8 0-16-7.2-16-16l0-256c0-8.8 7.2-16 16-16l140.1 0L400 115.9 400 320c0 8.8-7.2 16-16 16zM192 384l192 0c35.3 0 64-28.7 64-64l0-204.1c0-12.7-5.1-24.9-14.1-33.9L366.1 14.1c-9-9-21.2-14.1-33.9-14.1L192 0c-35.3 0-64 28.7-64 64l0 256c0 35.3 28.7 64 64 64zM64 128c-35.3 0-64 28.7-64 64L0 448c0 35.3 28.7 64 64 64l192 0c35.3 0 64-28.7 64-64l0-32-48 0 0 32c0 8.8-7.2 16-16 16L64 464c-8.8 0-16-7.2-16-16l0-256c0-8.8 7.2-16 16-16l32 0 0-48-32 0z"/></svg>';
	const iconClassic = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512"><path d="M0 96C0 78.3 14.3 64 32 64l384 0c17.7 0 32 14.3 32 32s-14.3 32-32 32L32 128C14.3 128 0 113.7 0 96zM0 256c0-17.7 14.3-32 32-32l384 0c17.7 0 32 14.3 32 32s-14.3 32-32 32L32 288c-17.7 0-32-14.3-32-32zM448 416c0 17.7-14.3 32-32 32L32 448c-17.7 0-32-14.3-32-32s14.3-32 32-32l384 0c17.7 0 32 14.3 32 32z"/></svg>';
	const iconDynamic = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path d="M40 48C26.7 48 16 58.7 16 72l0 48c0 13.3 10.7 24 24 24l48 0c13.3 0 24-10.7 24-24l0-48c0-13.3-10.7-24-24-24L40 48zM192 64c-17.7 0-32 14.3-32 32s14.3 32 32 32l288 0c17.7 0 32-14.3 32-32s-14.3-32-32-32L192 64zm0 160c-17.7 0-32 14.3-32 32s14.3 32 32 32l288 0c17.7 0 32-14.3 32-32s-14.3-32-32-32l-288 0zm0 160c-17.7 0-32 14.3-32 32s14.3 32 32 32l288 0c17.7 0 32-14.3 32-32s-14.3-32-32-32l-288 0zM16 232l0 48c0 13.3 10.7 24 24 24l48 0c13.3 0 24-10.7 24-24l0-48c0-13.3-10.7-24-24-24l-48 0c-13.3 0-24 10.7-24 24zM40 368c-13.3 0-24 10.7-24 24l0 48c0 13.3 10.7 24 24 24l48 0c13.3 0 24-10.7 24-24l0-48c0-13.3-10.7-24-24-24l-48 0z"/></svg>';
	const iconGallery = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512"><path d="M384 96l0 128-128 0 0-128 128 0zm0 192l0 128-128 0 0-128 128 0zM192 224L64 224 64 96l128 0 0 128zM64 288l128 0 0 128L64 416l0-128zM64 32C28.7 32 0 60.7 0 96L0 416c0 35.3 28.7 64 64 64l320 0c35.3 0 64-28.7 64-64l0-320c0-35.3-28.7-64-64-64L64 32z"/></svg>';
	const iconPrev = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 512"><path d="M9.4 233.4c-12.5 12.5-12.5 32.8 0 45.3l192 192c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L77.3 256 246.6 86.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0l-192 192z"/></svg>';
	const iconNext = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 512"><path d="M310.6 233.4c12.5 12.5 12.5 32.8 0 45.3l-192 192c-12.5 12.5-32.8 12.5-45.3 0s-12.5-32.8 0-45.3L242.7 256 73.4 86.6c-12.5-12.5-12.5-32.8 0-45.3s32.8-12.5 45.3 0l192 192z"/></svg>';

	// Hàng nút chọn kiểu xem
	$( '#mw-pages > p:first-of-type' ).after(
		'<div class="catlist-menu"><div class="catlist-selector">' +
		`<span class="catbtn" data-label="${ labels.classic }" title="classic">${ iconClassic }</span>` +
		`<span class="catbtn" data-label="${ labels.dynamic }" title="dynamic">${ iconDynamic }</span>` +
		`<span class="catbtn" data-label="${ labels.gallery }" title="gallery">${ iconGallery }</span>` +
		'</div></div>'
	);
	$pages.find( '.catlist-menu' ).prepend( '<div class="catlist-nav"></div>' );

	if ( config.catlistAlphabets ) {
		$pages.find( '.catlist-nav' ).prepend( '<div class="catlist-alphabet"></div>' );
		const $alphabet = $pages.find( '.catlist-alphabet' );
		for ( const letter of 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ) {
			$alphabet.append( $( '<a>' ).addClass( 'catbtn' ).attr( 'href', '?pagefrom=' + letter ).text( letter ) );
		}
		$alphabet.prepend( $( '<a>' ).addClass( 'catbtn' ).attr( 'href', '?' ).text( '#' ) );
	}

	// Phân trang: lấy liên kết trang trước/sau của MediaWiki, gỡ bản gốc, dựng nút ở trên và dưới danh sách
	const prevHref = $( '#mw-pages > a[href*="pageuntil"]' ).attr( 'href' ) ?? null;
	const nextHref = $( '#mw-pages > a[href*="pagefrom"]' ).attr( 'href' ) ?? null;
	$pages.contents().filter( function () {
		return this.nodeType === Node.TEXT_NODE || this.nodeName === 'A';
	} ).remove();

	if ( prevHref || nextHref ) {
		const $navTop = $pages.find( '.catlist-nav' );
		const $navBottom = $( '<div>' ).addClass( 'catlist-nav' ).appendTo( $pages );
		for ( const $nav of [ $navTop, $navBottom ] ) {
			$nav.prepend( prevHref ?
				$( '<a>' ).addClass( 'catbtn catlist-prev' ).attr( 'href', prevHref ).text( labels.prev ) :
				$( '<span>' ).addClass( 'catbtn catlist-prev' ).text( labels.prev )
			).append( nextHref ?
				$( '<a>' ).addClass( 'catbtn catlist-next' ).attr( 'href', nextHref ).text( labels.next ) :
				$( '<span>' ).addClass( 'catbtn catlist-next' ).text( labels.next )
			);
		}
	}
	$pages.find( '.catlist-prev' ).prepend( iconPrev );
	$pages.find( '.catlist-next' ).append( iconNext );

	$pages.find( '.catlist-selector .catbtn[title="' + $pages.attr( 'class' ).slice( 8 ) + '"]' ).addClass( 'active' );
	$pages.find( '.catlist-selector .catbtn' ).on( 'click', function () {
		const $btn = $( this );
		$btn.addClass( 'active' ).siblings().removeClass( 'active' );
		localStorage.categoryView = $btn.attr( 'title' );
		$pages.attr( 'class', 'catview-' + $btn.attr( 'title' ) );
	} );

	// Dựng hai bản sao danh sách: lưới hình và danh sách kèm hình
	$pages.find( '.mw-category' ).after( '<div class="gallery-catlist"><ul></ul></div>' );
	$pages.find( '.mw-category li' ).clone().appendTo( $pages.find( '.gallery-catlist ul' ) );
	$pages.find( '.mw-category' ).clone().removeClass().addClass( 'dynamic-catlist' ).insertAfter( $pages.find( '.mw-category' ) );

	const galleryStyle = config.galleryCatStyle.toLowerCase();
	if ( galleryStyle === 'compact' || galleryStyle === 'compacter' ) {
		$pages.find( '.gallery-catlist' ).addClass( 'gallery-' + galleryStyle );
	}

	// Ảnh đại diện (PageImages), hỏi API theo lô 50 tiêu đề
	const api = new mw.Api();
	const titles = [];
	$pages.find( '.mw-category li a' ).each( function () {
		titles.push( $( this ).attr( 'title' ) );
	} );
	const batches = [];
	for ( let i = 0; i < titles.length; i += 50 ) {
		batches.push( titles.slice( i, i + 50 ) );
	}

	Promise.all( batches.map( ( batch ) => new Promise( ( resolve, reject ) => {
		api.get( {
			action: 'query',
			format: 'json',
			prop: 'pageimages',
			pithumbsize: config.thumbSize,
			titles: batch
		} ).done( ( data ) => {
			resolve( data.query && data.query.pages ? Object.values( data.query.pages ) : [] );
		} ).fail( reject );
	} ) ) ).then( ( results ) => {
		const byTitle = new Map();
		for ( const page of results.flat() ) {
			byTitle.set( page.title, page );
		}

		$pages.find( '.gallery-catlist li a' ).each( function () {
			const $link = $( this );
			$link.wrapInner( '<div class="catgallery-text"><span></span></div>' );

			// Cho phép xuống dòng sau dấu : và / trong tên dài
			const $span = $link.find( 'span' );
			const text = $span.text();
			$span.empty();
			text.split( /([:/])/ ).forEach( ( part ) => {
				$span.append( document.createTextNode( part ) );
				if ( /[:/]/.test( part ) ) {
					$span.append( document.createElement( 'wbr' ) );
				}
			} );

			const page = byTitle.get( $link.attr( 'title' ) );
			const src = page && page.thumbnail && page.thumbnail.source;
			if ( src ) {
				$( '<img>' ).addClass( 'catgallery-thumb catgallery-img' ).attr( { src: src, alt: page.title } ).prependTo( this );
			} else {
				$link.addClass( 'catgallery-noimg' ).prepend( `<div class="catgallery-thumb">${ iconEmpty }</div>` );
			}
		} );

		$pages.find( '.dynamic-catlist li a' ).each( function () {
			const $link = $( this );
			const page = byTitle.get( $link.attr( 'title' ) );
			const src = page && page.thumbnail && page.thumbnail.source;
			if ( src ) {
				$( '<a>' ).attr( { title: $link.attr( 'title' ), href: $link.attr( 'href' ) } )
					.append( $( '<img>' ).addClass( 'catlink-thumb' ).attr( { src: src, alt: page.title } ) )
					.insertBefore( this );
			} else {
				$link.before( `<div class="catlink-thumb">${ iconEmpty }</div>` );
			}
		} );
	} );

	// Tiện ích DarkMode: không đảo màu ảnh
	if ( $( '.ext-darkmode-link' ).length > 0 ) {
		$pages.find( '> div' ).addClass( 'mw-no-invert' );
	}
} );
