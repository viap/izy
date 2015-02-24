
var matched, browser;

// Use of jQuery.browser is frowned upon.
// More details: http://api.jquery.com/jQuery.browser
// jQuery.uaMatch maintained for back-compat
jQuery.uaMatch = function( ua ) {
    ua = ua.toLowerCase();

    var match = /(chrome)[ \/]([\w.]+)/.exec( ua ) ||
        /(webkit)[ \/]([\w.]+)/.exec( ua ) ||
        /(opera)(?:.*version|)[ \/]([\w.]+)/.exec( ua ) ||
        /(msie) ([\w.]+)/.exec( ua ) ||
        ua.indexOf("compatible") < 0 && /(mozilla)(?:.*? rv:([\w.]+)|)/.exec( ua ) ||
        [];

    return {
        browser: match[ 1 ] || "",
        version: match[ 2 ] || "0"
    };
};

matched = jQuery.uaMatch( navigator.userAgent );
browser = {};

if ( matched.browser ) {
    browser[ matched.browser ] = true;
    browser.version = matched.version;
}

// Chrome is Webkit, but Webkit is also Safari.
if ( browser.chrome ) {
    browser.webkit = true;
} else if ( browser.webkit ) {
    browser.safari = true;
}

jQuery.browser = browser;




var lineSlider, albumSlider, playlistSlider, materialsSlider;
var isBrandMode = function(){
	return $(".h-wrapper-inner").hasClass("brand-mode");
}
var isShelfMode = function(){
	return $("body").hasClass("shelf-mode--on");
}
var isMenuOpen = function(){
	return $(".slide-menu").hasClass("slide-menu--open");
}
var brickSliders_setWidth = function(lineSlider, albumSlider, playlistSlider, materialsSlider, width){
	console.log("setwidth");
	console.log(width);
	if (lineSlider) console.log("reload lineSlider");
	if (lineSlider) lineSlider.reloadSlider({slideWidth: width});
	if (playlistSlider) playlistSlider.reloadSlider({slideWidth: width});
	if (albumSlider) albumSlider.reloadSlider({slideWidth: width});
	if (materialsSlider) materialsSlider.reloadSlider({slideWidth: width});
}
var brickSliders_reload = function(lineSlider, albumSlider, playlistSlider, materialsSlider){
	if ($('.widget-slider__line .widget__list-slider').length >0 ) {
		if (!lineSlider){
			lineSlider = $('.widget-slider__line .widget__list-slider').bxSlider({
				minSlides: 4,
				maxSlides: 6,
				slideWidth: 150,
				slideMargin: 20,
				speed: 700,
				pager: false,
				prevSelector: '.widget-slider__line .widget-section-slider_prev',
				nextSelector: '.widget-slider__line .widget-section-slider_next',
				nextText: "",
				prevText: "",
				preloadImages: "all"
			});
		}
		else{
			lineSlider.reloadSlider();
		}

		if ( $(".widget-slider__line .bx-wrapper").width() < $(".widget-slider__line .widget__list-slider_wrap").width() ){
			$(".widget-section-slider_prev, .widget-section-slider_next", ".widget-slider__line ").hide();
		}
	}

	if ($('.widget-slider__playlist .widget__list-slider').length > 0) {
		if (!playlistSlider){
			playlistSlider = $('.widget-slider__playlist .widget__list-slider').bxSlider({
				minSlides: 4,
				maxSlides: 6,
				slideWidth: 150,
				slideMargin: 20,
				speed: 700,
				pager: false,
				prevSelector: '.widget-slider__playlist .widget-section-slider_prev',
				nextSelector: '.widget-slider__playlist .widget-section-slider_next',
				nextText: "",
				prevText: "",
				preloadImages: "all"
			});
		}
		else{
			playlistSlider.reloadSlider();
		}
		if ( $(".widget-slider__playlist .bx-wrapper").width() < $(".widget-slider__playlist .widget__list-slider_wrap").width() ){
			$(".widget-section-slider_prev, .widget-section-slider_next", ".widget-slider__playlist ").hide();
		}
	}

	if ($('.widget-slider__albums .widget__list-slider').length > 0) {
		if (!albumSlider){
			albumSlider = $('.widget-slider__albums .widget__list-slider').bxSlider({
				minSlides: 4,
				maxSlides: 5,
				slideWidth: 150,
				slideMargin: 20,
				speed: 700,
				pager: false,
				prevSelector: '.widget-slider__albums .widget-section-slider_prev',
				nextSelector: '.widget-slider__albums .widget-section-slider_next',
				nextText: "",
				prevText: "",
				preloadImages: "all"
			});
		}
		else{
			albumSlider.reloadSlider();
		}
		if ( $(".widget-slider__albums .bx-wrapper").width() < $(".widget-slider__albums .widget__list-slider_wrap").width() ){
			$(".widget-section-slider_prev, .widget-section-slider_next", ".widget-slider__albums ").hide();
		}
	}

	if ($('.widget-slider__materials .widget__list-slider').length > 0) {
		if ( !materialsSlider ){
			materialsSlider = $('.widget-slider__materials .widget__list-slider').bxSlider({
				minSlides: 4,
				maxSlides: 5,
				slideWidth: 150,
				slideMargin: 20,
				speed: 700,
				pager: false,
				prevSelector: '.widget-slider__materials .widget-section-slider_prev',
				nextSelector: '.widget-slider__materials .widget-section-slider_next',
				nextText: "",
				prevText: "",
				preloadImages: "all"
			});
		}
		else{
			materialsSlider.reloadSlider();
		}
		if ( $(".widget-slider__materials .bx-wrapper").width() < $(".widget-slider__materials .widget__list-slider_wrap").width() ){
			$(".widget-section-slider_prev, .widget-section-slider_next", ".widget-slider__materials").hide();
		}
	}
}

var widget_mh = 1165,  // 3 group_item
	widget_scroll_obj = [];



$(document).ready(function(){
	var
		tags_menu = ".slide-menu",
		menu_height = $(".slide-menu-wrap").height(),
		header_height = $(".b-header").height(),
		control_height = $(".slide-menu-control").height(),
		side_control_margin_top = parseInt($(".side-control").not(":first-child").css("margin-top")),
		slide_menu_control = ".slide-menu-control",
		menu_bottom_height = $(".slide-menu-bottom").height(),

		menu_shadow = ".slide-menu-bottom",
		right_aside = ".right-aside",
		side_panel = ".b-side-panel",

		right_aside_min_gap = 20,
		side_panel_min_gap = 30,
		brand_start_pos = 330,
		right_aside_min_pos = header_height + right_aside_min_gap,
		side_min_pos = header_height + control_height + side_panel_min_gap,

		_body = $("body"),
		_widget = $(".b-media-widget"),
		_media_box = ".b-media-box",
		wrapper = ($(".b-container-main-wrap").length) ? $(".b-container-main-wrap") : $(".h-wrapper-inner");

	var move_fix_elements = function(){
		var left = $(document).scrollLeft(),
			new_left = $("body")[0].scrollWidth/2 - left,
			new_right = $("body")[0].offsetWidth - $("body")[0].scrollWidth/2 + left;

		/*$(right_aside).css("left", new_left);*/
		/*$(side_panel).css("right", new_right);*/
	}
	//scroll fix-elemets on brand-mode
	/*if ( isBrandMode() ){
		var right_aside_new_pos = brand_start_pos - $(document).scrollTop(),
			side_new_pos =  brand_start_pos - $(document).scrollTop();

			if (right_aside_new_pos < right_aside_min_pos) {right_aside_new_pos = right_aside_min_pos;}
			if (side_new_pos < side_min_pos) {side_new_pos = side_min_pos;}

			$(right_aside).css("top", right_aside_new_pos + "px");
			$(side_panel).css("top", side_new_pos + "px");*/

		var scroll_fix_elem = function(){
			var min_margin = 20,
				start_margin = 260,
				min_left_margin = $(".slide-menu-control").height() + min_margin,
				new_pos = start_margin - $(document).scrollTop();


			if (new_pos < min_margin) {
				new_pos = min_margin;
			}
			if (new_pos <  min_left_margin) {
				$(".b-side-panel").css("top", min_left_margin - new_pos + "px");
			}
			else{
				$(".b-side-panel").css("top", 0 + "px");
			}

			$(".fix_layer_inner").css( "margin-top", new_pos + "px");

			/*right_aside_new_pos = brand_start_pos - $(document).scrollTop();
			side_new_pos =  brand_start_pos - $(document).scrollTop();

			if (right_aside_new_pos < right_aside_min_pos) {right_aside_new_pos = right_aside_min_pos;}
			if (side_new_pos < side_min_pos) {side_new_pos = side_min_pos;}

			if ( isMenuOpen() ){
				var right_aside_padding = 0;
				var side_padding = 0;

				if (right_aside_new_pos < ( right_aside_min_pos + menu_height) ){
					right_aside_padding = right_aside_min_pos + menu_height - right_aside_new_pos;
				}
				if (side_new_pos < ( side_min_pos + menu_height) ){
					side_padding = side_min_pos + menu_height - side_new_pos;
				}
				$(right_aside).css("padding-top",  padding + "px");
				$(side_panel).css("padding-top",  0 + "px");
			}

			$(right_aside).css("top", right_aside_new_pos + "px");
			$(side_panel).css("top", side_new_pos + "px");*/
		}

		$(window).on("scroll", scroll_fix_elem)
	/*}*/

	$(".container__brick .brick-i_drndr").draggable({
		stop: function(event, ui) {
			$(this).parents('.b-container__brick').find('.brick-i__hover').hide();
		},
//		drag: function() {
//			counts[ 1 ]++;
//			updateCounterStatus($drag_counter, counts[ 1 ]);
//		},
//		stop: function() {
//			counts[ 2 ]++;
//			updateCounterStatus($stop_counter, counts[ 2 ]);
//		}
		cursor: 'move',
		cursorAt: { top: 20, left: 20 },
		helper: function( event ) {
			var _this  = $(event.target);
			var _helper = _this.find(".brick__clone-dnd").clone();
			_helper.removeClass("brick__clone-dnd--hidden");
			_helper.prependTo("body");
			return _helper;
		},
		start: function(){
      		$(this).data("startingScrollTop",$(document).scrollTop());
  		 },
	   drag: function(event,ui){
	      var st = parseInt($(this).data("startingScrollTop"));
	      ui.helper.position.top -= $(document).scrollTop() - st;
	   }/*,
		appendTo: ".b-container-main-wrap"*/
	});

	/*$(".b-media-box").not(".media-box__profile").droppable({
		accept: function(el){
			return el.hasClass("brick-i_drndr--" + $(this).data("content"));
		},
		activate: function(event, ui){
			$(this).addClass("b-media-box--dropp");
		},
		deactivate: function(event, ui){
			$(this).removeClass("b-media-box--dropp");
		},
		out: function(event, ui){
			ui.helper.find(".brick__clone-dnd-status").attr("class", "brick__clone-dnd-status");
		},
		drop: function(){
			$(this).addClass("b-media-box--event").removeClass("b-media-box--dropp");
			setTimeout(function() { $(".b-media-box").removeClass("b-media-box--event") }, 2000);
		},
		greedy: true
	})*/
	$(".b-drop-control").droppable({
		accept: function(el){
			return el.hasClass("brick-i_drndr--" + $(this).parents(".b-media-box").data("content"));
		},
		hoverClass: "b-drop-control--active",
		tolerance: "pointer",
		over: function(event, ui) {
			var _this = $(this);
			var _status = ui.helper.find(".brick__clone-dnd-status");
			_status.attr("class", "brick__clone-dnd-status");

			if (_this.hasClass("b-drop-control--play")){
				_status.addClass("brick__clone-dnd-status--play")
			}
			if (_this.hasClass("b-drop-control--turn") || _this.hasClass("b-drop-control--add")){
				_status.addClass("brick__clone-dnd-status--add")
			}
		}
	})


	$(document).on('click', '.b-media-full_tumbler',  function(){
		var _this = $(this);

		_body.toggleClass("shelf-mode");

		if (!_body.hasClass("shelf-mode--on")){
			_body.attr("data-scr", $(document).scrollTop());
			wrapper.removeClass("shelf-wrap");
		}
		if  (_body.hasClass("shelf-mode")){
			var _this_media_box = _this.parents(_media_box);
			$(".b-media-widget").find(".move_helper").addClass("move_helper--type-" + _this_media_box.data("content"));

			_body.addClass("shelf-mode--on");

			_this_media_box.addClass("b-media-box--open");


			$(this).addClass("b-media-full_tumbler--big-size").insertBefore(_this_media_box);
			wrapper.addClass("shelf-wrap");

			//$(".b-widget-content").css("min-height", ( Math.max( 770, _body.height() - 70, right_aside.height() ) ) + "px");
			$(".b-widget-content").css("min-height", ( Math.max( widget_mh, _body.height() - 90, $(right_aside).height() ) ) + "px");

			//$(".b-widget-content").height(Math.max(right_aside.height()));

			$(window).off("scroll", scroll_fix_elem);
			if (isBrandMode()){
				if (parseInt($(right_aside).css("top")) != right_aside_min_pos){
					$(right_aside).animate({top: right_aside_min_pos}, 1500);
				}
			}
			$(document).scrollTop(0);

			$(".search_suggest_inner").each(function(){
				$(this).width($(this).parents(".group_item").width());
				var arr = [];
				arr.push($(this));
				/*arr.push($(this).jScrollPane_n());*/
				widget_scroll_obj.push(arr);
			})
			if  ( $(".b-widget-content--brick").is(':visible') ){
				brickSliders_reload();
			}
		}
		else{
			var _this_media_box  = _this.siblings(".b-media-box--open");
			_body.removeClass("shelf-mode--on");

			_this_media_box.removeClass("b-media-box--open");

			$(this).removeClass("b-media-full_tumbler--big-size");
			_this_media_box.find(".b-media__controls").prepend($(this));

			var right_aside_new_top = ( ( isBrandMode() ) ? brand_start_pos : right_aside_min_pos )- _body.attr("data-scr");

			if (right_aside_new_top < right_aside_min_pos) {right_aside_new_top = right_aside_min_pos;}
			if (parseInt($(right_aside).css("top")) != right_aside_new_top){
				$(right_aside).animate({top: right_aside_new_top}, 1500);
			}
			$(window).on("scroll", scroll_fix_elem);
			$(document).scrollTop(_body.attr("data-scr"));
		}


		/*$('.widget-slider__albums').delegate('.slider-tumbler__track.inact', 'click', function() {
			$(this).removeClass('inact');
			$('.slider-tumbler__album').addClass('inact');
			albumSlider.destroySlider();
			$('.widget-slider__albums .widget__slider-album').hide();
			$('.widget-slider__albums .widget__slider-track').show();
			trackSlider = $('.widget-slider__albums .widget__slider-track').bxSlider({
				minSlides: 4,
				maxSlides: 5,
				slideWidth: 150,
				slideMargin: 20,
				speed: 700,
				pager: false,
				prevSelector: '.widget-slider__albums .widget-section-slider_prev',
				nextSelector: '.widget-slider__albums .widget-section-slider_next',
				nextText: "",
				prevText: ""
			});
		});

		$('.widget-slider__albums').delegate('.slider-tumbler__album.inact', 'click', function() {
			$(this).removeClass('inact');
			$('.slider-tumbler__track').addClass('inact');
			trackSlider.destroySlider();
			$('.widget-slider__albums .widget__slider-track').hide();
			$('.widget-slider__albums .widget__slider-album').show();
			albumSlider = $('.widget-slider__albums .widget__slider-album').bxSlider({
					minSlides: 4,
					maxSlides: 5,
					slideWidth: 150,
					slideMargin: 20,
					speed: 700,
					pager: false,
					prevSelector: '.widget-slider__albums .widget-section-slider_prev',
					nextSelector: '.widget-slider__albums .widget-section-slider_next',
					nextText: "",
					prevText: ""
				});
		});*/

	});
	$('.container__brick').mouseenter( function(){
		$(this).find('.brick-i__hover, .brick-i_favorite').stop(true, true).delay(300).fadeIn(200);
		/*$(this).parents(".container__brick").find(".brick-i_favorite").stop(true, true).delay(300).fadeIn(200);*/
	}).mouseleave( function(){
		$(this).find('.brick-i__hover, .brick-i_favorite').stop(true, true).hide();
		/*$(this).parents(".container__brick").find(".brick-i_favorite").stop(true, true).hide();*/
	});


$(window).load(function(){

	/*
	перенесено
	if ($('.tag-slider').length > 0){

		var amount = 0;

		$(".tag-slider li").each(function(indx, element){
			amount += $(this).outerWidth(true);
		})
		amount  = ((amount + 260) / $('.tag-slider').find("li").length ) *5;

		$('.tag-slider').mCustomScrollbar({
						horizontalScroll:true,
						scrollButtons:{
								enable:true,
								scrollType:"pixels",
								scrollAmount: amount,
								scrollSpeed: 1000
						},
						advanced:{autoExpandHorizontalScroll:true,
							updateOnContentResize: true
						},
						callbacks:{
							onTotalScroll: function(){ $('.mCSB_buttonRight', this).addClass('mCSB_buttonRight--disabled');},
							onTotalScrollBack: function(){ $('.mCSB_buttonLeft', this).addClass('mCSB_buttonLeft--disabled');},
							onTotalScrollOffset: 30,
							onTotalScrollBackOffset: 30,
							onScrollStart: function(){
								$('.mCSB_buttonLeft', this).removeClass('mCSB_buttonLeft--disabled');
								$('.mCSB_buttonRight', this).removeClass('mCSB_buttonRight--disabled');
							}
						}
					});

		$(".tag-slider").find(".mCSB_buttonLeft").addClass("mCSB_buttonLeft--disabled");

	}

	if ($('.radio-slider').length > 0){
		var amount = 0;

		$(".radio-slider li").each(function(indx, element){
			amount += $(this).outerWidth(true);
		})
		amount  = ((amount + 170) / $('.radio-slider').find("li").length ) *5;
		$('.radio-slider').mCustomScrollbar({
						horizontalScroll:true,
						scrollButtons:{
								enable:true,
								scrollType:"pixels",
								scrollAmount:amount,
								scrollSpeed: 1000
						},
						advanced:{autoExpandHorizontalScroll:true},
						callbacks:{ onTotalScroll: function(){ $('.mCSB_buttonRight', this).addClass('mCSB_buttonRight--disabled');},
									onTotalScrollBack: function(){$('.mCSB_buttonLeft', this).addClass('mCSB_buttonLeft--disabled');},
									onTotalScrollOffset: 30,
									onTotalScrollBackOffset: 30,
									onScrollStart: function(){
										$('.mCSB_buttonLeft', this).removeClass('mCSB_buttonLeft--disabled');
										$('.mCSB_buttonRight', this).removeClass('mCSB_buttonRight--disabled');
									}
								}
					});
		$(".radio-slider").find(".mCSB_buttonLeft").addClass("mCSB_buttonLeft--disabled");
	}*/
	menu_height = $(".slide-menu-wrap").height();
})

	/*if ($('.b-container-list').length > 0){
		$('.b-container-list').masonry({
		  		columnWidth: 300,
		  		gutter: 40,
		  		itemSelector: '.b-container__brick',
				//stamp: ".stamp"
			});
	}*/

	/*if( $(".b-bricklist").length){
		$(".b-bricklist").masonry({
			columnWidth: 300,
			gutter: 40,
			itemSelector: '.b-container__brick'
		})
	}

	if( $(".b-bricklist--small").length){
		$(".b-bricklist--small").masonry({
			columnWidth: 200,
			gutter: 20,
			itemSelector: '.b-container__brick'
		})
	}*/

	/*
	if($(".volume_control_track").length>0)
		$(".volume_control_track").slider({
			value: 3,
			min: 1,
			max: 4,
			orientation: "horizontal",
			range: "min",
			slide: function( event, ui ) {
						switch (ui.value){
							case 1:
									$('.volume_control_icon').attr('class', 'volume_control_icon none');
									break
							case 2:
									$('.volume_control_icon').attr('class', 'volume_control_icon little');
									break
							case 3:
									$('.volume_control_icon').attr('class', 'volume_control_icon middle');
									break
							case 4:
									$('.volume_control_icon').attr('class', 'volume_control_icon full');
									break
						}
			},
			animate: true
	});
	*/

	if($('.b-container__brick').length>0){
		$('.b-container__brick').find('.prod-author').each( function(){
			$clamp(this, {clamp: 2, useNativeClamp: false});
		});

		$('.b-container__brick').find('.interview-quote').each( function(){
			$clamp(this, {clamp: 2, truncationChar: '...»', useNativeClamp: false});
		});

		$('.b-container__brick').find('.newlist-author').each( function(){
			$clamp(this, {clamp: 3, useNativeClamp: false});
		});
	}

	$('.b-header-nav__item').mouseenter( function(){

		if ( $(this).hasClass('nav_color-video')) {
				var firstEl = $('.nav-inner_color-video').find('.category').first();
				firstEl.addClass('active');
				$('.b-video-inner-list', firstEl).css('display','block');
			}

		$(this).find('.b-nav-inner-list').stop(true,true).delay(200).slideDown(200);


	}).mouseleave( function(){
		$('.b-nav-inner-list', '.b-header-navigation').stop(true,true).delay(200).slideUp(50);
	});


	$('.category','.nav-inner_color-video').mouseenter(function() {
		if ( $(this).hasClass('active') ) {
			return;
		} else {
			$(this).addClass('active');
			$('ul', this).stop(true,true).animate(
			{
				'width': 'toggle'
			}, 200);
		}
	});

	$('.category','.nav-inner_color-video').mouseleave( function() {
		$(this).removeClass('active');
		$('ul', this).stop(true,true).animate(
		{
			'width': 'toggle'
		}, 100);

	});

	/*$(document).on("click", ".filter__item a", function(){
		if ( $(this).parent().hasClass("filter__item--switch")) {
			$(this).siblings().toggleClass("filter__item-i--active");
		}
		$(this).toggleClass("filter__item-i--active");
	})*/
	/*sorting*/
	$(".sorting__item").on("click", function(){
		var _this =  $(this);
		if (_this.hasClass("sorting__item--active")) return;

		_this.addClass("sorting__item--active").siblings().removeClass("sorting__item--active");
	})
	/*x_sorting*/

	/*filter*/
	/*$(".filter__item").on("click", function(){
		_this = $(this);
		if(_this.hasClass("filter__item--current")) return;

		_this.addClass("filter__item--current").siblings().removeClass("filter__item--current");
	})

	$(".js--filter-check").on("click", function(){
		var _this = $(this);
		$(".filter-inner").slideToggle(300, function(){
			$(this).toggleClass("filter-inner-hidden");
		});
	})*/
	/*x_filter*/

	/*show-by*/
		$(".show-by__item").on("click", function(){
			var _this = $(this);
			if (_this.hasClass("show-by__item--current")) return;
			_this.addClass("show-by__item--current").siblings().removeClass("show-by__item--current");
		})
	/*x_show-by*/

	/*check track*/
	$(".js-check-track").on("click", function(){
		var _this = $(this);
		_this.parents(".tracklist__unit").toggleClass("tracklist__unit--checked");
	})
	/*x_check-track*/


/*
	enquire.register("screen and (min-width:1020px) and (max-width: 1359px)", {
    	match : function() {

    		console.log("min-width:1020px");

    		if( $(".b-bricklist").length){
				$(".b-bricklist").masonry({
					columnWidth: 300,
					gutter: 40,
					itemSelector: '.b-container__brick'
				})
			}

			if( $(".b-bricklist--small").length){
				$(".b-bricklist--small").masonry({
					columnWidth: 200,
					gutter: 20,
					itemSelector: '.b-container__brick'
				})
			}
    	},
	})
	.register("screen and (min-width:1360px) and (max-width: 1459px)", {
    	match : function() {
    		console.log("min-width:1360px");

    		if( $(".b-bricklist").length){
				$(".b-bricklist").masonry({
					columnWidth: 300,
					gutter: 40,
					itemSelector: '.b-container__brick'
				})
			}

			if( $(".b-bricklist--small").length){
				$(".b-bricklist--small").masonry({
					columnWidth: 200,
					gutter: 60,
					itemSelector: '.b-container__brick'
				})
			}
    	},
	})
	.register("screen and (min-width:1460px) and (max-width: 1699px)", {
    	match : function() {
    		console.log("min-width:1460px");

    		if( $(".b-bricklist").length){
				$(".b-bricklist").masonry({
					columnWidth: 300,
					gutter: 90,
					itemSelector: '.b-container__brick'
				})
			}

			if( $(".b-bricklist--small").length){
				$(".b-bricklist--small").masonry({
					columnWidth: 200,
					gutter: 20,
					itemSelector: '.b-container__brick'
				})
			}
    	},
	})*/

var brick_hover_on = function(){
		$(this).find(".content-item_pic-back").show();
		$(this).find(".content-item_remove").show();
		$(this).find('.content-item__hover').stop(true, true).fadeIn(200);
}
var brick_hover_off = function(){
	$(this).find(".content-item_pic-back").hide();
	$(this).find(".content-item_remove").hide();
	$(this).find('.content-item__hover').stop(true, true).hide();
}
	enquire.register("screen and (max-width:1019px)", {
		match : function() {
			$(window).load(function(){
				/*$(right_aside).css("left", $("body")[0].scrollWidth/2);*/
				/*$(side_panel).css("right", $("body")[0].offsetWidth - $("body")[0].scrollWidth/2);*/
			});
			$(window).on("scroll", move_fix_elements).on("resize", move_fix_elements);
		},
		unmatch: function(){
			$(window).off("scroll", move_fix_elements).off("resize", move_fix_elements);

			/*$(right_aside).css("left", "50%");*/
			/*$(side_panel).css("right", "50%");*/
		}
	})
	.register("screen and (min-width:1780px)", {
		match : function() {
			if (isShelfMode()) {
				brickSliders_setWidth(lineSlider, albumSlider, playlistSlider, materialsSlider, 118);
			}
		}
	})
	.register("screen and (max-width:1779px)", {
		match : function() {
			if (isShelfMode()) {
				brickSliders_setWidth(lineSlider, albumSlider, playlistSlider, materialsSlider, 118);
			}
		}
	})
	.register("screen and (min-width:1440px)", {
    	match : function() {
    		if(pane2api){
    			pane2api.reinitialise();
    		}
    		$(document).on("mouseenter", ".content-item_pic", brick_hover_on);
    		$(document).on("mouseleave", ".content-item_pic", brick_hover_off);

    		$('.container__brick').mouseenter( function(){
				$(this).find('.brick-i__hover, .brick-i_favorite').stop(true, true).fadeIn(200);
			}).mouseleave( function(){
				$(this).find('.brick-i__hover, .brick-i_favorite').stop(true, true).hide();
			});
			widget_mh = 770;// 2 group item

			$(".search_suggest_inner").each(function(){
				$(this).width($(this).parents(".group_item").width());
			})

			if (isShelfMode()) {
				wrapper.height( Math.max( widget_mh + 90, _body.height() ) );

				$(".b-widget-content").css("min-height", ( Math.max( widget_mh, _body.height() - 90, $(right_aside).height() ) ) + "px");

				for (var i = 0, len = widget_scroll_obj.length; i <= len -1; i ++ ){
					var api = widget_scroll_obj[i][1].data('jsp');
					api.reinitialise();
				}
				brickSliders_setWidth(lineSlider, albumSlider, playlistSlider, materialsSlider, 118);
			}
    	},
    	unmatch: function(){
    		$(document).off("mouseenter", ".content-item_pic", brick_hover_on);
    		$(document).off("mouseleave", ".content-item_pic", brick_hover_off);


			widget_mh = 1165;// 2 group item

			$(".search_suggest_inner").each(function(){
				$(this).width($(this).parents(".group_item").width());
			})

			if (isShelfMode) {
				wrapper.height( Math.max( widget_mh + 90, _body.height() ) );
				$(".b-widget-content").css("min-height", ( Math.max( widget_mh, _body.height() - 90, $(right_aside).height() ) ) + "px");

				for (var i = 0, len = widget_scroll_obj.length; i <= len -1; i ++ ){
					var api = widget_scroll_obj[i][1].data('jsp');
					var pos_y = api.getContentPositionY();
					api.reinitialise();
				}
			}
    	}
	})
	.register("screen and (min-width: 1410px)",{
		match : function() {
    		if(pane2api){
    			pane2api.reinitialise();
    		}
    	}
	})
	.register("screen and (min-width: 1070px)",{
		match : function() {
    		if(pane2api){
    			pane2api.reinitialise();
    		}
    	}
	});
	$(".js-hide").on("click", function(){
		var _this = $(this);
		var tracklist =  _this.parents(".b-artist-list").find(".b-tracklist");
		if (!_this.hasClass("js-hide-list--hide")){
			tracklist.slideUp("300");
			_this.addClass("js-hide-list--hide");
			_this.text("Показать");
		}
		else{
			tracklist.slideDown("300");
			_this.removeClass("js-hide-list--hide");
			_this.text("Скрыть");
		}
	})

	$(".js-hide-switch").on("click", function(){
		var _this = $(this),
			element =  _this.parents(".js-hide-container").find(".js-hide-element");

		if (!_this.hasClass("js-hide-switch--hide")){
			element.slideUp("300");
			_this.addClass("js-hide-switch--hide");
			_this.text("Показать");
		}
		else{
			element.slideDown("300");
			_this.removeClass("js-hide-switch--hide");
			_this.text("Скрыть");
		}
	})

	$(".js-load-next-comment").on("click", function(){
		var comment_list = $(this).parents(".b-comments").find(".comment-list");
		comment_list.append('<li class="comment_unit"><div class="comment-date">18.05.2013</div><div class="comment-user-pict"><img src="/css/iSvoy3/content/user_pic_2.jpg" width="50" height="50"/></div><div class="comment-data"><span class="comment-user-name">эвелиночка</span><p class="comment-text">КРУТАЯ ПЕСНЯ</p></div></li>');
	})
	$(".js-load-next-track").on("click", function(){
		var tracklist =  $(this).parents(".js-group-list").find(".tracklist");
		tracklist.append('<li class="tracklist__unit"> <div class="tracklist__unit-inner"> <div class="track-control"> <em class="track-control__ico track-control__ico--check js-check-track"></em> <em class="track-control__ico track-control__ico--play"></em> </div> <div class="tracklist__item"> <em class="rating-ico rating-ico--down"></em><span class="track-name">Die Alone - <b>Diplo</b></span> </div> </div> <div class="tracklist__unit-inner"> <div class="track-control-panel"> <em class="actions-ico actions-ico--video"></em> <em class="actions-ico actions-ico--text"></em> <em class="actions-ico actions-ico--playlist"> <div class="b-popup b-popup--hidden"> <div class="b-popup-inner"> <ul class="tracklist-group tracklist-group--user"> <li class="tracklist-item tracklist-group-name"> <div class="tracklist-inner"> Ваш </div> <div class="tracklist-inner"></div> </li> <li class="tracklist-item"> <div class="tracklist-inner"> <a href="#">ПУХLESS</a> </div> <div class="tracklist-inner"></div> </li> </ul> <ul class="tracklist-group tracklist-group--user"> <li class="tracklist-item  tracklist-group-name"> <div class="tracklist-inner"> Другие пользователи </div> <div class="tracklist-inner"></div> </li> <li class="tracklist-item"> <div class="tracklist-inner"> <a href="#">Ступор</a> </div> <div class="tracklist-inner"><a href="#userpage" title="Иннокентий Кириллов" class="user-profile-ico"></a></div> </li> <li class="tracklist-item"> <div class="tracklist-inner"> <a href="#">SUPERTEMA</a> </div> <div class="tracklist-inner"><a href="#userpage" title="Иннокентий Кириллов" class="user-profile-ico"></a></div> </li> </ul> <ul class="tracklist-group"> <li class="tracklist-item"> <div class="tracklist-inner"> <a href="#">50 треков для пикника 50 треков для пикника 50 треков для пикника</a> </div> <div class="tracklist-inner"></div> </li> <li class="tracklist-item"> <div class="tracklist-inner"> <a href="#">50 треков для пикника</a> </div> <div class="tracklist-inner"></div> </li> <li class="tracklist-item"> <div class="tracklist-inner"> <a href="#">50 треков для пикника</a> </div> <div class="tracklist-inner"></div> </li> </ul> <a href="#all" class="b-popup-control">Все</a> </div> </div> <span>9+</span> </em> <em class="actions-ico actions-ico--share"></em> <em class="actions-ico actions-ico--turn"></em> <em class="actions-ico actions-ico--add"></em> <em class="actions-ico actions-ico--like"></em> <span class="price-label price-label--in-basket">20 РУБ.</span> </div> <span class="track-time">02:08</span> </div> </li> ');

	})

	$(".js-load-all-list").on("click", function(){
		var _this = $(this);
		if (_this.hasClass("control__item--disabled")) return;
		var tracklist =  _this.parents(".js-group-list").find(".tracklist");
		tracklist.append('<li class="tracklist__unit"> <div class="tracklist__unit-inner"> <div class="track-control"> <em class="track-control__ico track-control__ico--check js-check-track"></em> <em class="track-control__ico track-control__ico--play"></em> </div> <div class="tracklist__item"> <em class="rating-ico rating-ico--down"></em><span class="track-name">Die Alone - <b>Diplo</b></span> </div> </div> <div class="tracklist__unit-inner"> <div class="track-control-panel"> <em class="actions-ico actions-ico--video"></em> <em class="actions-ico actions-ico--text"></em> <em class="actions-ico actions-ico--playlist"> <div class="b-popup b-popup--hidden"> <div class="b-popup-inner"> <ul class="tracklist-group tracklist-group--user"> <li class="tracklist-item tracklist-group-name"> <div class="tracklist-inner"> Ваш </div> <div class="tracklist-inner"></div> </li> <li class="tracklist-item"> <div class="tracklist-inner"> <a href="#">ПУХLESS</a> </div> <div class="tracklist-inner"></div> </li> </ul> <ul class="tracklist-group tracklist-group--user"> <li class="tracklist-item  tracklist-group-name"> <div class="tracklist-inner"> Другие пользователи </div> <div class="tracklist-inner"></div> </li> <li class="tracklist-item"> <div class="tracklist-inner"> <a href="#">Ступор</a> </div> <div class="tracklist-inner"><a href="#userpage" title="Иннокентий Кириллов" class="user-profile-ico"></a></div> </li> <li class="tracklist-item"> <div class="tracklist-inner"> <a href="#">SUPERTEMA</a> </div> <div class="tracklist-inner"><a href="#userpage" title="Иннокентий Кириллов" class="user-profile-ico"></a></div> </li> </ul> <ul class="tracklist-group"> <li class="tracklist-item"> <div class="tracklist-inner"> <a href="#">50 треков для пикника 50 треков для пикника 50 треков для пикника</a> </div> <div class="tracklist-inner"></div> </li> <li class="tracklist-item"> <div class="tracklist-inner"> <a href="#">50 треков для пикника</a> </div> <div class="tracklist-inner"></div> </li> <li class="tracklist-item"> <div class="tracklist-inner"> <a href="#">50 треков для пикника</a> </div> <div class="tracklist-inner"></div> </li> </ul> <a href="#all" class="b-popup-control">Все</a> </div> </div> <span>9+</span> </em> <em class="actions-ico actions-ico--share"></em> <em class="actions-ico actions-ico--turn"></em> <em class="actions-ico actions-ico--add"></em> <em class="actions-ico actions-ico--like"></em> <span class="price-label price-label--in-basket">20 РУБ.</span> </div> <span class="track-time">02:08</span> </div> </li> ');
		_this.addClass("control__item--disabled");
	})
	if ($.browser.msie) {$("html").addClass("ie");}

	/*
	Перенесено

	var alph_list_width = $(".alph-artist-wr").height();
	$(".alph-artist-wr").css("top", -alph_list_width/2);
	$(".alph-artist-wr").css("left", alph_list_width/2);
	$(".alph-scroll-fix").css("width", alph_list_width);

	$(".scroll-alph-wrap").jScrollPane_n({
		//horizontalDragMinWidth: 160,
        //horizontalDragMaxWidth: 160
	});*/

	var pane2api = $(".scroll-alph-wrap").data('jsp');

	/*
	перенесено

	$(document).on("click", ".alph-group-control--open", function(){
		_this = $(this);
		_this.removeClass("alph-group-control--open").addClass("alph-group-control--close");


		if (_this.parents(".alph-artist__item").nextUntil(".alph-artist__item--head").filter(".alph-artist__item--all").length){
			_this.parents(".alph-artist__item").nextUntil(".alph-artist__item--head").filter(".alph-artist__item--all").css("display", "inline-block");

		}
		else{
			_this.parents(".alph-artist__item").nextUntil(".alph-artist__item--head").filter(".alph-artist__item--popular").last().after('<li class="alph-artist__item alph-artist__item--all">контент, возвращаемый ajax\'м</li>');
		}
			_this.parents(".alph-artist__item").nextUntil(".alph-artist__item--head").filter(".alph-artist__item--popular").hide();

		var old_width = $(".alph-scroll-fix").width();
		var alph_list_width = $(".alph-artist-wr").height();
			$(".alph-artist-wr").css("top", -alph_list_width/2);
			$(".alph-artist-wr").css("left", alph_list_width/2);
			$(".alph-scroll-fix").css("width", alph_list_width);

		if (old_width != $(".alph-scroll-fix").width()){pane2api.reinitialise();}
	})

	$(document).on("click", ".alph-group-control--close", function(){
		_this = $(this);
		_this.removeClass("alph-group-control--close").addClass("alph-group-control--open");
		var
			alph_list = _this.parents(".alph-artist__item").nextUntil(".alph-artist__item--head");
			popular_list = alph_list.filter(".alph-artist__item--popular"),


		_this.parents(".alph-artist__item").nextUntil(".alph-artist__item--head").filter(".alph-artist__item--all").hide();
		_this.parents(".alph-artist__item").nextUntil(".alph-artist__item--head").filter(".alph-artist__item--popular").css("display", "inline-block");


		var old_width = $(".alph-scroll-fix").width();
		var alph_list_width = $(".alph-artist-wr").height();
			$(".alph-artist-wr").css("top", -alph_list_width/2);
			$(".alph-artist-wr").css("left", alph_list_width/2);
			$(".alph-scroll-fix").css("width", alph_list_width);

		if (old_width != $(".alph-scroll-fix").width()){pane2api.reinitialise();}
	})*/

	$(document).on("click", ".js-all-playlist", function(e){
		e.preventDefault();
		var _this = $(this);
		_this.toggleClass("playlist-list-open");
		if (_this.hasClass("playlist-list-open")){
			_this.find(".action_text").text("Скрыть");
			_this.find(".actions-ico").addClass("actions-ico--checked");
		}
		else{
			_this.find(".action_text").text("Все плейлисты");
			_this.find(".actions-ico").removeClass("actions-ico--checked");
		}
		$(".playlist-list").slideToggle(300);
	});
	$(document).on("click", ".price-label", function(){
		_this = $(this);
		if (_this.hasClass("price-label--in-basket")){
			return;
		}
		else{
			_this.addClass("price-label--in-basket");
		}
	})

	/*$(document).on("click", ".media-tumbler-i", function(){
		var cat_arr = ['music', 'audio', 'video', 'book'];
		var _this = $(this),
			cat  = "",
			preview_cat = $(this).parents(".b-media-box").data("content");

		for (var i = 0, len = cat_arr.length; i <= len - 1; i++){
			if (_this.hasClass("media-tumbler-i--" + cat_arr[i])){
				cat = cat_arr[i];
				break;
			}
		}
		$(".b-media-box-container .b-media-box").addClass("b-media-box--hidden");
		$(".b-media-box-container .b-media-box--" + cat).removeClass("b-media-box--hidden");
		$(".b-media-widget").removeClass("b-media-widget--" + preview_cat).addClass("b-media-widget--" + cat);
	})*/

	/*$(document).on("click", ".slide-menu-control", function(){

		$(this).toggleClass("slide-menu-control--down");

		if ( $(tags_menu).hasClass("slide-menu--open")){
			direction = "-=";

			shadow_pos = "0";

			$(".b-side-panel").animate({marginTop: 0 }, 1100);
		}
		else{
			direction = "+=";

			shadow_pos = "-10";

			menu_height = $(".slide-menu-wrap").height();
			if ( parseInt($(tags_menu).css("margin-bottom")) + menu_height + 40 > parseInt( $(".fix_layer_inner").css("margin-top")) ){
				$(".b-side-panel").animate({marginTop: 40 - parseInt( $(".b-side-panel").css("top") ) }, 800);
			}
		}

		$(tags_menu).animate({marginTop: direction + menu_height, marginBottom: direction + menu_height}, {duration:1000, complete: function(){
			$(tags_menu).toggleClass("slide-menu--open");
		}});

		$(menu_shadow).animate({bottom: shadow_pos}, 1000);

	})*/

	/*$(".b-control-i--shuffle").on("click", function(){
		$(this).toggleClass("b-control-i--shuffle-on");
	})
	$(".b-control-i--repeat").on("click", function(){
		$(this).toggleClass("b-control-i--repeat-on");
	})*/


	/*add duration*/
	/*$(".slide-menu-control, .b-side-panel, .b-container-wrap, .right-aside").addClass("main_block_duration");*/

	/*actions*/
	$(document).on("click", ".actions-ico--like", function(){
		if (!$(this).hasClass("actions-ico--checked")){
			$(this).addClass("actions-ico--checked");
		}
	}).on("click", ".actions-ico--subscribe", function(){
		if (!$(this).hasClass("actions-ico--checked")){
			$(this).addClass("actions-ico--checked");
		}
	}).on("click", ".actions-ico--turn", function(){
		if (!$(this).hasClass("actions-ico--checked")){
			$(this).addClass("actions-ico--checked");
		}
	}).on("click", ".actions-ico--add", function(){
		if (!$(this).hasClass("actions-ico--checked")){
			$(this).addClass("actions-ico--checked");
		}
	}).on("click", ".actions-ico--play", function(){
		$(this).toggleClass("actions-ico--play actions-ico--pause").siblings(".action_text").text("Пауза");

	}).on("click", ".actions-ico--pause", function(){
		$(this).toggleClass("actions-ico--play actions-ico--pause").siblings(".action_text").text("Прослушать");

	}).on("click", ".actions-ico--buy", function(){
		if (!$(this).hasClass("actions-ico--checked")){
			$(this).addClass("actions-ico--checked");
		}
	})
	.on("click", ".actions-ico--settings", function(){
		$(this).find(".settings-list").slideToggle(400);
	})

	/*actions*/
	$(document).on(".create_playlist", function(){})

	$(".switch_ico").on("click", function(){
		var _this = $(this);
		if ( _this.hasClass("switch_ico--active") ) return false;

		$(".switch_ico").removeClass("switch_ico--active");
		_this.addClass("switch_ico--active");

		$(".b-widget-content--list, .b-widget-content--brick").toggle();
		if ( _this.hasClass("switch_ico--brick") ){
			brickSliders_reload();

			for (var i = 0, len = widget_scroll_obj.length; i <= len -1; i ++ ){
				widget_scroll_obj[i][0].width(widget_scroll_obj[i][0].parents(".group_item").width());
				var api = widget_scroll_obj[i][1].data('jsp');
				api.reinitialise();
			}
		}
	})
		//-----------------------------------------------------------NEW_MOVE

		var draggableOpts = {
			revert: 'invalid',
			create: function(event, ui){
				$(this).attr("data-id", $(this).attr("id"));
			},
			cursor: 'move',
			cursorAt: {	left: 5, top: 5},
		};
		var draggableOptsList = $.extend({}, draggableOpts,
			{
				handle: ".prod-drndr",
				helper: function (event, ui) {
					var _helper = $('.move_helper').clone();
					_helper.data("list", $(this).data("list")).css("height", "20").css("width", "150" ).show().addClass("static").addClass("current-helper");
					_helper.find(".item_name").html( $(this).find(".prod-name").text() );

					//$('.b-media-widget').append(_helper);
					$('.b-media-widget').after(_helper);

					return _helper;
				},
			});
		var draggableOptsBrick = $.extend({}, draggableOpts,
			{
				handle: ".brick-i_drndr",
				helper: function (event, ui) {
					var _helper = $('.brick__clone-dnd').clone();
					_helper.data("list", $(this).data("list")).css("height", "60").css("width", "60" ).show().addClass("static").addClass("current-helper").find(".brick__clone-dnd-status").addClass("brick__clone-dnd-status--static");;
					_helper.find(".item_name").html( $(this).find(".prod-name").text() );

					_helper.find("brick__clone-dnd-pic img").attr("src", $(this).find("content-item_pic img").attr("src"));// маленькое изображение
					$('.b-media-widget').after(_helper);

					return _helper;
				}
			});

		    jQuery.fn.draggableSetup = function draggableSetup(content_type, widget_type) {
		    	var options = [],
		    		content_type = content_type;

		    	if ( widget_type == "brick" ){
		    		switch(content_type){
			    		case "track":
			    			options = $.extend({}, draggableOptsBrick, { connectToSortable: ".widget__list-slider--line, .prod-list--track, .tracklist--edit"} );
			    			break;
			    		case "playlist":
			    			options = $.extend({}, draggableOptsBrick, { connectToSortable: ".widget__list-slider--line, .widget__list-slider--playlist"});
			    			break;
			    		case "album":
			    			options = $.extend({}, draggableOptsBrick, {	connectToSortable: ".widget__list-slider--line, .widget__list-slider--album"})
			    			break;
		    			case "editor":
			    			options = $.extend({}, draggableOptsBrick, {	connectToSortable: ".widget__list-slider--line, .widget__list-slider--editor"})
			    			break;
			    	}
		    	}
		    	else{

			    	switch(content_type){
			    		case "track":
			    			options = $.extend({}, draggableOptsList, { connectToSortable: ".prod-list--line, .widget__list-slider--line, .prod-list--track, .tracklist--edit"} );
			    			break;
			    		case "playlist":
			    			options = $.extend({}, draggableOptsList, { connectToSortable: ".prod-list--line, .prod-list--playlist"});
			    			break;
			    		case "album":
			    			options = $.extend({}, draggableOptsList, {	connectToSortable: ".prod-list--line, .prod-list--album"})
			    			break;
		    			case "editor":
			    			options = $.extend({}, draggableOptsList, {	connectToSortable: ".prod-list--line, .prod-list--editor"})
			    			break;
			    		case "track_unit":
			    			options = $.extend({}, draggableOptsList, { connectToSortable: ".prod-list--line, .widget__list-slider--line, .prod-list--track, .tracklist--edit"} );
			    			break;
			    	}
		    	}
		        this.draggable( options );
		        return this;
		    }

		function inArray(needle, haystack) {
		    var length = haystack.length;
		    for(var i = 0; i < length; i++) {
		        if(haystack[i] == needle) return true;
		    }
		    return false;
		}

		function create_new_element(type){
			var new_element;
			switch (type){
				case "track_list":
					new_element = $('<li class="prod-list__item prod-list__item--track" data-list="track"><div class="prod-list__item_inner"><div class="prod-drndr"></div><p class="prod-name"></p><p class="prod-author"></p><p class="prod-time"></p></div></li>');
					break;
				case "track_brick":
					new_element = $('\
					<div class="b-widget__content-item  b-widget__content-item--track" data-list="line">\
						<div class="content-item_pic">\
							<img width="150" src="http://static.media.svoy.ru/16252e882c013a858586592a5eeb1914" title="The DuckDuckDuckDuckDuckDuckDuckDuck - Who got the creck1">\
							<div class="content-item_pic-back content-item_pic-back--color"></div>\
							<div class="content-item_state">\
								<div class="state_light"></div>\
								<div class="state_center"></div>\
							</div>\
							<div class="content-item__hover" style="display: none;">\
								<em class="hover-control-i hover-control-i--play"></em>\
								<em class="hover-control-i hover-control-i--edit"></em>\
								<em class="hover-control-i hover-control-i--share"></em>\
								<div class="brick-i_drndr">\
									<div class="brick__clone-dnd brick__clone-dnd--hidden">\
										<em class="brick__clone-dnd-status"></em>\
										<div class="brick__clone-dnd-pic"><img src="http://content2.adfox.ru/131126/adfox/255292/899280.jpg" height="60" width="60"></div>\
									</div>\
								</div>\
							</div>\
							<div class="content-item_remove"></div>\
						</div>\
						<div class="content-item_title"></div>\
						<div class="content-item_author"></div>\
					</div>');
					break;
				case "track_unit":
				new_element = $('\
					<li class="tracklist__unit ui-draggable" data-list="track">\
						<div class="tracklist__unit-inner">\
							<div class="track-control">\
								<div class="prod-drndr"></div>\
							</div>\
							<div class="tracklist__item">\
								<span class="track-name"><span class="prod-name"></span> - <b><span class="prod-author"></span></b></span>\
							</div>\
						</div>\
						<div class="tracklist__unit-inner">\
							<div class="remove_item"></div>\
						</div>\
					</li>\
				');
			}

			return new_element;

		}
		var prod_id_array = []

		$(".prod-list").each(function(){
			var this_type = $(this).data("list");
			prod_id_array[this_type] = [];
			$("li", this).each(function(){
				var this_item = $(this);
				prod_id_array[this_type].push(this_item.attr("id"))
			})
		})

		/*добавить массив при редактировании плейлиста*/
		var edit_list_id = $(".tracklist--edit").attr("id");
		prod_id_array[edit_list_id] = [];
		$(".tracklist--edit li").each(function(){
			var this_item = $(this);
			prod_id_array[edit_list_id].push(this_item.attr("id"));
		})
		/**/


		$(".prod-list__item--track").draggable($.extend({}, draggableOptsList, {
			connectToSortable: ".prod-list--line, .widget__list-slider--line, .prod-list--track, .tracklist--edit ",
		}));

		$(".prod-list__item--redaction_playlist, .prod-list__item--user_playlist").draggable($.extend({}, draggableOptsList, {
			connectToSortable: ".prod-list--line, .prod-list--playlist",

		}));

		$(".prod-list__item--album").draggable($.extend({}, draggableOptsList, {
			connectToSortable: ".prod-list--line, .prod-list--album",
		}));
		$(".prod-list__item--editor").draggable($.extend({}, draggableOptsList, {
			connectToSortable: ".prod-list--line, .prod-list--editor",
		}));
		$(".tracklist--edit .tracklist__unit").draggable($.extend({}, draggableOptsList, {
			connectToSortable: ".prod-list--line, .tracklist--edit, .widget__list-slider--line, .prod-list--track",
		}));
		$(".prod-list--track").droppable({
			accept: ".prod-list__item--track, .b-widget__content-item--track",
			over: function(event, ui){

				ui.helper.removeClass("static disabled").addClass("enabled")

				var status = ui.helper.find(".brick__clone-dnd-status");

				status.removeClass("brick__clone-dnd-status--static brick__clone-dnd-status--disabled").addClass("brick__clone-dnd-status--add");

				if ( $(this).data("list") == ui.helper.data("list") ){
					ui.helper.removeClass("enabled");
					ui.helper.addClass("static");

					status.removeClass("brick__clone-dnd-status--add").addClass("brick__clone-dnd-status--static")
				}
			},
			out: function(event, ui){
				ui.helper.removeClass("static enabled").addClass("disabled");
			},
			tolerance:  "pointer",
			greedy: true
		})

		$(".tracklist--edit").droppable({
			accept: ".prod-list__item--track, .b-widget__content-item--track, .tracklist__unit",
			over: function(event, ui){

				ui.helper.removeClass("static disabled").addClass("enabled")

				var status = ui.helper.find(".brick__clone-dnd-status");

				status.removeClass("brick__clone-dnd-status--static brick__clone-dnd-status--disabled brick__clone-dnd-status--play").addClass("brick__clone-dnd-status--add");

				if ( $(this).data("list") == ui.helper.data("list") ){
					ui.helper.removeClass("enabled");
					ui.helper.addClass("static");

					status.removeClass("brick__clone-dnd-status--add").addClass("brick__clone-dnd-status--static")
				}
			},
			out: function(event, ui){
				ui.helper.removeClass("static enabled").addClass("disabled");
				var status = ui.helper.find(".brick__clone-dnd-status");

				status.removeClass("brick__clone-dnd-status--add brick__clone-dnd-status--static").addClass("brick__clone-dnd-status--play");
			},
			tolerance:  "pointer",
			greedy: true,
		})

		$(".prod-list--album").droppable({
			accept: ".prod-list__item--album",
			over: function(event, ui){
				ui.helper.removeClass("static disabled").addClass("enabled")
				if ( $(this).data("list") == ui.helper.data("list") ){
					ui.helper.removeClass("enabled");
					ui.helper.addClass("static");
				}
			},
			out: function(event, ui){
				ui.helper.removeClass("static enabled").addClass("disabled")
			},
			tolerance:  "pointer"
		});
		$(".prod-list--playlist").droppable({
			accept: ".prod-list__item--user_playlist, .prod-list__item--redaction_playlist",
			over: function(event, ui){
				ui.helper.removeClass("static disabled").addClass("enabled")
				if ( $(this).data("list") == ui.helper.data("list") ){
					ui.helper.removeClass("enabled");
					ui.helper.addClass("static");
				}
			},
			out: function(event, ui){
				ui.helper.removeClass("static enabled").addClass("disabled")
			},
			tolerance:  "pointer"
		})
		$(".prod-list--editor").droppable({
			accept: ".prod-list__item--editor",
			over: function(event, ui){
				ui.helper.removeClass("static disabled").addClass("enabled")
				if ( $(this).data("list") == ui.helper.data("list") ){
					ui.helper.removeClass("enabled");
					ui.helper.addClass("static");
				}
			},
			out: function(event, ui){
				ui.helper.removeClass("static enabled").addClass("disabled")
			},
			tolerance:  "pointer"
		})

		$(".right-aside").droppable({
			tolerance: "pointer",
			over: function(event, ui){
				ui.helper.removeClass("static disabled").addClass("enabled enabled-play");

				var status = ui.helper.find(".brick__clone-dnd-status");
				status.removeClass("brick__clone-dnd-status--static brick__clone-dnd-status--add").addClass("brick__clone-dnd-status--play");
			},
			drop: function(event, ui){
				detail_available = ['redaction_playlist', 'user_playlist', 'album']
				isDetail = false;
				for (i = 0, n = detail_available.length; i <= n-1; i++){
					if ( ui.draggable.hasClass("prod-list__item--" + detail_available[i] )){
						isDetail =  true;
						break;
					}
				}
				if (isDetail){
					console.log("Детальное описание без воспроизведения. ID = " + $(ui.draggable).attr("data-id"));
					$(".b-widget-current").addClass("hidden");
					$(".b-widget-current").eq(0).removeClass("hidden");

					if ( $(".right-aside .tracklist__unit").length >=12 ){
						wrapper.height( Math.max( 1080, widget_mh + 90, _body.height() ) );
					}
					$(".b-widget-content").css("min-height", ( Math.max( widget_mh, _body.height() - 90, $(right_aside).height() ) ) + "px");

					/*$(".b-widget-current:visible").find(".tracklist-wrap").jScrollPane_n();*/
					for (var i = 0, len = widget_scroll_obj.length; i <= len -1; i ++ ){
						var api = widget_scroll_obj[i][1].data('jsp');
						api.reinitialise();
					}
				}
				else{
					console.log("Воспроизведение. ID = " +  $(ui.draggable).attr("data-id"));
				}
			},
			out: function(event, ui){
				ui.helper.removeClass("static enabled enabled-play").addClass("disabled");
			},
			greedy: true
		})
		$(".b-media-widget").droppable({
			over: function(event, ui){
				ui.helper.removeClass("static enabled").addClass("disabled");
				var status = ui.helper.find(".brick__clone-dnd-status");
				status.removeClass("brick__clone-dnd-status--static brick__clone-dnd-status--add brick__clone-dnd-status--play");
			},
			tolerance: "pointer"
		})


		$(".prod-list").sortable({
			helper: function(event, ui){
				var _helper  = $(".current-helper");
				return _helper;
			},
			handle: ".prod-drndr",
			receive: function(event, ui){
				//ui.item - old element
				var prod_id = ui.sender.attr("id");

				if ( ( $(this).data("list") == ui.sender.data("list") ) && (!ui.sender.hasClass("tracklist__unit")) ){

					var this_copy = $(".sort_item_copy", this);
				 	ui.item.insertBefore(this_copy);
				 	this_copy.remove();
		        }
		        else {
		        	var new_element = $(".sort_item_new", this),
		        		create_element = $(".create_element", this);


		        	new_element.attr("id", prod_id);

		        	if ( inArray(prod_id, prod_id_array[$(this).data("list")])){ //element with this id already exists
		        		$("li[id=" + prod_id +"]", this).not(".sort_item_new").not(".create_element").insertBefore(new_element);
		        		new_element.remove();
		        		create_element.remove();
		        	}
		        	else{
		        		new_element.removeClass("sort_item_new");
		        		prod_id_array[$(this).data("list")].push(prod_id);
		        	}
		        	if ( create_element.length ){
		        		new_element.remove();
		        		create_element.removeClass("create_element");
		        	}
		        }
			},
			beforeStop: function(event, ui){
				//ui.item  - create element
				 ui.item.removeClass("prod-list__item--active");
				if ( $(this).data("list") == ui.item.data("list")  && (!ui.item.hasClass("tracklist__unit"))){
					ui.item.addClass("sort_item_copy");
		        }
		        else{
		        	var type = $(this).data("list");
		        	ui.item.addClass("sort_item_new");
		        	if ( type == "line") {
		        		type = ui.item.data("list");
		        	}
		        	ui.item.data("list", $(this).data("list"));
		        	ui.item.attr("data-list",  $(this).data("list"));//for copy
		        	ui.item.removeClass("ui-draggable").draggableSetup(type);


		        	if (ui.item.hasClass("b-widget__content-item")){
						var this_name = $(ui.item).find(".content-item_title").html(),
							this_author = $(ui.item).find(".content-item_author").html(),
							new_item = create_new_element( type + "_list" );

						new_item.find(".prod-name").html(this_name);
						new_item.find(".prod-author").html(this_author);
						new_item.attr("id", $(ui.item).attr("data-id"));
						new_item.insertBefore(ui.item).addClass("create_element").removeClass("ui-draggable").draggableSetup(type);
					}
					if ( ui.item.hasClass("tracklist__unit") ){
						var this_name = $(ui.item).find(".prod-name").html(),
							this_author = $(ui.item).find(".prod-author").html(),
							new_item = create_new_element( type + "_list" );

						new_item.find(".prod-name").html(this_name);
						new_item.find(".prod-author").html(this_author);
						new_item.attr("id", $(ui.item).attr("data-id"));
						new_item.insertBefore(ui.item).addClass("create_element").removeClass("ui-draggable").draggableSetup(type);;
					}
		        }
			},
			tolerance:  "pointer",
			change: function(event, ui){
				ui.helper.removeClass("static disabled").addClass("enabled");

				if ( $(this).data("list") == ui.helper.data("list")  && (!ui.item.hasClass("tracklist__unit"))){
					ui.helper.removeClass("enabled");
					ui.helper.addClass("static");
				}
			},
			placeholder: "sortable_placeholder",
			start: function(event, ui){
				ui.item.addClass("gtest");
			},
			out: function(event, ui){
				//ui.helper.removeClass("static enabled").addClass("disabled");
			}
		})

		$(".tracklist--edit").sortable({
			helper: function(event, ui){
				var _helper  = $(".current-helper");
				return _helper;
			},
			handle: ".prod-drndr",
			receive: function(event, ui){

				//ui.item - old element
				var prod_id = ui.sender.attr("id");

				if ( $(this).data("list") == ui.sender.data("list")  && ( !ui.sender.hasClass("prod-list__item") )){

					var this_copy = $(".sort_item_copy", this);
				 	ui.item.insertBefore(this_copy);
				 	this_copy.remove();
		        }
		        else {
		        	var new_element = $(".sort_item_new", this),
		        		create_element = $(".create_element", this);


		        	new_element.attr("id", prod_id);

		        	if ( inArray(prod_id, prod_id_array[$(this).data("id")])){ //element with this id already exists
		        		$("li[id=" + prod_id +"]", this).not(".sort_item_new").not(".create_element").insertBefore(new_element);
		        		new_element.remove();
		        		create_element.remove();
		        	}
		        	else{
		        		new_element.removeClass("sort_item_new");
		        		prod_id_array[$(this).data("list")].push(prod_id);
		        	}
		        	if ( create_element.length ){
		        		new_element.remove();
		        		create_element.removeClass("create_element");
		        	}
		        }
			},
			beforeStop: function(event, ui){

				//ui.item  - create element
				 ui.item.removeClass("prod-list__item--active");
				if ( $(this).data("list") == ui.item.data("list")  && (!ui.item.hasClass("prod-list__item"))){
					ui.item.addClass("sort_item_copy");
		        }
		        else{
		        	var type = $(this).data("list");
		        	ui.item.addClass("sort_item_new");
		        	if ( type == "line") {
		        		type = ui.item.data("list");
		        	}
		        	ui.item.data("list", $(this).data("list"));
		        	ui.item.attr("data-list",  $(this).data("list"));//for copy
		        	ui.item.removeClass("ui-draggable").draggableSetup("track_unit");

		        	if (ui.item.hasClass("b-widget__content-item")){
						var this_name = $(ui.item).find(".content-item_title").html(),
							this_author = $(ui.item).find(".content-item_author").html(),
							new_item = create_new_element( type + "_unit" );

						new_item.find(".prod-name").html(this_name);
						new_item.find(".prod-author").html(this_author);
						new_item.attr("id", $(ui.item).attr("data-id"));
						new_item.insertBefore(ui.item).addClass("create_element").removeClass("ui-draggable").draggableSetup("track_unit");
					}
					if ( ui.item.hasClass("prod-list__item") ){
						var this_name = $(ui.item).find(".prod-name").html(),
							this_author = $(ui.item).find(".prod-author").html(),
							new_item = create_new_element( type + "_unit" );

						new_item.find(".prod-name").html(this_name);
						new_item.find(".prod-author").html(this_author);
						new_item.attr("id", $(ui.item).attr("data-id"));
						new_item.insertBefore(ui.item).addClass("create_element").removeClass("ui-draggable").draggableSetup("track_unit");
					}
		        }
			},
			tolerance:  "pointer",
			change: function(event, ui){

				ui.helper.removeClass("static disabled").addClass("enabled");

				if ( $(this).data("list") == ui.helper.data("list") && (!ui.item.hasClass("prod-list__item"))){
					ui.helper.removeClass("enabled");
					ui.helper.addClass("static");
				}
			},
			placeholder: "sortable_placeholder"
		})

		$(document).on("click", ".prod-list__item .prod-name", function(){
			var _this = $(this),
				_this_item = _this.parents(".prod-list__item"),
				_this_list = $(this).parents(".prod-list");

			console.log( "2Детальное описание, id = " + _this.parents(".prod-list__item").attr("id") );
			_this_list.find(".prod-list__item--active").removeClass("prod-list__item--active");

			_this_item.addClass("prod-list__item--active");
			_this_item.prevAll(".prod-list__item").appendTo(_this_list);

		})





		//BRICK_MODE

		$(".b-widget__content-item--track").draggable($.extend({}, draggableOptsBrick, {
			connectToSortable: ".widget__list-slider--line, .prod-list--track, .tracklist--edit",
		}));

		$(".b-widget__content-item--redaction_playlist, .b-widget__content-item--user_playlist").draggable($.extend({}, draggableOptsBrick, {
			connectToSortable: ".widget__list-slider--line, .widget__list-slider--playlist",
		}));

		$(".b-widget__content-item--album").draggable($.extend({}, draggableOptsBrick, {
			connectToSortable: ".widget__list-slider--line, .widget__list-slider--album",
		}));
		$(".b-widget__content-item--editor").draggable($.extend({}, draggableOptsBrick, {
			connectToSortable: ".widget__list-slider--line, .widget__list-slider--editor",
		}));


		$(".widget__list-slider--track").droppable({
			accept: ".b-widget__content-item--track",
			tolerance:  "pointer"
		})
		$(".widget__list-slider--album").droppable({
			accept: ".b-widget__content-item--album",
			tolerance:  "pointer"
		});
		$(".widget__list-slider--playlist").droppable({
			accept: ".b-widget__content-item--user_playlist, .b-widget__content-item--redaction_playlist",
			tolerance:  "pointer"
		})
		$(".widget__list-slider--editor").droppable({
			accept: ".b-widget__content-item--editor",
			tolerance:  "pointer",
		})

		$(".widget__list-slider").sortable({
			helper: function(event, ui){
				var _helper  = $(".current-helper");
				return _helper;
			},
			receive: function(event, ui){
				//ui.item - old element
				var prod_id = ui.sender.attr("id");
				if ( $(this).data("list") == ui.sender.data("list") ){
					var this_copy = $(".sort_item_copy", this);
				 	ui.item.insertBefore(this_copy);
				 	this_copy.remove();
		        }
		        else {
		        	var new_element = $(".sort_item_new", this),
		        		create_element = $(".create_element", this);


		        	new_element.attr("id", prod_id);

		        	if ( inArray(prod_id, prod_id_array[$(this).data("list")])){ //element with this id already exists

		        		$("div[id=" + prod_id +"]", this).not(".sort_item_new").not(".bx-clone").not(".create_element").insertBefore(new_element);

		        		new_element.remove();
		        		create_element.remove();

		        	}
		        	else{
		        		new_element.removeClass("sort_item_new");
		        		prod_id_array[$(this).data("list")].push(prod_id);
		        	}

					if ( create_element.length ){
		        		new_element.remove();
		        		create_element.removeClass("create_element");
			       	}
			    }
			},
			beforeStop: function(event, ui){
				//ui.item  - create element
					ui.item.removeClass("prod-list__item--active");
					if ( $(this).data("list") == ui.item.data("list") ){
						ui.item.addClass("sort_item_copy");
			        }
			        else{
			        	var type = $(this).data("list");
			        	ui.item.addClass("sort_item_new");
			        	if ( type == "line") {
			        		type = ui.item.data("list");
			        	}
			        	ui.item.data("list", $(this).data("list"));
			        	ui.item.attr("data-list",  $(this).data("list"));//for copy
			        	ui.item.removeClass("ui-draggable").draggableSetup(type, "brick");


			        	if (ui.item.hasClass("prod-list__item") || ui.item.hasClass("tracklist__unit")){
							var this_name = $(ui.item).find(".prod-name").html(),
								this_author = $(ui.item).find(".prod-author").html(),
								new_item = create_new_element( type + "_brick" );
							var style = $(this).find(".b-widget__content-item").attr("style");
							new_item.find(".content-item_title").html(this_name);
							new_item.find(".content-item_author").html(this_author);
							new_item.attr("id", $(ui.item).attr("data-id"));
							new_item.insertBefore(ui.item).addClass("create_element").removeClass("ui-draggable").attr("style", style).draggableSetup(type, "brick");
						}
			        }
			},
			tolerance:  "pointer",
			change: function(event, ui){
					var wrapper = $(this).parents(".bx-wrapper")
					wrapper.find(".placeholder-clone").remove();

					ui.placeholder.html('<div class="sortable_placeholder--vertical__inner"></div>');
					var pic_height = $(this).find(".content-item_pic img").height();
					ui.placeholder.css("top", (+1)*(pic_height - ui.placeholder.height())/2 + 'px');
					var placeholder_clone = ui.placeholder.clone();
					var left_pos = ui.placeholder.offset().left - wrapper.offset().left;
					if  (left_pos > wrapper.width()){
						placeholder_clone.hide();
					}
					placeholder_clone.addClass("placeholder-clone").css("left", left_pos -  parseInt( ui.placeholder.css("marginLeft") ) ) ;
					placeholder_clone.prependTo(wrapper);

					var status = ui.helper.find(".brick__clone-dnd-status");

					ui.helper.removeClass("static disabled").addClass("enabled");
					status.removeClass("brick__clone-dnd-status--static brick__clone-dnd-status--disabled").addClass("brick__clone-dnd-status--add")

					if ( $(this).data("list") == ui.helper.data("list") ){
						ui.helper.removeClass("enabled");
						status.removeClass("brick__clone-dnd-status--add")
						ui.helper.addClass("static");
						status.addClass("brick__clone-dnd-status--static")
					}
			},
			stop: function(e, ui){
				$(this).parents(".bx-wrapper").find(".placeholder-clone").remove();
				$(document).on("mouseenter", ".content-item_pic", brick_hover_on);
    			$(document).on("mouseleave", ".content-item_pic", brick_hover_off);
			},
			out: function(){
				$(this).parents(".bx-wrapper").find(".placeholder-clone").remove();
			},
			placeholder: "sortable_placeholder--vertical",
			cursor: 'move',
			cursorAt: {	left: 5, top: 5},
			activate: function(event, ui){
				var sortable = $(this);

				$(".content-item__hover, .content-item_pic-back, .content-item_remove").hide();

				$(document).off("mouseenter", ".content-item_pic", brick_hover_on);
    			$(document).off("mouseleave", ".content-item_pic", brick_hover_off);

    			$(document).on("mousemove.viewport", function(e){
    				viewport_border(e, sortable.parents(".bx-viewport"), sortable)
    			});
			},
			deactivate: function(){
				$(document).on("mouseenter", ".content-item_pic", brick_hover_on);
    			$(document).on("mouseleave", ".content-item_pic", brick_hover_off);

				$(document).off("mousemove.viewport");
			}
		});
		$(".create_ico").on("click", function(){
			var item = $(".b-widget__content-item--track")
			if ( !item.data("draggable") ) {
				item.draggable($.extend(
				draggableOptsBrick,
				{
					connectToSortable: ".widget__list-slider--line, .widget__list-slider--track, .prod-list--track",
				}
				));
			}
			item.draggable("option", "handle", false);
		});

		viewport_border = function(event, viewport, sortable){
			var viewport_left = viewport.offset().left,
				viewport_top = viewport.offset().top,
				section = sortable.parents(".b-widget__content-section"),
				isOut = section.hasClass("isOut");

			if (isOut){
				if ( (viewport_left < event.clientX) && ( ( parseInt(viewport_left) + parseInt(viewport.width()) ) > event.clientX) ){
					sortable.css("overflow", "auto").sortable("refresh").sortable("refreshPositions")
					section.removeClass("isOut");
				}
			}
			else{
				if ( (viewport_left > event.clientX) || ( ( parseInt(viewport_left) + parseInt(viewport.width()) ) < event.clientX) ){
					sortable.css("overflow", "visible").sortable("refresh").sortable("refreshPositions");
					section.addClass("isOut");
				}
			}
		}

		/*remove items*/
		$(document).on("click", ".remove_item", function(){
			$(this).parents("li").remove();
		}).on("click", ".content-item_remove", function(){
			$(this).parents(".b-widget__content-item").remove();
		})
		//reinit slider ???

		/*x_remove_items*/

		/*edit items*/
			$(document).on("click", ".hover-control-i--edit, .settings-item--edit", function(){
				var id = $(this).parents("*[data-id]").attr("data-id");
			 	console.log("Редактирование элемента ID: " +  id);
			 	$(".b-widget-current").addClass("hidden");
			 	/*$(".b-widget-current").eq(1).removeClass("hidden").find(".tracklist-wrap").jScrollPane_n({});*/
			 	//$(".b-widget-content").css("min-height", ( Math.max( 770, _body.height() - 70, right_aside.height() ) ) + "px");
			 	$(".b-widget-content").css("min-height", ( Math.max( widget_mh, _body.height() - 90, $(right_aside).height() ) ) + "px");
			})
		/*x_edit_items*/
})