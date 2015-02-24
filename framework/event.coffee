class Event

	## ============ STATIC ============ ##
	# optimized internal dispatch function for triggering events like backbone.events
	@maxHandlersCount: 10
	@triggerEvents: (events, args)->
		ind = -1
		len = events.length
		a1 = args[0]
		a2 = args[1]
		a3 = args[2]
		switch (args.length)
			when 0 then (ev = events[ind]).handler.call ev.ctx while (++ind < len)
			when 1 then (ev = events[ind]).handler.call ev.ctx, a1 while (++ind < len)
			when 2 then (ev = events[ind]).handler.call ev.ctx, a1, a2 while (++ind < len)
			when 3 then (ev = events[ind]).handler.call ev.ctx, a1, a2, a3 while (++ind < len)
			else (ev = events[ind]).handler.apply ev.ctx, args while (++ind < len)

	@getName: ()->
		self = @
		f = typeof self == 'function'
		if !f
			self = self.constructor
			f = typeof self == 'function'
		s = f && ((self.name && ['', self.name]) || self.toString().match(/function ([^\(]+)/))
		(!f && 'not a function') || (s && s[1] || 'anonymous')
	## ============ STATIC ============ ##

	#_events: {}
	#_listeners:{}

	_prepareAttr: (attr, defaultValue)->
		if ! _.has @, attr
			@[attr] = (@[attr] && _.clone @[attr]) || defaultValue || {}

	constructor:()->
		@_prepareAttr '_events'
		@_prepareAttr '_listeners'

	setName: (name)->
		@name = name

	getName: ()->
		Event.getName.apply @, arguments

	clear:()->
		@_events = {}

	trigger: (name) ->
		if @_events && @_events[name]
			args = [].slice.call arguments, 1
			events = @_events[name]
			allEvents = @_events.all
			Event.triggerEvents events, args if events
			Event.triggerEvents allEvents, arguments if allEvents
		@

	on: (name, handler, context) ->
		@_prepareAttr '_events'
		@_events[name] = [] if !@_events[name]
		evObj = { handler: handler, context: context, ctx: context || @ }
		if _.isEmpty(_.findWhere( @_events[name], evObj) )
			@_events[name].push evObj

		if @_events[name].length > Event.maxHandlersCount
			console.log 'WARNING: possible memory leak'
		@

	once: (name, handler, context) ->
		self = @
		once = _.once ()->
			self.off(name, once);
			handler.apply(this, arguments);

		once._callback = handler;
		@on name, once, context

	off: (name, handler, context)->
		if !name && !handler && !context
			@_events = {}

		if name then names = [name] else names = _.keys @_events

		_.each names, (evName)=>
			if events = @_events[evName]
				@_events[evName] = retain = [];
				if handler || context
					_.each events, (ev)=>
						if (handler && handler != ev.handler && handler != (ev.handler && ev.handler._callback) ) || (context && context != ev.context)
							retain.push ev
				delete @_events[evName] if !retain.length

		@

	listenTo: ( obj, name, handler )->
		listeners = @_listeners || (@_listeners = {})
		id = obj._listenerId || (obj._listenerId = _.uniqueId('l'))
		listeners[id] = obj
		obj.on name, handler, @
		@

	listenToOnce: ( obj, name, handler )->
		listeners = @_listeners || (@_listeners = {})
		id = obj._listenerId || (obj._listenerId = _.uniqueId('l'))
		listeners[id] = obj
		obj.once name, handler, @
		@

	stopListening: ( obj, name, handler ) ->

		deleteListener = ! name && ! handler

		if obj && obj._listenerId
			(listeners = {})[obj._listenerId] = obj

		if listeners
			_.each listeners, (listner, id)=>
				listner.off name, handler, @
				delete @_listeners[id] if deleteListener && @_listeners[id]
		@

	reListenTo:(obj, name, handler)->
		@stopListening obj, name, handler
		@listenTo obj, name, handler

	reListenToOnce:(obj, name, handler )->
		@stopListening obj, name, handler
		@listenToOnce obj, name, handler

module.exports = Event

Config = require '../config'

if( Config.isBrowser() )
	window.CEvent = Event