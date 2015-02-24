Event = require './event'
config = require '../config'
RequestManager = require './request_manager'
async = require 'async'
Utils = require  './utils'
Sync = require  './sync'

class Model extends Event

	#id: null
	@idName: 'id'
	urlRoot: null
	queryData: {}

	# private attributes
	_attributes = null
	_loaded = false
	_loading = false
	_changed = null
	_changing = false
	_previousAttributes = null
	_pending = false
	_idToUrl = true

	constructor: ( params ) ->
		@_prepareAttr '_attributes'
		@_prepareAttr '_changed'
		@_prepareAttr 'queryData'
		@_prepareAttr '_attributes'

		if _.isObject params
			_.each params, (val, key) =>
				@set key, val, silent: true
		else
			@setId id if id = parseInt params

		@urlRoot = Utils.pasteParamsToString(@urlRoot, params)

		if params && params.queryData
			@queryData = _.clone params.queryData
		#console.log 'model init: ' + @getId()
		super params

	destroy: ()->

	getUrl: (params)->

		urlPath = ''
		url = ''
		mathod = params?.method || ''
		switch( mathod )
			when 'create' then urlPath = @urlCreate || @urlRoot
			when 'update' then urlPath = @urlUpdate || @urlRoot
			when 'patch' then  urlPath = @urlPatch || @urlRoot
			when 'delete' then urlPath = @urlDelete || @urlRoot
			else urlPath = @urlRoot

		if urlPath
			getParams = []
			getParams = _.map _.extend({}, @queryData, params.data), (value, name)-> return name+'='+encodeURIComponent(value)

			url = config.server.api + urlPath + '/' + if @_idToUrl != false and @getIdName() then @getId() else ''

			url += '?' + getParams.join '&' if getParams.length

		url

	fetch: ( params ) ->
		# handle (callback) and ({callback, options}) params style
		method = 'read'
		if _.isFunction params
			callback = params
		else if _.isObject params
			callback = params?.callback || ()->
			options = params?.options || {}
			extData = params?.data || {}

		options = {} if ! options
		url = @getUrl data: extData, method: method
		if !@loaded() && url && ! @loading()
			console.log 'fetching model: ' + url
			@beforeFetch()
			@loading true

			#RequestManager.get url, options, (err, data) =>
			success = (err, data) =>

				if err
					if _.isFunction callback
						callback err
					return

				data = @parse data
				@build data

				# changing statuses
				@loaded true
				@loading false

				@trigger 'fetch_success'

				# call function after success fetching
				@afterFetch data

				if _.isFunction callback
					callback null, @

			@sync method, @, _.extend( options, {url: url, callback: success} )
		else
			if _.isFunction callback
				callback null, @

	beforeFetch: ()->
	afterFetch: (data)->

	# getters / setters : start
	loaded:( value )->
		value = @_loaded if _.isUndefined value
		@_loaded = !! value

	loading: (value)->
		value = @_loading if _.isUndefined value
		@_loading = !! value
	# getters / setters : end

	isNew: ()->
		id = @getId()
		_.isNull( id ) || _.isUndefined( id )

	has: (attr)-> @get(attr) != null
	get: (attr) -> @_attributes[attr]
	getAttributes: () -> _.clone @_attributes
	getId: ()-> @_attributes[@getIdName()]
	getIdName: ()-> @constructor.idName
	toJSON: (options)-> _.clone @_attributes

	setId: (id)->
		if id && ( _.isNumber id || id = parseInt id )
			@_attributes[@getIdName()] = id
			true
		else
			false

	build: (data)->
		if _.isObject data
			_.extend @_attributes, data
			true
		else
			false

	parse: (data, options)->
		data = JSON.parse(data) if _.isString data
		data

	stringify: ()->
		JSON.stringify @getAttributes()

	validate: (attrs, options)->
		true

	sync: ()->
		Sync.request.apply @, arguments

	set: (key, val, options)->
		if ! key
			return @

		if _.isObject key
			attrs = key
			options = val
		else
			(attrs = {})[key] = val

		#console.log 'SET MODEL ATTRIBUTES: '
		#console.log attrs

		options = {} if !options

		# Run validation.
		if !@validate attrs, options
			return false

		# Extract attributes and options.
		unset = options.unset
		silent = options.silent
		changes = []
		changing = @_changing
		@_changing = true

		if !changing
			@_previousAttributes = _.clone(@_attributes)
			@_changed = {}

		current = @_attributes
		prev = @_previousAttributes

		#Check for changes of `id`.
		@setId attrs[@getIdName()] if attrs[@getIdName()]

		# For each `set` attribute, update or delete the current value.
		_.each attrs, (val, attr )=>

			if !_.isEqual current[attr], val
				changes.push attr
			if !_.isEqual prev[attr], val
				@_changed[attr] = val
			else
				delete @_changed[attr]

			if unset then delete current[attr] else current[attr] = val

		# Trigger all relevant attribute changes.
		if !silent
			if changes.length
				@_pending = true

			_.each changes, (attr)=>
				@trigger 'change:' + attr, _.extend options, {value: current[attr]}

		# You might be wondering why there's a `while` loop here. Changes can
		# be recursively nested within `"change"` events.
		if changing
			return @

		if !silent
			while @_pending
				@_pending = false;
				@trigger 'change', options

		@_pending = false;
		@_changing = false;
		@

	unset: (attr, options)->
		@set attr, null, _.extend( {}, options, {unset: true} )

	save: ( key, val, options )->
		attributes = @_attributes

		if _.isNull( key ) || _.isObject( key )
			attrs = key
			options = val
		else
			(attrs = {})[key] = val

		options = _.extend {validate: true}, options

		if attrs && ! options.wait
			if ! @set attrs, options
				return false
		else if ! @validate attrs, options
				return false

		if attrs && options.wait
			@_attributes = _.extend {}, attributes, attrs

		callback = options.callback

		options.callback = (err, resp)=>
			@_attributes = attributes;
			serverAttrs = @parse resp, options

			if options.wait
				serverAttrs = _.extend attrs || {}, serverAttrs

			if _.isObject(serverAttrs) && ! @set( serverAttrs, options )
				return false

			if _.isFunction callback
				callback err, resp #@, resp, options

			@trigger 'sync', @, options, err, resp

		#wrapError @, options

		method = if @isNew() then 'create' else ( if options.patch then 'patch' else 'update' )
		options.attrs = attrs if method == 'patch'

		xhr = @sync method, @, options

		if attrs && options.wait
			@_attributes = attributes;

		xhr

	#destroy: (options)-> @
	#remove: ( options )-> @


module.exports = Model