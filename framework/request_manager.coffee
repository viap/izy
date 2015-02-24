config = require '../config'

class RequestManager
	## ============ STATIC ============ ##
	@instance: null
	@request: null
	# static method for singleton
	@getInstance: ()->
		if ! @instance
			@instance = new RequestManager();
		@instance;
	## ============ STATIC ============ ##

	_defaultParams: null
	_defaultData: null
	_defaultToUrl: true

	constructor: ()->
		@_defaultParams = {}
		@_defaultData = {}
		@_defaultToUrl = true

		if config.isServer()
			RequestManager.serverRequest = require './node/server_request'
			RequestManager.serverRequest._defaultParams = @_defaultParams
			RequestManager.serverRequest._defaultData = @_defaultData
			RequestManager.serverRequest._defaultToUrl = @_defaultToUrl

			@ajax = (url, options, callback)=> RequestManager.serverRequest.ajax url, options, callback
			@get  = (url, options, callback)=> RequestManager.serverRequest.get url, options, callback
			@post = (url, options, callback)=> RequestManager.serverRequest.post url, options, callback
			@del  = (url, options, callback)=> RequestManager.serverRequest.del url, options, callback
			@put = (url, options, callback)=> RequestManager.serverRequest.put url, options, callback
			@patch  = (url, options, callback)=> RequestManager.serverRequest.patch url, options, callback

	_initParams: ( url, options, callback )->
		opts = {}

		if _.isString url
			if _.isFunction options
				callback = options
			else if _.isObject options
				if options && _.isFunction options.callback
					callback = options.callback
					delete options.callback
				_.extend opts, options
			opts.url = url
		else if _.isObject url
			if url && _.isFunction url.callback
				callback = url.callback
				delete url.callback
			_.extend opts, url
			callback = options if _.isFunction options
		else
			throw new Error 'Invalid parameters'

		if callback
			opts.success = (data) ->
							callback null, data

		if callback && !opts.error
			opts.error = (jqXHR, textStatus, errorThrown ) ->
							callback( textStatus || 'Unknown error while sending GET request', null)

		# add Default params
		if @_defaultToUrl
			if opts.url.indexOf('?') >= 0
				opts.url += '&'
			else
				opts.url += '?'
			opts.url += _.map(@_defaultData, (v,k)-> k+'='+v ).join '&'
		else
			opts.data = {} if ! opts.data
			_.extend opts.data, @_defaultData

		opts

	ajax: (url, options, callback)->
		params = _.extend {}, @_defaultParams, @_initParams( url, options, callback )
		$.ajax params

	get: (url, options, callback)->
		params = _.extend {}, @_defaultParams, @_initParams( url, options, callback ), {type: 'get'}
		$.ajax params

	post: (url, options, callback)->
		params = _.extend {}, @_defaultParams, @_initParams( url, options, callback ), {type: 'post'}
		$.ajax params

	del: (url, options, callback)->
		params = _.extend {}, @_defaultParams, @_initParams( url, options, callback ), {type: 'delete'}
		$.ajax params

	put: (url, options, callback)->
		params = _.extend {}, @_defaultParams, @_initParams( url, options, callback ), {type: 'put'}
		$.ajax params

	patch: (url, options, callback)->
		params = _.extend {}, @_defaultParams, @_initParams( url, options, callback ), {type: 'patch'}
		$.ajax params

	setDefaultToUrl: (value)->
		if config.isBrowser()
			@_defaultToUrl = !! value
		else
			RequestManager.serverRequest._defaultToUrl = !! value

	setDefaultData:(name, value)->
		params = {}
		if _.isObject name
			params = name
		else if _.isString name
			params[name] = value

		_.each params, (value, name) =>
			if config.isBrowser()
				@_defaultData[name] = value
			else
				RequestManager.serverRequest._defaultData[name] = value

	deleteDefaultData:(name)->
		names = []
		if _.isArray name
			names = name
		else if _.isString name
			names.push name

		_.each names, (name) =>
			if config.isBrowser()
				delete @_defaultData[name]
			else
				delete RequestManager.serverRequest._defaultData[name]

	setDefaultParam:(name, value)->
		params = {}
		if _.isObject name
			params = name
		else if _.isString name
			params[name] = value

		_.each params, (value, name)=>
			if config.isBrowser()
				@_defaultParams[name] = value
			else
				RequestManager.serverRequest._defaultParams[name] = value

	getDefaultToUrl: ()->
		if config.isBrowser()
			@_defaultToUrl
		else
			RequestManager.serverRequest._defaultToUrl

	getDefaultParam: ()->
		if config.isBrowser()
			@_defaultParams
		else
			RequestManager.serverRequest._defaultParams

	getDefaultData: ()->
		if config.isBrowser()
			@_defaultData
		else
			RequestManager.serverRequest._defaultData

module.exports = RequestManager.getInstance()