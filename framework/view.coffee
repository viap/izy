config = require '../config'
Event = require './event'
Router = require './router'
async = require 'async'

class View extends Event
	# template name consist of applicatuion name and template filename separated by :
	templateName: null
	emptyTemplateName: 'common:empty'

	model: null

	@_count: 0

	# context is jQuery selector or response object
	context: null

	# events to bind
	# events: null
	# global events to bind
	globalEvents: null

	constructor: (params)->
		if params && params.model
			@model = params.model
		#console.log params

		@constructor._count++
		@_number = @constructor._count

		super params

	destroy: ()->

	goToUrl: ( event, url, options )->
		Router.goToUrl event, url, options

	bindEvents: ()->
		@bindEvent eventName, eventHandler for eventName, eventHandler of @events
		@bindEvent eventName, eventHandler, true for eventName, eventHandler of @globalEvents
		#delete @events
		#delete @globalEvents

	bindEvent: (eventName, eventHandler, global) ->
		eventHandler = @[eventHandler] if !_.isFunction eventHandler
		return if !eventHandler

		delegateEventSplitter = /^(\S+)\s*(.*)$/

		match = eventName.match delegateEventSplitter
		selector = match[2]
		eventName = match[1]

		#method = _.bind eventHandler, @

		currentView = @
		method = ()->

					args = _.map arguments, (val)-> val

					event = args[0] || window.event || {}
					# stopPropogation and preventDefault
					if event.stopPropagation then event.stopPropagation() else event.cancelBubble = true
					if event.preventDefault then event.preventDefault() else event.returnValue = false

					$target = $ @
					args.push $target

					task = ()=>
							eventHandler.apply currentView, args

					# model is not loaded
					if currentView.model && ! currentView.model.loaded() && ! currentView.model.loading()
						currentView.model.fetch task
					else
						# model is loading
						if currentView.model && currentView.model.loading()
							afterFetch_callback = currentView.model.afterFetch
							currentView.model.afterFetch = (data)=>
								task()
								afterFetch_callback(data)
								currentView.model.afterFetch = afterFetch_callback
						else
							# model is empty or was loaded
							task()

		if !! global
			Event::on eventName, method
		else
			if selector == ''
				if eventName == 'init'
					$(document).ready method
				else
					@context.on eventName, method
			else
				@context.on eventName, selector, method

		# console.log 'TODO BINDING BASED ON BACKBONE VIEW', eventName

	setContext: (context) ->
		@context = context

	show: (params, data) ->
		if config.isBrowser()
			$obj = $(data)

			_.each params, (value, key)->
				if !_.isEmpty value
					$obj.attr 'data-'+key, value

			if @context && @context.size()
				@context.replaceWith $obj
				@context = $obj
		else
			@context.send data


module.exports = View