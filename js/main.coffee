class Main
	constructor:->
		@$window = $(window)
		@$body = $(document.body)
		@$header = $('#js-header')
		@$headerSection = $('#js-header-section')
		@$services = $('.service-b').first()
		@$abouts    = $('.about-b').first()
		@$pageJumps = $('.page-jump-e')
		@$menu = $('#js-menu')
		@$mainLogo = $('#js-main-logo')
		@$bodyHtml = $('body,html')

		@POPUP_OFFSET = 49
		@POPUP_HEADER_OFFSET = 60
		@CLICK_EVENT = if $.isFunction($.fn.tap) then 'tap' else 'click'

		# @$mask = $('#js-blinded-mask')
		
		@$greenBtn 	= $('.js-green-btn')
		@$blueBtn 	= $('.js-blue-btn')
		@$redBtn 	= $('.js-red-btn')

		@$greenPopup 	= $('#js-green-popup')
		@$bluePopup 	= $('#js-blue-popup')
		@$redPopup 		= $('#js-red-popup')

		@$popupSpacer 	= $('#js-popup-spacer')

		@servicesAnimated = []
		@aboutsAnimated	  = []


		@listenToScroll()
		@listenToPopups()
		@listenMenu()
		@$body.on @CLICK_EVENT, =>  @hidePopup()

		@normalHeader =
			animate:
				'top': 0
				'opacity': 1
			css:
				'position':'fixed'
				'top': -@$header.outerHeight()
				'opacity': 0

		@fixedHeader = 
			animate:
				'top': -@$header.outerHeight()
				'opacity': 0
			css:
				'top': 0
				'position':'absolute'
				'opacity': 1

	listenToPopups:->
		@$greenBtn.on 	@CLICK_EVENT, (e)=> e.stopPropagation(); @showPopup @$greenPopup, e;   
		@$blueBtn.on 	@CLICK_EVENT, (e)=> e.stopPropagation(); @showPopup @$bluePopup, e; 
		@$redBtn.on 	@CLICK_EVENT, (e)=> e.stopPropagation(); @showPopup @$redPopup, e; 
		# @$mask.on 		@CLICK_EVENT, _.bind @hidePopup, @
		@$window.on 'throttledresize', _.bind @positPopup, @
		@$mainLogo.on @CLICK_EVENT, (e)=> e.stopPropagation(); e.preventDefault(); @$bodyHtml.animate {'scrollTop': 0}, 750 ; return false

	showPopup:($popup, e)->
		# @$mask.show()
		@$currentPopup?.hide()
		$target = $(e.target)
		@$currentPopup = $popup.fadeIn()
		@$currentPopup.data '$target': $target
		@positPopup()
		if !$popup.data().closeHandler
			$popup.find('#js-close').on @CLICK_EVENT, =>  $popup.data('closeHandler': true); @hidePopup()
			$popup.on @CLICK_EVENT, (e)=> e.stopPropagation()
		@$bodyHtml.animate 'scrollTop': $popup.offset().top - @POPUP_OFFSET	- @POPUP_HEADER_OFFSET
		@$popupSpacer.css 'height': $popup.outerHeight()

	positPopup:->
		if !@$currentPopup then return
		$target = @$currentPopup.data().$target
		@$currentPopup.css
			top: $target.position().top + 2*$target.outerHeight() + @POPUP_OFFSET

	hidePopup:(speed='fast')->
		# @$mask.fadeOut('fast');
		@$currentPopup?.fadeOut(speed, => @$currentPopup = null; @$window.trigger 'scroll')
		@$popupSpacer.css 'height': 0


	listenToScroll:->
		@currState = false
		@$window.on 'scroll', _.bind @scroll, @
		@$window.trigger 'scroll'


	listenMenu:->
		@$menu.on 'click', 'a', (e)=>
			e.preventDefault()
			@scrollToSection $(e.target).attr 'href'
			

	scrollToSection:(selector)->
		@$bodyHtml.animate 'scrollTop': $(selector).offset().top


	scroll:(e)->
		@showHeader @$window.scrollTop() >= @$headerSection.outerHeight()
		if !@servicesAnimated[0]
			@animateBlocks 
				state: (@$window.scrollTop() + @$window.outerHeight()) >= @$services.offset().top + (@$window.outerHeight()/5)
				delay: 200
				selector: '.service-b'
				lock: @servicesAnimated
				animation: 'fadeInLeft'

		if !@aboutsAnimated[0]
			@animateBlocks 
				state: (@$window.scrollTop() + @$window.outerHeight()) >= @$abouts.offset().top + (@$window.outerHeight()/5)
				delay: 100
				selector: '.about-b'
				lock: @aboutsAnimated
				animation: 'fadeInDown'

		@checkMenu()

	checkMenu:->
		@currJump = @$pageJumps.eq(0)
		for i in [0..@$pageJumps.length-1]
			if @$window.scrollTop() >= @$pageJumps.eq(i).position().top - (@$window.outerHeight()/2) then @currJump = @$pageJumps.eq(i)
			if @$window.scrollTop() < @POPUP_OFFSET then @currJump = @$pageJumps.eq(0)
			if @$window.scrollTop() >= @$bodyHtml.outerHeight() - @$window.outerHeight() then @currJump = @$pageJumps.eq(@$pageJumps.length-1)
		@checkMenuItem @currJump

	checkMenuItem:($item)->
		menuId = $item.attr 'id'
		@$menu.find("a[href=\"##{menuId}\"]").addClass('is-active').siblings().removeClass('is-active')


	showHeader:(state)->
		if state and (state isnt @currState)
			@currState = state
			@$header.css(@normalHeader.css)
			.addClass('is-fixed')
			.stop().animate @normalHeader.animate

		if !state and (state isnt @currState)
			@currState = state
			@$header.stop().animate @fixedHeader.animate, 200, =>
				@$header.css @fixedHeader.css
				@$header.removeClass('is-fixed')

	animateBlocks:(o)->
		if o.state
			@makeChain 
				$els: $(o.selector)
				delay: o.delay
				animation: o.animation
			o.lock[0] = true


	makeChain:(o)->
		o.i ?= 0
		if o.i is o.$els.length then return
		@animate(o.$els[o.i],o).then =>
			@makeChain 
				$els: o.$els
				i: ++o.i
				delay: o.delay
				animation: o.animation

	animate:(el,o)->
		dfr = new $.Deferred
		if Modernizr.cssanimations then $(el).addClass "animated #{o.animation}" else $(el).animate('opacity':1)
		setTimeout => 
			dfr.resolve()
		, o.delay

		dfr.promise()

		
new Main